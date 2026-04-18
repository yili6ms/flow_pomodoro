class FocusSession {
  final String id;
  final String? taskId;
  final String? taskTitle;
  final String? intent;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final bool completed;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.intent,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'intent': intent,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'completed': completed,
      };

  factory FocusSession.fromJson(Map<String, dynamic> j) => FocusSession(
        id: j['id'] as String,
        taskId: j['taskId'] as String?,
        taskTitle: j['taskTitle'] as String?,
        intent: j['intent'] as String?,
        startedAt: DateTime.tryParse(j['startedAt'] as String? ?? '') ??
            DateTime.now(),
        endedAt: DateTime.tryParse(j['endedAt'] as String? ?? '') ??
            DateTime.now(),
        durationSeconds: (j['durationSeconds'] ?? 0) as int,
        completed: (j['completed'] ?? false) as bool,
      );
}
