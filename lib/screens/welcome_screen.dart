import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/flow_visual.dart';
import '../widgets/glass_panel.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _focus = 25;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'FLOW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 8,
                    color: accent.glow.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.appName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1.0,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.welcomeTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: FlowColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: FlowVisual(
                      style: settings.animationStyle,
                      size: 220,
                      isFocus: false,
                      isBreak: false,
                      flowStage: 'rest',
                      reduceMotion: settings.reduceMotion,
                      accentColor: accent.primary,
                      accentGlow: accent.glow,
                    ),
                  ),
                ),
                Text(
                  l.chooseFocusDuration,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    color: FlowColors.textMuted.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [15, 25, 45, 60].map((m) {
                      final selected = _focus == m;
                      return GestureDetector(
                        onTap: () => setState(() => _focus = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: selected
                                ? LinearGradient(colors: [
                                    accent.glow,
                                    accent.primary,
                                  ])
                                : null,
                            color: selected ? null : Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Text(
                            l.minutesShort(m),
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : FlowColors.textPrimary,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                GradientPillButton(
                  label: l.begin,
                  icon: Icons.arrow_forward_rounded,
                  color: accent.primary,
                  glow: accent.glow,
                  onPressed: () async {
                    await settings.setFocusMinutes(_focus);
                    await settings.setOnboarded(true);
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
