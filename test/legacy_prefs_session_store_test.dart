import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flow_pomodoro/services/legacy_prefs_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns empty when key missing', () async {
    final store = LegacyPrefsSessionStore();
    await store.init();
    expect(await store.loadAll(), isEmpty);
  });

  test('reads valid sessions from legacy JSON', () async {
    SharedPreferences.setMockInitialValues({
      'stats.sessions':
          '[{"id":"a","taskId":null,"taskTitle":"T","intent":null,"startedAt":"2026-04-18T10:00:00.000","endedAt":"2026-04-18T10:25:00.000","durationSeconds":1500,"completed":true}]',
    });
    final store = LegacyPrefsSessionStore();
    await store.init();
    final out = await store.loadAll();
    expect(out, hasLength(1));
    expect(out.first.id, 'a');
    expect(out.first.taskTitle, 'T');
    expect(out.first.durationSeconds, 1500);
  });

  test('survives malformed JSON', () async {
    SharedPreferences.setMockInitialValues({
      'stats.sessions': '###not-json###',
    });
    final store = LegacyPrefsSessionStore();
    await store.init();
    expect(await store.loadAll(), isEmpty);
  });

  test('skips non-map items but keeps the rest', () async {
    SharedPreferences.setMockInitialValues({
      'stats.sessions':
          '[42,{"id":"good","taskId":null,"taskTitle":null,"intent":null,"startedAt":"2026-04-18T10:00:00.000","endedAt":"2026-04-18T10:25:00.000","durationSeconds":600,"completed":true}]',
    });
    final store = LegacyPrefsSessionStore();
    await store.init();
    final out = await store.loadAll();
    expect(out, hasLength(1));
    expect(out.first.id, 'good');
  });

  test('clearLegacyKey removes the SharedPreferences entry', () async {
    SharedPreferences.setMockInitialValues({
      'stats.sessions':
          '[{"id":"a","taskId":null,"taskTitle":null,"intent":null,"startedAt":"2026-04-18T10:00:00.000","endedAt":"2026-04-18T10:25:00.000","durationSeconds":600,"completed":true}]',
    });
    final store = LegacyPrefsSessionStore();
    await store.init();
    await store.clearLegacyKey();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('stats.sessions'), isNull);
  });

  test('insert and deleteAll are unsupported (read-only)', () async {
    final store = LegacyPrefsSessionStore();
    await store.init();
    expect(() => store.deleteAll(), throwsUnsupportedError);
  });
}
