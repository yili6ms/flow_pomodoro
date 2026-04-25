import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/session.dart';
import '../services/notification_scheduler.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';
import 'task_provider.dart';

enum TimerPhase { idle, focus, shortBreak, longBreak }

enum TimerStatus { stopped, running, paused }

class TimerProvider extends ChangeNotifier {
  final SettingsProvider settings;
  final TaskProvider tasks;
  final StatsProvider stats;
  final NotificationScheduler? notifications;

  TimerProvider({
    required this.settings,
    required this.tasks,
    required this.stats,
    this.notifications,
  });

  TimerPhase phase = TimerPhase.idle;
  TimerStatus status = TimerStatus.stopped;
  int totalSeconds = 0;
  int remainingSeconds = 0;
  int currentRound = 0; // completed focus rounds in current cycle
  String? currentIntent;
  DateTime? _phaseStartedAt;

  Timer? _ticker;

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  bool get isFocus => phase == TimerPhase.focus;
  bool get isBreak =>
      phase == TimerPhase.shortBreak || phase == TimerPhase.longBreak;

  /// Elapsed seconds within this phase.
  int get elapsedSeconds => totalSeconds - remainingSeconds;

  String get phaseLabel => switch (phase) {
        TimerPhase.idle => 'Ready',
        TimerPhase.focus => 'Focus',
        TimerPhase.shortBreak => 'Short Break',
        TimerPhase.longBreak => 'Long Break',
      };

  /// Flow state phase (per design doc):
  /// pre-focus, initiation (0-3m), stabilization (3-15m), deep flow (15+), exit.
  String get flowStage {
    if (phase != TimerPhase.focus) return 'rest';
    final mins = elapsedSeconds / 60.0;
    if (mins < 3) return 'initiation';
    if (mins < 15) return 'stabilization';
    return 'deep';
  }

  void startFocus({required String intent}) {
    currentIntent = intent;
    phase = TimerPhase.focus;
    totalSeconds = settings.focusMinutes * 60;
    remainingSeconds = totalSeconds;
    status = TimerStatus.running;
    _phaseStartedAt = DateTime.now();
    _startTicker();
    _schedulePhaseComplete();
    _haptic(HapticFeedback.lightImpact);
    notifyListeners();
  }

  void startBreak({bool long = false}) {
    phase = long ? TimerPhase.longBreak : TimerPhase.shortBreak;
    totalSeconds =
        (long ? settings.longBreakMinutes : settings.shortBreakMinutes) * 60;
    remainingSeconds = totalSeconds;
    status = TimerStatus.running;
    _phaseStartedAt = DateTime.now();
    _startTicker();
    _schedulePhaseComplete();
    notifyListeners();
  }

  void pause() {
    if (status != TimerStatus.running) return;
    status = TimerStatus.paused;
    _ticker?.cancel();
    unawaited(notifications?.cancelPhaseComplete());
    notifyListeners();
  }

  void resume() {
    if (status != TimerStatus.paused) return;
    status = TimerStatus.running;
    _startTicker();
    _schedulePhaseComplete();
    notifyListeners();
  }

  void stop({bool record = true}) {
    _ticker?.cancel();
    unawaited(notifications?.cancelPhaseComplete());
    if (record && phase == TimerPhase.focus && _phaseStartedAt != null) {
      _recordSession(completed: false);
    }
    phase = TimerPhase.idle;
    status = TimerStatus.stopped;
    totalSeconds = 0;
    remainingSeconds = 0;
    currentIntent = null;
    _phaseStartedAt = null;
    notifyListeners();
  }

  void resetCycle() {
    stop(record: false);
    currentRound = 0;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        _onPhaseComplete();
      }
    });
  }

  Future<void> _onPhaseComplete() async {
    _ticker?.cancel();
    await notifications?.cancelPhaseComplete();
    _haptic(HapticFeedback.mediumImpact);
    if (phase == TimerPhase.focus) {
      _recordSession(completed: true);
      currentRound += 1;
      if (tasks.activeTaskId != null) {
        await tasks.incrementPomodoro(tasks.activeTaskId!);
      }
      final useLong = currentRound % settings.roundsBeforeLongBreak == 0;
      if (settings.autoSwitch) {
        startBreak(long: useLong);
      } else {
        phase = useLong ? TimerPhase.longBreak : TimerPhase.shortBreak;
        totalSeconds =
            (useLong ? settings.longBreakMinutes : settings.shortBreakMinutes) *
                60;
        remainingSeconds = totalSeconds;
        status = TimerStatus.stopped;
        notifyListeners();
      }
    } else if (isBreak) {
      if (settings.autoSwitch) {
        // Return to idle; user starts next focus by pressing Start.
        phase = TimerPhase.idle;
        status = TimerStatus.stopped;
        totalSeconds = 0;
        remainingSeconds = 0;
        notifyListeners();
      } else {
        status = TimerStatus.stopped;
        notifyListeners();
      }
    }
  }

  void _schedulePhaseComplete() {
    if (status != TimerStatus.running || phase == TimerPhase.idle) return;
    final scheduler = notifications;
    if (scheduler == null) return;
    unawaited(scheduler.schedulePhaseComplete(
      phase: switch (phase) {
        TimerPhase.focus => NotificationPhase.focus,
        TimerPhase.shortBreak => NotificationPhase.shortBreak,
        TimerPhase.longBreak => NotificationPhase.longBreak,
        TimerPhase.idle => NotificationPhase.idle,
      },
      remaining: Duration(seconds: remainingSeconds),
    ));
  }

  void _recordSession({required bool completed}) {
    final start = _phaseStartedAt ?? DateTime.now();
    final end = DateTime.now();
    final durSec = completed
        ? totalSeconds
        : end.difference(start).inSeconds.clamp(0, totalSeconds);
    if (durSec <= 0) return;
    final session = FocusSession(
      id: end.microsecondsSinceEpoch.toString(),
      taskId: tasks.activeTaskId,
      taskTitle: tasks.activeTask?.title,
      intent: currentIntent,
      startedAt: start,
      endedAt: end,
      durationSeconds: durSec,
      completed: completed,
    );
    stats.recordSession(session);
  }

  void _haptic(Future<void> Function() fn) {
    if (settings.haptics) {
      // Hardware may not exist (Windows). Errors are swallowed by platform.
      fn();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
