class Task {
  final String id;
  String title;
  int completedPomodoros;
  bool archived;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.completedPomodoros = 0,
    this.archived = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completedPomodoros': completedPomodoros,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        completedPomodoros: (j['completedPomodoros'] ?? 0) as int,
        archived: (j['archived'] ?? false) as bool,
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}
