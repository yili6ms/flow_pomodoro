import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/white_noise.dart';
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

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final settings = context.watch<SettingsProvider>();
    final tasks = context.watch<TaskProvider>();

    final isBreak = timer.isBreak;
    final accent = settings.accentColor;
    final color = isBreak ? FlowColors.breakPrimary : accent.primary;

    // UI fades as focus deepens (per design spec)
    double uiOpacity = 1.0;
    if (timer.flowStage == 'stabilization') uiOpacity = 0.85;
    if (timer.flowStage == 'deep') uiOpacity = 0.55;

    return Scaffold(
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          timer.phaseLabel,
                          style: const TextStyle(
                              fontSize: 14,
                              color: FlowColors.textMuted,
                              letterSpacing: 1.2),
                        ),
                        const Spacer(),
                        PopupMenuButton<WhiteNoise>(
                          tooltip: 'White noise',
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
                                        Text(n.label),
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
                          onPressed: () {
                            timer.stop();
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
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
                                'Round ${timer.currentRound + (timer.isFocus ? 1 : 0)}',
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
                    child: _Controls(timer: timer),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          if (_showEntry)
            FlowEntryOverlay(
              guidance: 'Enter the flow',
              reduceMotion: settings.reduceMotion,
              onComplete: () => setState(() => _showEntry = false),
            ),
        ],
      ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final TimerProvider timer;
  const _Controls({required this.timer});

  @override
  Widget build(BuildContext context) {
    if (timer.phase == TimerPhase.idle) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Done'),
      );
    }

    if (timer.status == TimerStatus.stopped && timer.isBreak) {
      return ElevatedButton(
        onPressed: () => timer.startBreak(
            long: timer.phase == TimerPhase.longBreak),
        child: const Text('Start break'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timer.status == TimerStatus.running)
          ElevatedButton(
            onPressed: timer.pause,
            child: const Text('Pause'),
          )
        else
          ElevatedButton(
            onPressed: timer.resume,
            child: const Text('Resume'),
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
          onPressed: () {
            timer.stop();
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
          child: const Text('End'),
        ),
      ],
    );
  }
}
