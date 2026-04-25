import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../services/notification_scheduler.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';
import 'task_provider.dart';

enum TimerPhase { idle, focus, shortBreak, longBreak }

enum TimerStatus { stopped, running, paused }

class TimerProvider extends ChangeNotifier {
  static const _kPhase = 'timer.phase';
  static const _kStatus = 'timer.status';
  static const _kTotalSeconds = 'timer.totalSeconds';
  static const _kRemainingSeconds = 'timer.remainingSeconds';
  static const _kCurrentRound = 'timer.currentRound';
  static const _kCurrentIntent = 'timer.currentIntent';
  static const _kPhaseStartedAt = 'timer.phaseStartedAt';
  static const _kLastSavedAt = 'timer.lastSavedAt';

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
  FocusSession? lastSessionSummary;

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

  Future<void> restorePersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhase = _phaseFromName(prefs.getString(_kPhase));
    final savedStatus = _statusFromName(prefs.getString(_kStatus));
    if (savedPhase == TimerPhase.idle || savedStatus == TimerStatus.stopped) {
      await _clearPersistedState();
      return;
    }

    phase = savedPhase;
    status = savedStatus;
    totalSeconds = prefs.getInt(_kTotalSeconds) ?? 0;
    remainingSeconds = prefs.getInt(_kRemainingSeconds) ?? 0;
    currentRound = prefs.getInt(_kCurrentRound) ?? 0;
    currentIntent = prefs.getString(_kCurrentIntent);
    _phaseStartedAt = _dateFromMillis(prefs.getInt(_kPhaseStartedAt));

    if (totalSeconds <= 0 || remainingSeconds <= 0) {
      await _clearPersistedState();
      _resetToIdle();
      notifyListeners();
      return;
    }

    if (status == TimerStatus.running) {
      final savedAt = _dateFromMillis(prefs.getInt(_kLastSavedAt));
      final elapsed = savedAt == null
          ? 0
          : DateTime.now().difference(savedAt).inSeconds.clamp(0, totalSeconds);
      remainingSeconds = (remainingSeconds - elapsed).clamp(0, totalSeconds);
      if (remainingSeconds <= 0) {
        await _onPhaseComplete();
        return;
      }
      _startTicker();
      _schedulePhaseComplete();
    }

    notifyListeners();
  }

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
    lastSessionSummary = null;
    currentIntent = intent;
    phase = TimerPhase.focus;
    totalSeconds = settings.focusMinutes * 60;
    remainingSeconds = totalSeconds;
    status = TimerStatus.running;
    _phaseStartedAt = DateTime.now();
    _startTicker();
    _schedulePhaseComplete();
    _persistState();
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
    _persistState();
    notifyListeners();
  }

  void pause() {
    if (status != TimerStatus.running) return;
    status = TimerStatus.paused;
    _ticker?.cancel();
    unawaited(notifications?.cancelPhaseComplete());
    _persistState();
    notifyListeners();
  }

  void resume() {
    if (status != TimerStatus.paused) return;
    status = TimerStatus.running;
    _startTicker();
    _schedulePhaseComplete();
    _persistState();
    notifyListeners();
  }

  void stop({bool record = true}) {
    _ticker?.cancel();
    unawaited(notifications?.cancelPhaseComplete());
    if (record && phase == TimerPhase.focus && _phaseStartedAt != null) {
      _recordSession(completed: false);
    }
    _resetToIdle();
    unawaited(_clearPersistedState());
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
        if (remainingSeconds % 15 == 0 || remainingSeconds <= 5) {
          _persistState();
        }
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
        _persistState();
        notifyListeners();
      }
    } else if (isBreak) {
      if (settings.autoSwitch) {
        // Return to idle; user starts next focus by pressing Start.
        _resetToIdle();
        unawaited(_clearPersistedState());
        notifyListeners();
      } else {
        status = TimerStatus.stopped;
        _persistState();
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

  FocusSession? _recordSession({required bool completed}) {
    final start = _phaseStartedAt ?? DateTime.now();
    final end = DateTime.now();
    final durSec = completed
        ? totalSeconds
        : end.difference(start).inSeconds.clamp(0, totalSeconds);
    if (durSec <= 0) return null;
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
    lastSessionSummary = session;
    return session;
  }

  void clearSessionSummary() {
    lastSessionSummary = null;
    notifyListeners();
  }

  void _resetToIdle() {
    phase = TimerPhase.idle;
    status = TimerStatus.stopped;
    totalSeconds = 0;
    remainingSeconds = 0;
    currentIntent = null;
    _phaseStartedAt = null;
  }

  void _persistState() {
    unawaited(_saveState());
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (phase == TimerPhase.idle) {
      await _clearPersistedState();
      return;
    }
    await prefs.setString(_kPhase, phase.name);
    await prefs.setString(_kStatus, status.name);
    await prefs.setInt(_kTotalSeconds, totalSeconds);
    await prefs.setInt(_kRemainingSeconds, remainingSeconds);
    await prefs.setInt(_kCurrentRound, currentRound);
    if (currentIntent == null) {
      await prefs.remove(_kCurrentIntent);
    } else {
      await prefs.setString(_kCurrentIntent, currentIntent!);
    }
    final startedAt = _phaseStartedAt;
    if (startedAt == null) {
      await prefs.remove(_kPhaseStartedAt);
    } else {
      await prefs.setInt(_kPhaseStartedAt, startedAt.millisecondsSinceEpoch);
    }
    await prefs.setInt(_kLastSavedAt, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_kPhase),
      prefs.remove(_kStatus),
      prefs.remove(_kTotalSeconds),
      prefs.remove(_kRemainingSeconds),
      prefs.remove(_kCurrentRound),
      prefs.remove(_kCurrentIntent),
      prefs.remove(_kPhaseStartedAt),
      prefs.remove(_kLastSavedAt),
    ]);
  }

  TimerPhase _phaseFromName(String? value) => TimerPhase.values.firstWhere(
        (phase) => phase.name == value,
        orElse: () => TimerPhase.idle,
      );

  TimerStatus _statusFromName(String? value) => TimerStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => TimerStatus.stopped,
      );

  DateTime? _dateFromMillis(int? millis) =>
      millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);

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
