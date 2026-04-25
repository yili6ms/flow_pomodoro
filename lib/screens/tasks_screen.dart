import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(BuildContext context) async {
    final v = _controller.text.trim();
    if (v.isEmpty) return;
    await context.read<TaskProvider>().addTask(v);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.tasks),
        backgroundColor: Colors.transparent,
      ),
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: l.newTaskHint,
                        ),
                        onSubmitted: (_) => _add(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add_circle,
                          color: accent.primary, size: 36),
                      onPressed: () => _add(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasks.tasks.isEmpty
                    ? Center(
                        child: Text(
                          l.noTasksYet,
                          style: const TextStyle(color: FlowColors.textMuted),
                        ),
                      )
                    : ListView(
                        children: [
                          for (final t in tasks.activeTasks)
                            _TaskTile(
                              taskId: t.id,
                              title: t.title,
                              pomodoros: t.completedPomodoros,
                              selected: t.id == tasks.activeTaskId,
                              archived: false,
                            ),
                          if (tasks.archivedTasks.isNotEmpty) ...[
                            const Divider(height: 1, color: Colors.white10),
                            ExpansionTile(
                              title: Text(l.archivedTasks),
                              iconColor: FlowColors.textMuted,
                              collapsedIconColor: FlowColors.textMuted,
                              children: [
                                for (final t in tasks.archivedTasks)
                                  _TaskTile(
                                    taskId: t.id,
                                    title: t.title,
                                    pomodoros: t.completedPomodoros,
                                    selected: false,
                                    archived: true,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String taskId;
  final String title;
  final int pomodoros;
  final bool selected;
  final bool archived;

  const _TaskTile({
    required this.taskId,
    required this.title,
    required this.pomodoros,
    required this.selected,
    required this.archived,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = context.read<TaskProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(
        archived
            ? Icons.archive_outlined
            : selected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
        color: selected ? accent.primary : FlowColors.textMuted,
      ),
      title: Text(
        title,
        style: archived
            ? const TextStyle(
                color: FlowColors.textMuted,
                decoration: TextDecoration.lineThrough,
              )
            : null,
      ),
      subtitle: Text(
        l.pomodorosCount(pomodoros),
        style: const TextStyle(color: FlowColors.textMuted, fontSize: 12),
      ),
      onTap: archived ? null : () => tasks.setActive(taskId),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'archive':
              tasks.archiveTask(taskId);
            case 'unarchive':
              tasks.unarchiveTask(taskId);
            case 'delete':
              tasks.deleteTask(taskId);
          }
        },
        itemBuilder: (_) => [
          if (archived)
            PopupMenuItem(value: 'unarchive', child: Text(l.unarchiveTask))
          else
            PopupMenuItem(value: 'archive', child: Text(l.archiveTask)),
          PopupMenuItem(value: 'delete', child: Text(l.deleteTask)),
        ],
      ),
    );
  }
}
