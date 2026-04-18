import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flow_pomodoro/models/session.dart';
import 'package:flow_pomodoro/services/in_memory_session_store.dart';
import 'package:flow_pomodoro/services/session_store.dart';
import 'package:flow_pomodoro/services/sqlite_session_store.dart';

FocusSession _make({
  String? id,
  DateTime? start,
  int duration = 1500,
  bool completed = true,
  String? title,
}) {
  final s = start ?? DateTime(2026, 4, 18, 10);
  return FocusSession(
    id: id ?? s.microsecondsSinceEpoch.toString(),
    taskId: null,
    taskTitle: title,
    intent: null,
    startedAt: s,
    endedAt: s.add(Duration(seconds: duration)),
    durationSeconds: duration,
    completed: completed,
  );
}

void _runStoreContract(String label, Future<SessionStore> Function() open) {
  group('$label contract', () {
    late SessionStore store;

    setUp(() async {
      store = await open();
    });

    tearDown(() async {
      await store.close();
    });

    test('insert + loadAll returns newest first', () async {
      await store.insert(
          _make(id: 'a', start: DateTime(2026, 4, 18, 9)));
      await store.insert(
          _make(id: 'b', start: DateTime(2026, 4, 18, 11)));
      await store.insert(
          _make(id: 'c', start: DateTime(2026, 4, 18, 10)));
      final loaded = await store.loadAll();
      expect(loaded.map((s) => s.id).toList(), ['b', 'c', 'a']);
    });

    test('insert is idempotent on the same id', () async {
      await store.insert(_make(id: 'x', title: 'first'));
      await store.insert(_make(id: 'x', title: 'second'));
      final loaded = await store.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.first.taskTitle, 'second');
    });

    test('deleteAll wipes the store', () async {
      await store.insert(_make(id: 'a'));
      await store.insert(_make(id: 'b'));
      await store.deleteAll();
      expect(await store.loadAll(), isEmpty);
    });

    test('init is safe to call twice', () async {
      await store.init();
      await store.init();
      expect(await store.loadAll(), isEmpty);
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  _runStoreContract('InMemorySessionStore', () async {
    final s = InMemorySessionStore();
    await s.init();
    return s;
  });

  _runStoreContract('SqliteSessionStore (in-memory)', () async {
    final s = SqliteSessionStore(
      databasePath: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    await s.init();
    return s;
  });

  group('SqliteSessionStore extras', () {
    test('round-trips all fields including booleans + ms precision',
        () async {
      final original = FocusSession(
        id: 'r1',
        taskId: 't42',
        taskTitle: 'Write report',
        intent: 'Finish draft',
        startedAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_123),
        endedAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_900_456),
        durationSeconds: 900,
        completed: false,
      );
      final store = SqliteSessionStore(
        databasePath: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      await store.init();
      await store.insert(original);
      final loaded = (await store.loadAll()).single;
      expect(loaded.id, 'r1');
      expect(loaded.taskId, 't42');
      expect(loaded.taskTitle, 'Write report');
      expect(loaded.intent, 'Finish draft');
      expect(loaded.startedAt.millisecondsSinceEpoch, 1_700_000_000_123);
      expect(loaded.endedAt.millisecondsSinceEpoch, 1_700_000_900_456);
      expect(loaded.durationSeconds, 900);
      expect(loaded.completed, false);
      await store.close();
    });

    test('persists across close + reopen with a real file', () async {
      final dir = await databaseFactoryFfi.getDatabasesPath();
      final path = '$dir/test_persist_${DateTime.now().microsecondsSinceEpoch}.db';
      await databaseFactoryFfi.deleteDatabase(path);

      final s1 = SqliteSessionStore(databasePath: path, factory: databaseFactoryFfi);
      await s1.init();
      await s1.insert(_make(id: 'persist-me'));
      await s1.close();

      final s2 = SqliteSessionStore(databasePath: path, factory: databaseFactoryFfi);
      await s2.init();
      final loaded = await s2.loadAll();
      expect(loaded.map((e) => e.id), contains('persist-me'));
      await s2.close();
      await databaseFactoryFfi.deleteDatabase(path);
    });
  });
}
