import 'package:flutter_test/flutter_test.dart';
import 'package:flow_pomodoro/models/session.dart';
import 'package:flow_pomodoro/models/task.dart';

void main() {
  group('Task model', () {
    test('toJson/fromJson roundtrip', () {
      final t = Task(id: '1', title: 'Write report', completedPomodoros: 3);
      final t2 = Task.fromJson(t.toJson());
      expect(t2.id, '1');
      expect(t2.title, 'Write report');
      expect(t2.completedPomodoros, 3);
      expect(t2.archived, false);
      expect(t2.createdAt.isAtSameMomentAs(t.createdAt), true);
    });

    test('defaults', () {
      final t = Task(id: 'x', title: 'a');
      expect(t.completedPomodoros, 0);
      expect(t.archived, false);
    });
  });

  group('FocusSession model', () {
    test('toJson/fromJson roundtrip', () {
      final start = DateTime(2026, 4, 18, 10, 0);
      final end = DateTime(2026, 4, 18, 10, 25);
      final s = FocusSession(
        id: 's1',
        taskId: 't1',
        taskTitle: 'Task',
        intent: 'Outline',
        startedAt: start,
        endedAt: end,
        durationSeconds: 1500,
        completed: true,
      );
      final s2 = FocusSession.fromJson(s.toJson());
      expect(s2.id, 's1');
      expect(s2.taskId, 't1');
      expect(s2.taskTitle, 'Task');
      expect(s2.intent, 'Outline');
      expect(s2.startedAt, start);
      expect(s2.endedAt, end);
      expect(s2.durationSeconds, 1500);
      expect(s2.completed, true);
    });

    test('handles null task fields', () {
      final s = FocusSession(
        id: 's',
        taskId: null,
        taskTitle: null,
        intent: null,
        startedAt: DateTime(2026),
        endedAt: DateTime(2026),
        durationSeconds: 0,
        completed: false,
      );
      final s2 = FocusSession.fromJson(s.toJson());
      expect(s2.taskId, null);
      expect(s2.taskTitle, null);
      expect(s2.intent, null);
    });
  });
}
