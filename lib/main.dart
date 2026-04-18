import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/audio_controller.dart';
import 'providers/hybrid_accent_ticker.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/task_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/session_store_init.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  final tasks = TaskProvider();
  final sessionStore = await initSessionStore();
  final stats = StatsProvider(store: sessionStore);
  await Future.wait([settings.load(), tasks.load(), stats.load()]);

  final timer = TimerProvider(settings: settings, tasks: tasks, stats: stats);

  // Owns the ambient white-noise loop. Listens to settings + timer; no
  // explicit lifecycle wiring needed beyond construction.
  // ignore: unused_local_variable
  final audio = AudioController(settings: settings, timer: timer);

  // Drives the rotating-hue color pair for the Hybrid accent. Idle until the
  // user selects AccentColor.hybrid.
  final hybridTicker = HybridAccentTicker();
  // ignore: unused_local_variable
  final hybridCtrl =
      HybridAccentController(settings: settings, ticker: hybridTicker);

  runApp(FlowPomodoroApp(
    settings: settings,
    tasks: tasks,
    stats: stats,
    timer: timer,
    hybridTicker: hybridTicker,
  ));
}

class FlowPomodoroApp extends StatelessWidget {
  final SettingsProvider settings;
  final TaskProvider tasks;
  final StatsProvider stats;
  final TimerProvider timer;
  final HybridAccentTicker hybridTicker;

  /// When true, skips the animated [SplashScreen] and shows the destination
  /// screen directly. Used by widget tests so they don't have to wait for
  /// the brand intro animation to play.
  final bool skipSplash;

  const FlowPomodoroApp({
    super.key,
    required this.settings,
    required this.tasks,
    required this.stats,
    required this.timer,
    required this.hybridTicker,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: tasks),
        ChangeNotifierProvider.value(value: stats),
        ChangeNotifierProvider.value(value: timer),
        ChangeNotifierProvider.value(value: hybridTicker),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, s, _) {
          return MaterialApp(
            title: 'Flow Pomodoro',
            debugShowCheckedModeBanner: false,
            themeMode: s.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            locale: s.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
            home: skipSplash
                ? (s.onboarded ? const HomeScreen() : const WelcomeScreen())
                : const SplashScreen(),
          );
        },
      ),
    );
  }
}
