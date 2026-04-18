import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fireworks: bursts of particles launched from a low origin and exploding
/// outward, fading as they fall. Uses a deterministic random seed for
/// reproducibility.
class FlowFireworks extends StatefulWidget {
  final double size;
  final bool isBreak;
  final bool reduceMotion;
  final String flowStage;
  final Color? accentColor;
  final Color? accentGlow;

  const FlowFireworks({
    super.key,
    required this.size,
    required this.isBreak,
    required this.flowStage,
    this.reduceMotion = false,
    this.accentColor,
    this.accentGlow,
  });

  @override
  State<FlowFireworks> createState() => _FlowFireworksState();
}

class _FlowFireworksState extends State<FlowFireworks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final List<_Burst> _bursts = [];
  final math.Random _rnd = math.Random();
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _c.addListener(_tick);
  }

  @override
  void dispose() {
    _c.removeListener(_tick);
    _c.dispose();
    super.dispose();
  }

  double get _intensity {
    if (widget.reduceMotion) return 0.35;
    return switch (widget.flowStage) {
      'initiation' => 1.0,
      'stabilization' => 0.7,
      'deep' => 0.35,
      _ => 0.85,
    };
  }

  void _tick() {
    final now = _c.value * _c.duration!.inMilliseconds / 1000.0;
    final dt = (now - _lastT).abs();
    _lastT = now;

    // Advance particles
    for (final b in _bursts) {
      b.age += dt;
    }
    _bursts.removeWhere((b) => b.age > b.life);

    // Spawn new burst — frequency scales with motion intensity.
    final spawnRate = 0.5 + 1.5 * _intensity; // bursts per second
    if (_rnd.nextDouble() < spawnRate * dt) {
      _spawnBurst();
    }
  }

  void _spawnBurst() {
    final cx = widget.size * (0.25 + _rnd.nextDouble() * 0.5);
    final cy = widget.size * (0.25 + _rnd.nextDouble() * 0.45);
    final color = _pickColor();
    final particleCount = 18 + _rnd.nextInt(14);
    final speed = 60.0 + _rnd.nextDouble() * 50.0;
    final particles = <_Spark>[];
    for (int i = 0; i < particleCount; i++) {
      final a = (i / particleCount) * math.pi * 2 +
          _rnd.nextDouble() * 0.3;
      final v = speed * (0.7 + _rnd.nextDouble() * 0.6);
      particles.add(_Spark(
        vx: math.cos(a) * v,
        vy: math.sin(a) * v,
        size: 1.5 + _rnd.nextDouble() * 1.8,
      ));
    }
    _bursts.add(_Burst(
      x: cx,
      y: cy,
      color: color,
      particles: particles,
      life: 1.4 + _rnd.nextDouble() * 0.6,
    ));
  }

  Color _pickColor() {
    if (widget.isBreak) {
      return [
        FlowColors.breakPrimary,
        FlowColors.breakGlow,
      ][_rnd.nextInt(2)];
    }
    final base = widget.accentColor ?? FlowColors.focusPrimary;
    final glow = widget.accentGlow ?? FlowColors.focusGlow;
    return [base, glow, Colors.white][_rnd.nextInt(3)];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _FireworksPainter(bursts: _bursts),
        ),
      ),
    );
  }
}

class _Spark {
  final double vx;
  final double vy;
  final double size;
  _Spark({required this.vx, required this.vy, required this.size});
}

class _Burst {
  final double x;
  final double y;
  final Color color;
  final List<_Spark> particles;
  final double life;
  double age = 0;
  _Burst({
    required this.x,
    required this.y,
    required this.color,
    required this.particles,
    required this.life,
  });
}

class _FireworksPainter extends CustomPainter {
  final List<_Burst> bursts;
  _FireworksPainter({required this.bursts});

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 60.0;
    for (final b in bursts) {
      final t = b.age;
      final lifeFrac = (t / b.life).clamp(0.0, 1.0);
      final fade = (1 - lifeFrac);
      for (final s in b.particles) {
        final px = b.x + s.vx * t;
        final py = b.y + s.vy * t + 0.5 * gravity * t * t;
        // Trailing dot
        final paint = Paint()
          ..color = b.color.withValues(alpha: fade * 0.9);
        canvas.drawCircle(Offset(px, py), s.size, paint);
        // Soft glow
        final glow = Paint()
          ..color = b.color.withValues(alpha: fade * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(px, py), s.size * 2.2, glow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => true;
}
