import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Concentric horizontal sine waves rippling outward.
class FlowWave extends StatefulWidget {
  final double size;
  final bool isBreak;
  final bool reduceMotion;
  final String flowStage;
  final Color? accentColor;
  final Color? accentGlow;

  const FlowWave({
    super.key,
    required this.size,
    required this.isBreak,
    required this.flowStage,
    this.reduceMotion = false,
    this.accentColor,
    this.accentGlow,
  });

  @override
  State<FlowWave> createState() => _FlowWaveState();
}

class _FlowWaveState extends State<FlowWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          painter: _WavePainter(
            t: _c.value,
            color: color,
            glow: glow,
            intensity: _intensity,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t; // 0..1
  final Color color;
  final Color glow;
  final double intensity;

  _WavePainter({
    required this.t,
    required this.color,
    required this.glow,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    // Soft halo
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          glow.withValues(alpha: 0.25),
          glow.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxR));
    canvas.drawCircle(center, maxR, halo);

    // 3 expanding rings
    for (int i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final r = maxR * phase;
      final alpha = (1 - phase) * 0.6 * intensity;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: alpha);
      canvas.drawCircle(center, r, p);
    }

    // Sine wave band across the middle
    final path = Path();
    final amp = 14.0 * intensity;
    final wlen = size.width / 4;
    for (double x = 0; x <= size.width; x += 2) {
      final y = center.dy +
          amp * math.sin((x / wlen) * 2 * math.pi + t * 2 * math.pi);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = color.withValues(alpha: 0.7);
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.t != t || old.color != color || old.intensity != intensity;
}
