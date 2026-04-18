import 'package:flutter/foundation.dart';

import '../models/session.dart';
import '../services/session_store.dart';

/// Front-loads the entire session history from a [SessionStore] into an
/// in-memory list and exposes the aggregations the UI needs. Recording a
/// new session writes-through to the store so the cache and disk stay in
/// sync.
class StatsProvider extends ChangeNotifier {
  final SessionStore store;
  final List<FocusSession> _sessions = [];

  StatsProvider({required this.store});

  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  Future<void> load() async {
    await store.init();
    final loaded = await store.loadAll();
    _sessions
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> recordSession(FocusSession session) async {
    await store.insert(session);
    _sessions.insert(0, session);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await store.deleteAll();
    _sessions.clear();
    notifyListeners();
  }

  // ---- Aggregations ----

  /// Number of focus sessions that ran to completion ("pomodoros").
  int get totalCompletedSessions =>
      _sessions.where((s) => s.completed).length;

  /// Total focused seconds across **all** recorded sessions, including
  /// sessions that were ended early. Mirrors how most pomodoro apps credit
  /// time spent focusing even when the round wasn't finished.
  int get totalFocusSeconds =>
      _sessions.fold(0, (sum, s) => sum + s.durationSeconds);

  int focusSecondsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _sessions
        .where((s) =>
            s.startedAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            s.startedAt.isBefore(end))
        .fold(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Returns last 7 days [oldest..today] of focus minutes.
  List<int> last7DaysMinutes() {
    final today = DateTime.now();
    final out = <int>[];
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      out.add((focusSecondsForDay(d) / 60).round());
    }
    return out;
  }

  /// Distribution of focus seconds across 4 buckets:
  /// morning(5-12), afternoon(12-17), evening(17-22), night(22-5).
  List<int> focusDistributionByTime() {
    final buckets = [0, 0, 0, 0];
    for (final s in _sessions) {
      final h = s.startedAt.hour;
      if (h >= 5 && h < 12) {
        buckets[0] += s.durationSeconds;
      } else if (h >= 12 && h < 17) {
        buckets[1] += s.durationSeconds;
      } else if (h >= 17 && h < 22) {
        buckets[2] += s.durationSeconds;
      } else {
        buckets[3] += s.durationSeconds;
      }
    }
    return buckets;
  }

  /// Most recent sessions, newest first.
  List<FocusSession> recentSessions({int limit = 5}) =>
      _sessions.take(limit).toList(growable: false);
}
