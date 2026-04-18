import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';
import 'session_store.dart';

/// Read-only [SessionStore] view over the legacy SharedPreferences storage
/// (`stats.sessions` JSON-array key) used in flow_pomodoro <= 0.0.5.
///
/// Used exactly once on startup to migrate prior session history into
/// SQLite, after which the legacy key is removed via [clearLegacyKey].
/// [insert] / [deleteAll] are not supported.
class LegacyPrefsSessionStore implements SessionStore {
  static const String legacyKey = 'stats.sessions';
  final List<FocusSession> _items = [];
  bool _initialized = false;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(legacyKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                _items.add(FocusSession.fromJson(item));
              } catch (e) {
                debugPrint('LegacyPrefsSessionStore: skipping corrupt: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('LegacyPrefsSessionStore: malformed JSON, ignored: $e');
      }
    }
    _initialized = true;
  }

  @override
  Future<List<FocusSession>> loadAll() async {
    if (!_initialized) {
      throw StateError('LegacyPrefsSessionStore.init() not called');
    }
    return List.unmodifiable(_items);
  }

  /// Removes the legacy SharedPreferences key. Call once after a successful
  /// migration so we don't migrate again on next launch.
  Future<void> clearLegacyKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(legacyKey);
  }

  @override
  Future<void> insert(FocusSession session) async {
    throw UnsupportedError('LegacyPrefsSessionStore is read-only');
  }

  @override
  Future<void> deleteAll() async {
    throw UnsupportedError('LegacyPrefsSessionStore is read-only');
  }

  @override
  Future<void> close() async {
    _items.clear();
    _initialized = false;
  }
}
