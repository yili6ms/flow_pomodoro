import 'package:flutter/material.dart';

/// Visual style options for the central focus animation.
enum FlowAnimationStyle {
  orb,
  wave,
  particles,
  fireworks;

  String get label => switch (this) {
        FlowAnimationStyle.orb => 'Orb',
        FlowAnimationStyle.wave => 'Wave',
        FlowAnimationStyle.particles => 'Particles',
        FlowAnimationStyle.fireworks => 'Fireworks',
      };

  String get id => switch (this) {
        FlowAnimationStyle.orb => 'orb',
        FlowAnimationStyle.wave => 'wave',
        FlowAnimationStyle.particles => 'particles',
        FlowAnimationStyle.fireworks => 'fireworks',
      };

  /// Material icon used in pickers and quick-switchers.
  IconData get icon => switch (this) {
        FlowAnimationStyle.orb => Icons.blur_circular_rounded,
        FlowAnimationStyle.wave => Icons.waves_rounded,
        FlowAnimationStyle.particles => Icons.scatter_plot_rounded,
        FlowAnimationStyle.fireworks => Icons.celebration_rounded,
      };

  static FlowAnimationStyle fromId(String? id) => switch (id) {
        'wave' => FlowAnimationStyle.wave,
        'particles' => FlowAnimationStyle.particles,
        'fireworks' => FlowAnimationStyle.fireworks,
        _ => FlowAnimationStyle.orb,
      };
}
