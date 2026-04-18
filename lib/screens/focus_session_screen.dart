import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/flow_animation_style.dart';
import '../models/white_noise.dart';
import '../providers/hybrid_accent_ticker.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/flow_entry_overlay.dart';
import '../widgets/flow_ring.dart';
import '../widgets/flow_visual.dart';

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  bool _showEntry = true;

  @override
  void initState() {
    super.initState();
    final timer = context.read<TimerProvider>();
    // Skip entry overlay if we resumed an in-progress session.
    if (timer.phase != TimerPhase.focus || timer.elapsedSeconds > 3) {
      _showEntry = false;
    }
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  /// True only when there's a session in progress that the user could
  /// abandon by leaving the screen.
  bool _isInProgress(TimerProvider timer) =>
      timer.phase != TimerPhase.idle &&
      !(timer.status == TimerStatus.stopped && timer.isBreak);

  /// Show "End focus session?" dialog. Returns true if user confirmed.
  Future<bool> _confirmLeave(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: FlowColors.bgDarkSoft,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(l.endSessionTitle),
        content: Text(
          l.endSessionBody,
          style: const TextStyle(color: FlowColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.stayFocused),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: FlowColors.focusPrimary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.endSession),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Stop the timer and pop the screen if confirmed.
  Future<void> _attemptLeave(BuildContext context) async {
    final timer = context.read<TimerProvider>();
    if (!_isInProgress(timer)) {
      timer.stop();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      return;
    }
    final confirmed = await _confirmLeave(context);
    if (!confirmed) return;
    if (!context.mounted) return;
    timer.stop();
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final settings = context.watch<SettingsProvider>();
    final tasks = context.watch<TaskProvider>();

    final isBreak = timer.isBreak;
    final accent = context.liveAccent();
    final color = isBreak ? FlowColors.breakPrimary : accent.primary;
    final l = AppLocalizations.of(context);

    // UI fades as focus deepens (per design spec)
    double uiOpacity = 1.0;
    if (timer.flowStage == 'stabilization') uiOpacity = 0.85;
    if (timer.flowStage == 'deep') uiOpacity = 0.55;

    final inProgress = _isInProgress(timer);

    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await _confirmLeave(context);
        if (!confirmed) return;
        if (!context.mounted) return;
        context.read<TimerProvider>().stop();
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
      child: Scaffold(
      backgroundColor: FlowColors.bgDark,
      body: AuroraBackground(
        accent: isBreak ? FlowColors.breakPrimary : accent.primary,
        secondary: isBreak ? accent.primary : FlowColors.breakPrimary,
        reduceMotion: settings.reduceMotion,
        child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: uiOpacity,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: FlowColors.textMuted),
                          onPressed: () => _attemptLeave(context),
                        ),
                        const Spacer(),
                        Text(
                          localizedPhaseLabel(context, timer.phase),
                          style: const TextStyle(
                              fontSize: 14,
                              color: FlowColors.textMuted,
                              letterSpacing: 1.2),
                        ),
                        const Spacer(),
                        PopupMenuButton<FlowAnimationStyle>(
                          tooltip: l.animationStyleTooltip,
                          icon: Icon(settings.animationStyle.icon,
                              color: FlowColors.textMuted),
                          onSelected: settings.setAnimationStyle,
                          itemBuilder: (_) => FlowAnimationStyle.values
                              .map((style) => PopupMenuItem(
                                    value: style,
                                    child: Row(
                                      children: [
                                        Icon(style.icon, size: 18),
                                        const SizedBox(width: 10),
                                        Text(style.localizedLabel(context)),
                                        if (settings.animationStyle ==
                                            style) ...[
                                          const Spacer(),
                                          const Icon(Icons.check, size: 16),
                                        ],
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        PopupMenuButton<WhiteNoise>(
                          tooltip: l.whiteNoiseTooltip,
                          icon: Icon(settings.whiteNoise.icon,
                              color: FlowColors.textMuted),
                          onSelected: settings.setWhiteNoise,
                          itemBuilder: (_) => WhiteNoise.values
                              .map((n) => PopupMenuItem(
                                    value: n,
                                    child: Row(
                                      children: [
                                        Icon(n.icon, size: 18),
                                        const SizedBox(width: 10),
                                        Text(n.localizedLabel(context)),
                                        if (settings.whiteNoise == n) ...[
                                          const Spacer(),
                                          const Icon(Icons.check, size: 16),
                                        ],
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop_circle_outlined,
                              color: FlowColors.textMuted),
                          onPressed: () => _attemptLeave(context),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FlowVisual(
                          style: settings.animationStyle,
                          size: 260,
                          isFocus: timer.isFocus,
                          isBreak: isBreak,
                          flowStage: timer.flowStage,
                          reduceMotion: settings.reduceMotion,
                          accentColor: accent.primary,
                          accentGlow: accent.glow,
                        ),
                        FlowRing(
                          size: 320,
                          progress: timer.progress,
                          color: color,
                          strokeWidth: 6,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _fmt(timer.remainingSeconds),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 800),
                              opacity: uiOpacity,
                              child: Text(
                                timer.currentIntent ??
                                    tasks.activeTask?.title ??
                                    '',
                                style: const TextStyle(
                                    color: FlowColors.textMuted, fontSize: 14),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 800),
                              opacity: uiOpacity,
                              child: Text(
                                l.roundN(timer.currentRound +
                                    (timer.isFocus ? 1 : 0)),
                                style: const TextStyle(
                                    color: FlowColors.textMuted, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: uiOpacity,
                    child: _Controls(
                      timer: timer,
                      onEnd: () => _attemptLeave(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          if (_showEntry)
            FlowEntryOverlay(
              guidance: l.enterTheFlow,
              reduceMotion: settings.reduceMotion,
              style: settings.animationStyle,
              accentColor: accent.primary,
              accentGlow: accent.glow,
              onComplete: () => setState(() => _showEntry = false),
            ),
        ],
      ),
      ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TimerProvider timer;
  final VoidCallback onEnd;
  const _Controls({required this.timer, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (timer.phase == TimerPhase.idle) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l.done),
      );
    }

    if (timer.status == TimerStatus.stopped && timer.isBreak) {
      return ElevatedButton(
        onPressed: () => timer.startBreak(
            long: timer.phase == TimerPhase.longBreak),
        child: Text(l.startBreak),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timer.status == TimerStatus.running)
          ElevatedButton(
            onPressed: timer.pause,
            child: Text(l.pause),
          )
        else
          ElevatedButton(
            onPressed: timer.resume,
            child: Text(l.resume),
          ),
        const SizedBox(width: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: FlowColors.textPrimary,
            side: const BorderSide(color: FlowColors.textMuted),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40)),
          ),
          onPressed: onEnd,
          child: Text(l.endLabel),
        ),
      ],
    );
  }
}
