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

  static FlowAnimationStyle fromId(String? id) => switch (id) {
        'wave' => FlowAnimationStyle.wave,
        'particles' => FlowAnimationStyle.particles,
        'fireworks' => FlowAnimationStyle.fireworks,
        _ => FlowAnimationStyle.orb,
      };
}
