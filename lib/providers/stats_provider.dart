import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class StatsProvider extends ChangeNotifier {
  static const _kSessions = 'stats.sessions';
  final List<FocusSession> _sessions = [];
  late SharedPreferences _prefs;

  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_kSessions);
    _sessions.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                _sessions.add(FocusSession.fromJson(item));
              } catch (e) {
                debugPrint('StatsProvider: skipping corrupt session: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('StatsProvider: failed to decode sessions, resetting: $e');
        await _prefs.remove(_kSessions);
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final raw = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_kSessions, raw);
  }

  Future<void> recordSession(FocusSession session) async {
    _sessions.insert(0, session);
    // Keep last 1000 sessions to bound storage.
    if (_sessions.length > 1000) {
      _sessions.removeRange(1000, _sessions.length);
    }
    await _save();
    notifyListeners();
  }

  // ---- Aggregations ----

  int get totalCompletedSessions =>
      _sessions.where((s) => s.completed).length;

  int get totalFocusSeconds => _sessions
      .where((s) => s.completed)
      .fold(0, (sum, s) => sum + s.durationSeconds);

  int focusSecondsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _sessions
        .where((s) =>
            s.completed &&
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
    for (final s in _sessions.where((s) => s.completed)) {
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
}
