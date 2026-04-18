import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'legacy_prefs_session_store.dart';
import 'session_store.dart';
import 'sqlite_session_store.dart';

/// Initializes the production [SessionStore] and migrates session history
/// from the legacy SharedPreferences blob (used in <= 0.0.5) into SQLite
/// the first time we see it.
///
/// On Android/iOS this uses the default sqflite plugin; on Windows/Linux
/// it switches to `sqflite_common_ffi`.
Future<SessionStore> initSessionStore() async {
  final factory = _platformFactory();
  final dbPath = await _resolveDatabasePath();
  final store = SqliteSessionStore(databasePath: dbPath, factory: factory);
  await store.init();

  await _migrateLegacyIfPresent(store);

  return store;
}

DatabaseFactory _platformFactory() {
  if (kIsWeb) {
    throw UnsupportedError('Web is not supported by the SQLite store');
  }
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }
  return sqflite.databaseFactory;
}

Future<String> _resolveDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'flow_pomodoro.db');
}

Future<void> _migrateLegacyIfPresent(SqliteSessionStore target) async {
  final legacy = LegacyPrefsSessionStore();
  try {
    await legacy.init();
    final items = await legacy.loadAll();
    if (items.isEmpty) {
      // Nothing to migrate; still clear the (possibly empty) key so we
      // don't re-enter this branch every launch.
      await legacy.clearLegacyKey();
      return;
    }
    debugPrint(
      'SessionStore: migrating ${items.length} legacy sessions to SQLite',
    );
    for (final s in items) {
      await target.insert(s);
    }
    await legacy.clearLegacyKey();
  } catch (e) {
    debugPrint('SessionStore: legacy migration failed (kept legacy data): $e');
  } finally {
    await legacy.close();
  }
}
