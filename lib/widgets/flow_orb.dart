import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// FlowOrb: central animated "Flow Core".
/// - Inner core breathing glow
/// - Outer slow-rotating orbit highlights
/// Animation intensity adapts to flow stage.
class FlowOrb extends StatefulWidget {
  final double size;
  final bool isFocus;
  final bool isBreak;
  final bool reduceMotion;
  final Color? accentColor;
  final Color? accentGlow;

  /// 'initiation' | 'stabilization' | 'deep' | 'rest'
  final String flowStage;

  const FlowOrb({
    super.key,
    required this.size,
    required this.isFocus,
    required this.isBreak,
    required this.flowStage,
    this.reduceMotion = false,
    this.accentColor,
    this.accentGlow,
  });

  @override
  State<FlowOrb> createState() => _FlowOrbState();
}

class _FlowOrbState extends State<FlowOrb>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _breath.dispose();
    _orbit.dispose();
    super.dispose();
  }

  Color get _primary {
    if (widget.isBreak) return FlowColors.breakPrimary;
    return widget.accentColor ?? FlowColors.focusPrimary;
  }

  Color get _glow {
    if (widget.isBreak) return FlowColors.breakGlow;
    return widget.accentGlow ?? FlowColors.focusGlow;
  }

  /// Motion intensity decreases as flow deepens.
  double get _motionFactor {
    if (widget.reduceMotion) return 0.3;
    switch (widget.flowStage) {
      case 'initiation':
        return 1.0;
      case 'stabilization':
        return 0.7;
      case 'deep':
        return 0.35;
      default:
        return 0.85;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _orbit]),
        builder: (context, _) {
          final breath = 0.5 - 0.5 * math.cos(_breath.value * math.pi * 2);
          final scale = 1.0 + 0.05 * _motionFactor * breath;
          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              painter: _OrbPainter(
                primary: _primary,
                glow: _glow,
                breath: breath,
                orbit: _orbit.value,
                motion: _motionFactor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Color primary;
  final Color glow;
  final double breath; // 0..1
  final double orbit; // 0..1
  final double motion;

  _OrbPainter({
    required this.primary,
    required this.glow,
    required this.breath,
    required this.orbit,
    required this.motion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    // Outer soft glow halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glow.withValues(alpha: 0.35 + 0.15 * breath),
          glow.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, haloPaint);

    // Mid soft body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: 0.85),
          primary.withValues(alpha: 0.25),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.62));
    canvas.drawCircle(center, r * 0.62, bodyPaint);

    // Inner core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85),
          primary.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.32));
    canvas.drawCircle(center, r * 0.32, corePaint);

    // Orbit highlights (3 small dots)
    final orbitR = r * 0.78;
    final dotPaint = Paint()..color = glow.withValues(alpha: 0.6 * motion);
    for (int i = 0; i < 3; i++) {
      final angle = (orbit + i / 3) * math.pi * 2;
      final p = Offset(
        center.dx + orbitR * math.cos(angle),
        center.dy + orbitR * math.sin(angle),
      );
      canvas.drawCircle(p, 3.0 + 1.5 * breath, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.breath != breath ||
      old.orbit != orbit ||
      old.primary != primary ||
      old.glow != glow ||
      old.motion != motion;
}
