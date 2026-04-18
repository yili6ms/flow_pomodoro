import 'package:flutter/material.dart';
import '../models/flow_animation_style.dart';
import 'flow_fireworks.dart';
import 'flow_orb.dart';
import 'flow_particles.dart';
import 'flow_wave.dart';

/// Wrapper that renders the chosen animation style.
class FlowVisual extends StatelessWidget {
  final FlowAnimationStyle style;
  final double size;
  final bool isFocus;
  final bool isBreak;
  final bool reduceMotion;
  final String flowStage;
  final Color? accentColor;
  final Color? accentGlow;

  const FlowVisual({
    super.key,
    required this.style,
    required this.size,
    required this.isFocus,
    required this.isBreak,
    required this.flowStage,
    this.reduceMotion = false,
    this.accentColor,
    this.accentGlow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: KeyedSubtree(
        key: ValueKey(style),
        child: switch (style) {
          FlowAnimationStyle.orb => FlowOrb(
              size: size,
              isFocus: isFocus,
              isBreak: isBreak,
              flowStage: flowStage,
              reduceMotion: reduceMotion,
              accentColor: accentColor,
              accentGlow: accentGlow,
            ),
          FlowAnimationStyle.wave => FlowWave(
              size: size,
              isBreak: isBreak,
              flowStage: flowStage,
              reduceMotion: reduceMotion,
              accentColor: accentColor,
              accentGlow: accentGlow,
            ),
          FlowAnimationStyle.particles => FlowParticles(
              size: size,
              isBreak: isBreak,
              flowStage: flowStage,
              reduceMotion: reduceMotion,
              accentColor: accentColor,
              accentGlow: accentGlow,
            ),
          FlowAnimationStyle.fireworks => FlowFireworks(
              size: size,
              isBreak: isBreak,
              flowStage: flowStage,
              reduceMotion: reduceMotion,
              accentColor: accentColor,
              accentGlow: accentGlow,
            ),
        },
      ),
    );
  }
}
