import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/flow_visual.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

/// Animated brand intro shown when the Flutter engine boots, on top of (and
/// after) the native_splash static image.
///
/// Sequence (~2.0s total):
///   0.00–0.45s  Orb scales up + fades in from black
///   0.30–0.85s  Wordmark "FLOW" eyebrow + "Flow Pomodoro" title fade in
///   0.85–1.25s  Tagline fades in
///   1.55–2.00s  Whole stack fades out, then `Navigator.pushReplacement` to
///               the next screen.
///
/// Honors `settings.reduceMotion` by collapsing the timeline to a quick fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _orbScale;
  late final Animation<double> _orbOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    final reduce = context.read<SettingsProvider>().reduceMotion;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: reduce ? 700 : 2000),
    );

    Animation<double> band(double from, double to,
            {Curve curve = Curves.easeOut}) =>
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(from, to, curve: curve),
        );

    _orbScale = Tween(begin: 0.6, end: 1.0).animate(
      band(0.00, 0.55, curve: Curves.easeOutBack),
    );
    _orbOpacity = band(0.00, 0.35);
    _wordmarkOpacity = band(0.20, 0.55);
    _taglineOpacity = band(0.40, 0.70);
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(
      band(0.85, 1.00, curve: Curves.easeIn),
    );

    _ctrl.forward().whenComplete(_goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final next = settings.onboarded
        ? const HomeScreen()
        : const WelcomeScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: FlowColors.bgDark,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: AuroraBackground(
              accent: accent.primary,
              secondary: FlowColors.breakPrimary,
              reduceMotion: settings.reduceMotion,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Opacity(
                      opacity: _orbOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _orbScale.value,
                        child: FlowVisual(
                          style: settings.animationStyle,
                          size: 200,
                          isFocus: false,
                          isBreak: false,
                          flowStage: 'rest',
                          reduceMotion: settings.reduceMotion,
                          accentColor: accent.primary,
                          accentGlow: accent.glow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Opacity(
                      opacity: _wordmarkOpacity.value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            'FLOW',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 8,
                              fontWeight: FontWeight.w600,
                              color: accent.glow.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.appName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -0.6,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                      child: Text(
                        l.welcomeTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: FlowColors.textMuted.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
