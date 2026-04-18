import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/session.dart';
import 'session_store.dart';

/// SQLite-backed [SessionStore].
///
/// Schema (v1):
///   sessions(
///     id TEXT PRIMARY KEY,
///     task_id TEXT,
///     task_title TEXT,
///     intent TEXT,
///     started_at_ms INTEGER NOT NULL,
///     ended_at_ms INTEGER NOT NULL,
///     duration_seconds INTEGER NOT NULL,
///     completed INTEGER NOT NULL
///   )
///   INDEX idx_sessions_started_at ON sessions(started_at_ms DESC)
class SqliteSessionStore implements SessionStore {
  static const _kDbVersion = 1;
  static const _kTable = 'sessions';

  final String databasePath;
  final DatabaseFactory factory;

  Database? _db;

  SqliteSessionStore({
    required this.databasePath,
    required this.factory,
  });

  @override
  Future<void> init() async {
    if (_db != null) return;
    _db = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _kDbVersion,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_kTable (
              id TEXT PRIMARY KEY,
              task_id TEXT,
              task_title TEXT,
              intent TEXT,
              started_at_ms INTEGER NOT NULL,
              ended_at_ms INTEGER NOT NULL,
              duration_seconds INTEGER NOT NULL,
              completed INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_sessions_started_at '
            'ON $_kTable(started_at_ms DESC)',
          );
        },
      ),
    );
  }

  @override
  Future<List<FocusSession>> loadAll() async {
    final db = _requireDb();
    final rows = await db.query(_kTable, orderBy: 'started_at_ms DESC');
    final out = <FocusSession>[];
    for (final r in rows) {
      try {
        out.add(_fromRow(r));
      } catch (e) {
        debugPrint('SqliteSessionStore: skipping corrupt row: $e');
      }
    }
    return out;
  }

  @override
  Future<void> insert(FocusSession session) async {
    final db = _requireDb();
    await db.insert(
      _kTable,
      _toRow(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAll() async {
    final db = _requireDb();
    await db.delete(_kTable);
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Database _requireDb() {
    final db = _db;
    if (db == null) {
      throw StateError('SqliteSessionStore.init() not called');
    }
    return db;
  }

  static Map<String, Object?> _toRow(FocusSession s) => {
        'id': s.id,
        'task_id': s.taskId,
        'task_title': s.taskTitle,
        'intent': s.intent,
        'started_at_ms': s.startedAt.millisecondsSinceEpoch,
        'ended_at_ms': s.endedAt.millisecondsSinceEpoch,
        'duration_seconds': s.durationSeconds,
        'completed': s.completed ? 1 : 0,
      };

  static FocusSession _fromRow(Map<String, Object?> r) => FocusSession(
        id: r['id'] as String,
        taskId: r['task_id'] as String?,
        taskTitle: r['task_title'] as String?,
        intent: r['intent'] as String?,
        startedAt:
            DateTime.fromMillisecondsSinceEpoch((r['started_at_ms'] as int)),
        endedAt:
            DateTime.fromMillisecondsSinceEpoch((r['ended_at_ms'] as int)),
        durationSeconds: (r['duration_seconds'] as int),
        completed: (r['completed'] as int) != 0,
      );
}
