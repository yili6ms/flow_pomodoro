import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/glass_panel.dart';

/// Pre-focus screen: "What will you do in this session?"
class FocusIntentScreen extends StatefulWidget {
  const FocusIntentScreen({super.key});

  @override
  State<FocusIntentScreen> createState() => _FocusIntentScreenState();
}

class _FocusIntentScreenState extends State<FocusIntentScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final tasks = context.read<TaskProvider>();
    if (tasks.activeTask != null) {
      _controller.text = tasks.activeTask!.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _begin() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    Navigator.of(context).pop(txt);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  l.intentionEyebrow,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                    color: accent.glow.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.intentionPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 36),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                    cursorColor: accent.glow,
                    decoration: InputDecoration(
                      hintText: l.intentionHint,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _begin(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l.intentionFooter,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: FlowColors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                GradientPillButton(
                  label: l.enterTheFlow,
                  icon: Icons.east_rounded,
                  color: accent.primary,
                  glow: accent.glow,
                  onPressed: _begin,
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
