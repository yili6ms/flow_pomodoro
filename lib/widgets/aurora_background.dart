import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A slow-drifting "aurora" mesh of soft radial gradients used as the
/// global ambient background. Designed to feel alive without distracting
/// from foreground content. Always animates in real time (negligible CPU).
///
/// Pass an [accent] color to tint the dominant blob.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  final Color accent;
  final Color secondary;
  final bool reduceMotion;

  const AuroraBackground({
    super.key,
    required this.child,
    required this.accent,
    required this.secondary,
    this.reduceMotion = false,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 32),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base canvas
        const ColoredBox(color: Color(0xFF08090C)),
        // Animated mesh
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _AuroraPainter(
              t: widget.reduceMotion ? 0.25 : _c.value,
              accent: widget.accent,
              secondary: widget.secondary,
            ),
          ),
        ),
        // Subtle vignette + grain feel via dark overlay
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [Colors.transparent, Color(0xCC08090C)],
              stops: [0.55, 1.0],
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final Color accent;
  final Color secondary;

  _AuroraPainter({
    required this.t,
    required this.accent,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final maxR = math.sqrt(w * w + h * h) * 0.65;

    final phase = t * math.pi * 2;
    final blobs = [
      _Blob(
        center: Offset(
          w * (0.30 + 0.08 * math.sin(phase * 0.7)),
          h * (0.28 + 0.06 * math.cos(phase * 0.9)),
        ),
        radius: maxR * 0.55,
        color: accent.withValues(alpha: 0.55),
      ),
      _Blob(
        center: Offset(
          w * (0.78 + 0.07 * math.cos(phase * 0.6)),
          h * (0.22 + 0.05 * math.sin(phase * 0.5)),
        ),
        radius: maxR * 0.48,
        color: secondary.withValues(alpha: 0.40),
      ),
      _Blob(
        center: Offset(
          w * (0.55 + 0.10 * math.sin(phase * 0.45 + 1.0)),
          h * (0.85 + 0.04 * math.cos(phase * 0.6 + 0.5)),
        ),
        radius: maxR * 0.62,
        color: const Color(0xFF6E5AE6).withValues(alpha: 0.30),
      ),
    ];

    for (final b in blobs) {
      final shader = RadialGradient(
        colors: [b.color, b.color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      final paint = Paint()..shader = shader;
      canvas.drawCircle(b.center, b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.accent != accent || old.secondary != secondary;
}

class _Blob {
  final Offset center;
  final double radius;
  final Color color;
  _Blob({required this.center, required this.radius, required this.color});
}
