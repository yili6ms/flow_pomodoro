import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flow_pomodoro/main.dart';
import 'package:flow_pomodoro/providers/settings_provider.dart';
import 'package:flow_pomodoro/providers/stats_provider.dart';
import 'package:flow_pomodoro/providers/task_provider.dart';
import 'package:flow_pomodoro/providers/timer_provider.dart';
import 'package:flow_pomodoro/screens/focus_intent_screen.dart';
import 'package:flow_pomodoro/screens/home_screen.dart';
import 'package:flow_pomodoro/screens/welcome_screen.dart';

Future<FlowPomodoroApp> _buildApp({required bool onboarded}) async {
  SharedPreferences.setMockInitialValues({});
  final settings = SettingsProvider();
  final tasks = TaskProvider();
  final stats = StatsProvider();
  await settings.load();
  await tasks.load();
  await stats.load();
  if (onboarded) await settings.setOnboarded(true);
  await settings.setHaptics(false);
  final timer = TimerProvider(settings: settings, tasks: tasks, stats: stats);
  return FlowPomodoroApp(
    settings: settings,
    tasks: tasks,
    stats: stats,
    timer: timer,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows WelcomeScreen when not onboarded',
      (tester) async {
    final app = await _buildApp(onboarded: false);
    await tester.pumpWidget(app);
    await tester.pump();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Flow Pomodoro'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('shows HomeScreen when onboarded', (tester) async {
    final app = await _buildApp(onboarded: true);
    await tester.pumpWidget(app);
    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Start Focus'), findsOneWidget);
  });

  testWidgets('Welcome → Begin transitions to HomeScreen', (tester) async {
    final app = await _buildApp(onboarded: false);
    await tester.pumpWidget(app);
    await tester.pump();
    await tester.tap(find.text('Begin'));
    // FlowOrb has perpetual animations, so pumpAndSettle would hang.
    // Pump enough frames for the route transition to complete.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Start Focus opens FocusIntentScreen', (tester) async {
    final app = await _buildApp(onboarded: true);
    await tester.pumpWidget(app);
    await tester.pump();
    await tester.tap(find.text('Start Focus'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FocusIntentScreen), findsOneWidget);
    expect(find.text('Enter the flow'), findsOneWidget);
  });

  testWidgets('Adding a task via TaskProvider reflects on Home banner',
      (tester) async {
    final app = await _buildApp(onboarded: true);
    await tester.pumpWidget(app);
    await tester.pump();

    final ctx = tester.element(find.byType(HomeScreen));
    await ctx.read<TaskProvider>().addTask('My focus task');
    await tester.pump();

    expect(find.text('My focus task'), findsOneWidget);
  });
}
