import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Slow drifting particles floating around a soft core.
class FlowParticles extends StatefulWidget {
  final double size;
  final bool isBreak;
  final bool reduceMotion;
  final String flowStage;
  final Color? accentColor;
  final Color? accentGlow;

  const FlowParticles({
    super.key,
    required this.size,
    required this.isBreak,
    required this.flowStage,
    this.reduceMotion = false,
    this.accentColor,
    this.accentGlow,
  });

  @override
  State<FlowParticles> createState() => _FlowParticlesState();
}

class _FlowParticlesState extends State<FlowParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    final rnd = math.Random(42);
    _particles = List.generate(
      28,
      (i) => _Particle(
        angle: rnd.nextDouble() * math.pi * 2,
        radiusFactor: 0.25 + rnd.nextDouble() * 0.7,
        speed: 0.05 + rnd.nextDouble() * 0.25,
        size: 1.5 + rnd.nextDouble() * 2.5,
        phase: rnd.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _intensity {
    if (widget.reduceMotion) return 0.3;
    return switch (widget.flowStage) {
      'initiation' => 1.0,
      'stabilization' => 0.7,
      'deep' => 0.35,
      _ => 0.85,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isBreak
        ? FlowColors.breakPrimary
        : (widget.accentColor ?? FlowColors.focusPrimary);
    final glow = widget.isBreak
        ? FlowColors.breakGlow
        : (widget.accentGlow ?? FlowColors.focusGlow);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ParticlePainter(
            t: _c.value,
            particles: _particles,
            color: color,
            glow: glow,
            intensity: _intensity,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double radiusFactor;
  final double speed;
  final double size;
  final double phase;
  _Particle({
    required this.angle,
    required this.radiusFactor,
    required this.speed,
    required this.size,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;
  final Color color;
  final Color glow;
  final double intensity;

  _ParticlePainter({
    required this.t,
    required this.particles,
    required this.color,
    required this.glow,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    // Soft core glow
    final core = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxR * 0.45));
    canvas.drawCircle(center, maxR * 0.45, core);

    // Inner bright dot
    final inner = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85),
          color.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxR * 0.18));
    canvas.drawCircle(center, maxR * 0.18, inner);

    for (final p in particles) {
      final localT = (t + p.phase) % 1.0;
      final breath = 0.5 - 0.5 * math.cos(localT * math.pi * 2);
      final r = maxR * p.radiusFactor * (0.85 + 0.15 * breath);
      final a = p.angle + localT * p.speed * math.pi * 2 * intensity;
      final pos = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      final paint = Paint()
        ..color = glow.withValues(alpha: (0.35 + 0.5 * breath) * intensity);
      canvas.drawCircle(pos, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.t != t || old.color != color || old.intensity != intensity;
}
