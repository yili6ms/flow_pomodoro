import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  static const _kTasks = 'tasks.list';
  static const _kActive = 'tasks.activeId';

  final List<Task> _tasks = [];
  String? _activeTaskId;
  late SharedPreferences _prefs;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get activeTasks =>
      _tasks.where((t) => !t.archived).toList(growable: false);
  List<Task> get archivedTasks =>
      _tasks.where((t) => t.archived).toList(growable: false);
  String? get activeTaskId => _activeTaskId;
  Task? get activeTask {
    if (_activeTaskId == null) return null;
    for (final t in _tasks) {
      if (t.id == _activeTaskId) return t;
    }
    return null;
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_kTasks);
    _tasks.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                _tasks.add(Task.fromJson(item));
              } catch (e) {
                debugPrint('TaskProvider: skipping corrupt task: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('TaskProvider: failed to decode tasks, resetting: $e');
        await _prefs.remove(_kTasks);
      }
    }
    _activeTaskId = _prefs.getString(_kActive);
    // Drop active id pointing to a task that no longer exists.
    if (_activeTaskId != null &&
        !_tasks.any((t) => t.id == _activeTaskId)) {
      _activeTaskId = null;
      await _prefs.remove(_kActive);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final raw = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_kTasks, raw);
    if (_activeTaskId == null) {
      await _prefs.remove(_kActive);
    } else {
      await _prefs.setString(_kActive, _activeTaskId!);
    }
  }

  Future<Task> addTask(String title) async {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    _tasks.insert(0, task);
    _activeTaskId ??= task.id;
    await _save();
    notifyListeners();
    return task;
  }

  Future<void> setActive(String? id) async {
    _activeTaskId = id;
    await _save();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    if (_activeTaskId == id) _activeTaskId = null;
    await _save();
    notifyListeners();
  }

  Future<void> archiveTask(String id) async {
    for (final t in _tasks) {
      if (t.id == id) {
        t.archived = true;
        break;
      }
    }
    if (_activeTaskId == id) _activeTaskId = null;
    await _save();
    notifyListeners();
  }

  Future<void> unarchiveTask(String id) async {
    for (final t in _tasks) {
      if (t.id == id) {
        t.archived = false;
        break;
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> incrementPomodoro(String id) async {
    for (final t in _tasks) {
      if (t.id == id) {
        t.completedPomodoros += 1;
        break;
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> renameTask(String id, String newTitle) async {
    for (final t in _tasks) {
      if (t.id == id) {
        t.title = newTitle.trim();
        break;
      }
    }
    await _save();
    notifyListeners();
  }
}
