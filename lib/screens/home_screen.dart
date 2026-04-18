import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/flow_animation_style.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/flow_visual.dart';
import '../widgets/glass_panel.dart';
import 'focus_intent_screen.dart';
import 'focus_session_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final tasks = context.watch<TaskProvider>();
    final timer = context.watch<TimerProvider>();
    final accent = context.liveAccent();
    final l = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        accent: accent.primary,
        secondary: FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _Header(accent: accent.glow),
                const SizedBox(height: 8),
                Text(
                  l.homeQuote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: FlowColors.textMuted.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final styles = FlowAnimationStyle.values;
                        final next = styles[
                            (styles.indexOf(settings.animationStyle) + 1) %
                                styles.length];
                        settings.setAnimationStyle(next);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor:
                                FlowColors.bgDarkSoft.withValues(alpha: 0.92),
                            content: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(next.icon,
                                    size: 18, color: accent.primary),
                                const SizedBox(width: 10),
                                Text(l.animationChangedTo(
                                    next.localizedLabel(context))),
                              ],
                            ),
                          ));
                      },
                      child: FlowVisual(
                        style: settings.animationStyle,
                        size: 280,
                        isFocus: true,
                        isBreak: false,
                        flowStage: 'rest',
                        reduceMotion: settings.reduceMotion,
                        accentColor: accent.primary,
                        accentGlow: accent.glow,
                      ),
                    ),
                  ),
                ),
                _ActiveTaskCard(tasks: tasks, accent: accent.primary),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: l.labelFocus,
                        value: '${settings.focusMinutes}',
                        suffix: l.minShort,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        label: l.labelBreak,
                        value: '${settings.shortBreakMinutes}',
                        suffix: l.minShort,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        label: l.labelRound,
                        value: '${timer.currentRound + 1}',
                        suffix: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                GradientPillButton(
                  label: l.startFocus,
                  icon: Icons.play_arrow_rounded,
                  color: accent.primary,
                  glow: accent.glow,
                  onPressed: () => _onStart(context),
                ),
                const SizedBox(height: 8),
                if (timer.phase != TimerPhase.idle)
                  TextButton.icon(
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(l.resumeCurrentSession),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FocusSessionScreen(),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStart(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const FocusIntentScreen()),
    );
    if (result == null) return;
    if (!context.mounted) return;
    final timer = context.read<TimerProvider>();
    timer.startFocus(intent: result);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FocusSessionScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  final Color accent;
  const _Header({required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Text(
          'FLOW',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 6,
            fontWeight: FontWeight.w700,
            color: accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'POMODORO',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 4,
            color: FlowColors.textMuted.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        _IconChip(
          icon: Icons.checklist_rtl,
          tooltip: l.tasks,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TasksScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _IconChip(
          icon: Icons.bar_chart_rounded,
          tooltip: l.stats,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StatsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _IconChip(
          icon: Icons.settings_outlined,
          tooltip: l.settings,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconChip(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GlassPanel(
        onTap: onTap,
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(14),
        child: Icon(icon, size: 18, color: FlowColors.textPrimary),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final TaskProvider tasks;
  final Color accent;
  const _ActiveTaskCard({required this.tasks, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = tasks.activeTask;
    return GlassPanel(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TasksScreen()),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: Icon(Icons.flag_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t == null ? l.noActiveTask : l.active,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: FlowColors.textFaint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t?.title ?? l.tapToChoose,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          if (t != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.06),
              ),
              child: Text(
                '${t.completedPomodoros} 🍅',
                style: const TextStyle(
                    color: FlowColors.textMuted, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  const _StatTile({
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: FlowColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(
                      fontSize: 11,
                      color: FlowColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              color: FlowColors.textFaint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
