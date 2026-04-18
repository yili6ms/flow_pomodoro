import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/audio_controller.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/task_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  final tasks = TaskProvider();
  final stats = StatsProvider();
  await Future.wait([settings.load(), tasks.load(), stats.load()]);

  final timer = TimerProvider(settings: settings, tasks: tasks, stats: stats);

  // Owns the ambient white-noise loop. Listens to settings + timer; no
  // explicit lifecycle wiring needed beyond construction.
  // ignore: unused_local_variable
  final audio = AudioController(settings: settings, timer: timer);

  runApp(FlowPomodoroApp(
    settings: settings,
    tasks: tasks,
    stats: stats,
    timer: timer,
  ));
}

class FlowPomodoroApp extends StatelessWidget {
  final SettingsProvider settings;
  final TaskProvider tasks;
  final StatsProvider stats;
  final TimerProvider timer;

  const FlowPomodoroApp({
    super.key,
    required this.settings,
    required this.tasks,
    required this.stats,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: tasks),
        ChangeNotifierProvider.value(value: stats),
        ChangeNotifierProvider.value(value: timer),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, s, _) {
          return MaterialApp(
            title: 'Flow Pomodoro',
            debugShowCheckedModeBanner: false,
            themeMode: s.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: s.onboarded ? const HomeScreen() : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
