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
                child: tasks.activeTasks.isEmpty
                    ? Center(
                        child: Text(l.noTasksYet,
                            style: const TextStyle(color: FlowColors.textMuted)),
                      )
                    : ListView.separated(
                        itemCount: tasks.activeTasks.length,
                        separatorBuilder: (_, _) => const Divider(
                            height: 1, color: Colors.white10),
                        itemBuilder: (_, i) {
                          final t = tasks.activeTasks[i];
                          final selected = t.id == tasks.activeTaskId;
                          return ListTile(
                            leading: Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? accent.primary
                                  : FlowColors.textMuted,
                            ),
                            title: Text(t.title),
                            subtitle: Text(
                                l.pomodorosCount(t.completedPomodoros),
                                style: const TextStyle(
                                    color: FlowColors.textMuted,
                                    fontSize: 12)),
                            onTap: () => tasks.setActive(t.id),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: FlowColors.textMuted),
                              onPressed: () => tasks.deleteTask(t.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
