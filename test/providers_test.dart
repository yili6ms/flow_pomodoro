import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_pomodoro/providers/settings_provider.dart';
import 'package:flow_pomodoro/providers/task_provider.dart';
import 'package:flow_pomodoro/providers/stats_provider.dart';
import 'package:flow_pomodoro/models/session.dart';
import 'package:flow_pomodoro/models/white_noise.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider', () {
    test('defaults are spec values', () async {
      final s = SettingsProvider();
      await s.load();
      expect(s.focusMinutes, 25);
      expect(s.shortBreakMinutes, 5);
      expect(s.longBreakMinutes, 15);
      expect(s.roundsBeforeLongBreak, 4);
      expect(s.autoSwitch, false);
      expect(s.reduceMotion, false);
      expect(s.haptics, true);
      expect(s.onboarded, false);
      expect(s.themeMode, ThemeMode.dark);
    });

    test('changes persist across reload', () async {
      final s1 = SettingsProvider();
      await s1.load();
      await s1.setFocusMinutes(45);
      await s1.setAutoSwitch(true);
      await s1.setThemeMode(ThemeMode.light);
      await s1.setOnboarded(true);

      final s2 = SettingsProvider();
      await s2.load();
      expect(s2.focusMinutes, 45);
      expect(s2.autoSwitch, true);
      expect(s2.themeMode, ThemeMode.light);
      expect(s2.onboarded, true);
    });

    test('clamps values to valid ranges', () async {
      final s = SettingsProvider();
      await s.load();
      await s.setFocusMinutes(999);
      expect(s.focusMinutes, 180);
      await s.setFocusMinutes(0);
      expect(s.focusMinutes, 1);
      await s.setRoundsBeforeLongBreak(99);
      expect(s.roundsBeforeLongBreak, 10);
      await s.setRoundsBeforeLongBreak(0);
      expect(s.roundsBeforeLongBreak, 2);
    });

    test('notifies listeners on change', () async {
      final s = SettingsProvider();
      await s.load();
      var calls = 0;
      s.addListener(() => calls++);
      await s.setFocusMinutes(30);
      expect(calls, 1);
      await s.setHaptics(false);
      expect(calls, 2);
    });

    test('white noise selection and volume persist', () async {
      final s1 = SettingsProvider();
      await s1.load();
      expect(s1.whiteNoise, WhiteNoise.off);
      expect(s1.noiseVolume, 0.5);

      await s1.setWhiteNoise(WhiteNoise.rain);
      await s1.setNoiseVolume(0.8);

      final s2 = SettingsProvider();
      await s2.load();
      expect(s2.whiteNoise, WhiteNoise.rain);
      expect(s2.noiseVolume, closeTo(0.8, 1e-9));
    });

    test('noise volume is clamped to 0..1', () async {
      final s = SettingsProvider();
      await s.load();
      await s.setNoiseVolume(2.0);
      expect(s.noiseVolume, 1.0);
      await s.setNoiseVolume(-0.5);
      expect(s.noiseVolume, 0.0);
    });

    test('WhiteNoise.fromId falls back to off for unknown ids', () {
      expect(WhiteNoise.fromId(null), WhiteNoise.off);
      expect(WhiteNoise.fromId('garbage'), WhiteNoise.off);
      expect(WhiteNoise.fromId('pink'), WhiteNoise.pink);
    });
  });

  group('TaskProvider', () {
    test('addTask sets first task as active', () async {
      final p = TaskProvider();
      await p.load();
      final t = await p.addTask('First task');
      expect(p.activeTasks.length, 1);
      expect(p.activeTaskId, t.id);
      expect(p.activeTask?.title, 'First task');
    });

    test('addTask trims title and keeps existing active', () async {
      final p = TaskProvider();
      await p.load();
      final a = await p.addTask('A');
      await p.addTask('  B  ');
      expect(p.activeTaskId, a.id);
      expect(p.tasks.first.title, 'B');
    });

    test('setActive switches active task', () async {
      final p = TaskProvider();
      await p.load();
      await p.addTask('A');
      final b = await p.addTask('B');
      await p.setActive(b.id);
      expect(p.activeTaskId, b.id);
      await p.setActive(null);
      expect(p.activeTaskId, null);
      expect(p.activeTask, null);
    });

    test('deleteTask clears active when deleting active', () async {
      final p = TaskProvider();
      await p.load();
      final a = await p.addTask('A');
      await p.deleteTask(a.id);
      expect(p.activeTaskId, null);
      expect(p.activeTasks, isEmpty);
    });

    test('incrementPomodoro increases count', () async {
      final p = TaskProvider();
      await p.load();
      final a = await p.addTask('A');
      await p.incrementPomodoro(a.id);
      await p.incrementPomodoro(a.id);
      expect(p.activeTask?.completedPomodoros, 2);
    });

    test('renameTask updates title', () async {
      final p = TaskProvider();
      await p.load();
      final a = await p.addTask('Old');
      await p.renameTask(a.id, 'New');
      expect(p.tasks.first.title, 'New');
    });

    test('persists tasks across reload', () async {
      final p1 = TaskProvider();
      await p1.load();
      await p1.addTask('Persist me');
      await p1.incrementPomodoro(p1.activeTaskId!);

      final p2 = TaskProvider();
      await p2.load();
      expect(p2.tasks.length, 1);
      expect(p2.tasks.first.title, 'Persist me');
      expect(p2.tasks.first.completedPomodoros, 1);
      expect(p2.activeTaskId, p1.activeTaskId);
    });

    test('survives malformed JSON in storage', () async {
      SharedPreferences.setMockInitialValues({
        'tasks.list': 'not valid json{{{',
        'tasks.activeId': 'ghost',
      });
      final p = TaskProvider();
      await p.load();
      expect(p.tasks, isEmpty);
      expect(p.activeTaskId, null);
      // Should be usable after recovery.
      await p.addTask('Recovery');
      expect(p.tasks.length, 1);
    });

    test('skips individual corrupt task entries', () async {
      // Mix one good entry and one bad (missing required fields).
      SharedPreferences.setMockInitialValues({
        'tasks.list': '[{"bogus":"entry"},{"id":"1","title":"Good","completedPomodoros":2,"archived":false,"createdAt":"2026-04-18T10:00:00.000Z"}]',
      });
      final p = TaskProvider();
      await p.load();
      expect(p.tasks.length, 1);
      expect(p.tasks.first.title, 'Good');
    });

    test('clears stale activeId pointing to deleted task', () async {
      SharedPreferences.setMockInitialValues({
        'tasks.list': '[]',
        'tasks.activeId': 'gone',
      });
      final p = TaskProvider();
      await p.load();
      expect(p.activeTaskId, null);
    });
  });

  group('StatsProvider', () {
    FocusSession make({
      required DateTime start,
      int duration = 1500,
      bool completed = true,
    }) {
      return FocusSession(
        id: start.microsecondsSinceEpoch.toString(),
        taskId: null,
        taskTitle: null,
        intent: null,
        startedAt: start,
        endedAt: start.add(Duration(seconds: duration)),
        durationSeconds: duration,
        completed: completed,
      );
    }

    test('aggregates totals (only completed)', () async {
      final s = StatsProvider();
      await s.load();
      await s.recordSession(make(start: DateTime.now(), duration: 1500));
      await s.recordSession(make(start: DateTime.now(), duration: 600));
      await s.recordSession(
          make(start: DateTime.now(), duration: 300, completed: false));
      expect(s.totalCompletedSessions, 2);
      expect(s.totalFocusSeconds, 2100);
    });

    test('focusSecondsForDay only counts that day', () async {
      final s = StatsProvider();
      await s.load();
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      await s.recordSession(make(start: today, duration: 1500));
      await s.recordSession(make(start: yesterday, duration: 600));
      expect(s.focusSecondsForDay(today), 1500);
      expect(s.focusSecondsForDay(yesterday), 600);
    });

    test('last7DaysMinutes returns 7 entries with today last', () async {
      final s = StatsProvider();
      await s.load();
      await s.recordSession(make(start: DateTime.now(), duration: 1800));
      final week = s.last7DaysMinutes();
      expect(week.length, 7);
      expect(week.last, 30);
    });

    test('focusDistributionByTime buckets by hour-of-day', () async {
      final s = StatsProvider();
      await s.load();
      // morning (8am)
      await s.recordSession(
          make(start: DateTime(2026, 4, 18, 8), duration: 600));
      // afternoon (14)
      await s.recordSession(
          make(start: DateTime(2026, 4, 18, 14), duration: 1200));
      // evening (19)
      await s.recordSession(
          make(start: DateTime(2026, 4, 18, 19), duration: 300));
      // night (23)
      await s.recordSession(
          make(start: DateTime(2026, 4, 18, 23), duration: 900));
      final dist = s.focusDistributionByTime();
      expect(dist, [600, 1200, 300, 900]);
    });

    test('persists sessions across reload', () async {
      final s1 = StatsProvider();
      await s1.load();
      await s1.recordSession(make(start: DateTime.now(), duration: 1500));
      final s2 = StatsProvider();
      await s2.load();
      expect(s2.sessions.length, 1);
      expect(s2.totalFocusSeconds, 1500);
    });

    test('survives malformed JSON in storage', () async {
      SharedPreferences.setMockInitialValues({
        'stats.sessions': '###not-json###',
      });
      final s = StatsProvider();
      await s.load();
      expect(s.sessions, isEmpty);
      // Still functional after recovery.
      await s.recordSession(make(start: DateTime.now()));
      expect(s.sessions.length, 1);
    });

    test('skips sessions with invalid date strings', () async {
      SharedPreferences.setMockInitialValues({
        'stats.sessions':
            '[{"id":"a","taskId":null,"taskTitle":null,"intent":null,"startedAt":"not-a-date","endedAt":"also-not","durationSeconds":600,"completed":true}]',
      });
      final s = StatsProvider();
      await s.load();
      // The session is loaded with fallback DateTime.now() rather than crashing.
      expect(s.sessions.length, 1);
      expect(s.sessions.first.durationSeconds, 600);
    });
  });
}
