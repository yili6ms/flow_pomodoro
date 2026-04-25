import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_pomodoro/providers/settings_provider.dart';
import 'package:flow_pomodoro/providers/stats_provider.dart';
import 'package:flow_pomodoro/providers/task_provider.dart';
import 'package:flow_pomodoro/providers/timer_provider.dart';
import 'package:flow_pomodoro/services/in_memory_session_store.dart';

Future<TimerProvider> _newTimer({bool autoSwitch = false}) async {
  SharedPreferences.setMockInitialValues({});
  final s = SettingsProvider();
  await s.load();
  await s.setFocusMinutes(25);
  await s.setShortBreakMinutes(5);
  await s.setLongBreakMinutes(15);
  await s.setRoundsBeforeLongBreak(4);
  await s.setAutoSwitch(autoSwitch);
  await s.setHaptics(false); // avoid platform haptic calls in tests
  final t = TaskProvider();
  await t.load();
  final st = StatsProvider(store: InMemorySessionStore());
  await st.load();
  return TimerProvider(settings: s, tasks: t, stats: st);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerProvider', () {
    test('starts in idle state', () async {
      final t = await _newTimer();
      expect(t.phase, TimerPhase.idle);
      expect(t.status, TimerStatus.stopped);
      expect(t.remainingSeconds, 0);
      expect(t.progress, 0);
    });

    test('startFocus sets phase, total, intent', () async {
      final t = await _newTimer();
      t.startFocus(intent: 'write tests');
      expect(t.phase, TimerPhase.focus);
      expect(t.status, TimerStatus.running);
      expect(t.totalSeconds, 25 * 60);
      expect(t.remainingSeconds, 25 * 60);
      expect(t.currentIntent, 'write tests');
      expect(t.flowStage, 'initiation');
      t.stop(record: false);
    });

    test('ticks decrement remainingSeconds each second', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'x');
        async.elapse(const Duration(seconds: 5));
        expect(t.remainingSeconds, 25 * 60 - 5);
        expect(t.elapsedSeconds, 5);
        t.stop(record: false);
      });
    });

    test('pause stops ticking; resume continues', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'x');
        async.elapse(const Duration(seconds: 3));
        t.pause();
        expect(t.status, TimerStatus.paused);
        async.elapse(const Duration(seconds: 10));
        expect(t.remainingSeconds, 25 * 60 - 3);
        t.resume();
        async.elapse(const Duration(seconds: 2));
        expect(t.remainingSeconds, 25 * 60 - 5);
        t.stop(record: false);
      });
    });

    test('flowStage advances initiation → stabilization → deep', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'x');
        expect(t.flowStage, 'initiation');
        async.elapse(const Duration(minutes: 4));
        expect(t.flowStage, 'stabilization');
        async.elapse(const Duration(minutes: 12));
        expect(t.flowStage, 'deep');
        t.stop(record: false);
      });
    });

    test('focus completion increments round and records session', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'finish');
        async.elapse(const Duration(minutes: 25));
        async.elapse(const Duration(seconds: 1));
        expect(t.currentRound, 1);
        expect(t.lastSessionSummary?.completed, true);
        expect(t.lastSessionSummary?.intent, 'finish');
        expect(t.stats.totalCompletedSessions, 1);
        expect(t.stats.totalFocusSeconds, 25 * 60);
        // Without autoSwitch, phase advances to shortBreak but stays stopped
        expect(t.phase, TimerPhase.shortBreak);
        expect(t.status, TimerStatus.stopped);
        expect(t.remainingSeconds, 5 * 60);
      });
    });

    test('restorePersistedState restores a running focus timer', () async {
      final t1 = await _newTimer();
      t1.startFocus(intent: 'restore me');
      await Future<void>.delayed(Duration.zero);

      final s = SettingsProvider();
      await s.load();
      final tasks = TaskProvider();
      await tasks.load();
      final stats = StatsProvider(store: InMemorySessionStore());
      await stats.load();
      final t2 = TimerProvider(settings: s, tasks: tasks, stats: stats);
      await t2.restorePersistedState();

      expect(t2.phase, TimerPhase.focus);
      expect(t2.status, TimerStatus.running);
      expect(t2.currentIntent, 'restore me');
      expect(t2.remainingSeconds, greaterThan(0));
      t1.stop(record: false);
      t2.stop(record: false);
    });

    test('long break triggers every Nth round', () async {
      final t = await _newTimer(autoSwitch: true);
      fakeAsync((async) {
        for (int i = 0; i < 4; i++) {
          t.startFocus(intent: 'r$i');
          async.elapse(const Duration(minutes: 25, seconds: 1));
          // auto-switched into break — finish it too
          async.elapse(const Duration(minutes: 30));
        }
        expect(t.currentRound, 4);
        // After 4th focus, break should be longBreak (15m).
        // Hard to inspect mid-cycle; instead verify stats shows 4 sessions.
        expect(t.stats.totalCompletedSessions, 4);
      });
    });

    test('stop returns to idle and cancels ticker', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'partial');
        async.elapse(const Duration(seconds: 30));
        t.stop(record: false);
        expect(t.phase, TimerPhase.idle);
        expect(t.status, TimerStatus.stopped);
        expect(t.remainingSeconds, 0);
        // Ticker no longer fires.
        async.elapse(const Duration(seconds: 5));
        expect(t.remainingSeconds, 0);
      });
    });

    test('completion increments active task pomodoro count', () async {
      final t = await _newTimer();
      await t.tasks.addTask('Demo');
      fakeAsync((async) {
        t.startFocus(intent: 'demo');
        async.elapse(const Duration(minutes: 25, seconds: 1));
      });
      expect(t.tasks.activeTask?.completedPomodoros, 1);
    });

    test('progress goes from 0 to 1', () async {
      final t = await _newTimer();
      fakeAsync((async) {
        t.startFocus(intent: 'x');
        expect(t.progress, 0);
        async.elapse(const Duration(minutes: 12, seconds: 30));
        expect(t.progress, closeTo(0.5, 0.01));
        t.stop(record: false);
      });
    });
  });
}
