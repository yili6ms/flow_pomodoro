import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'flow_orb.dart';

/// Flow Gate transition: expanding/contracting circle with fade-in guidance.
/// Plays once, then calls [onComplete].
class FlowEntryOverlay extends StatefulWidget {
  final String guidance;
  final VoidCallback onComplete;
  final bool reduceMotion;

  const FlowEntryOverlay({
    super.key,
    required this.guidance,
    required this.onComplete,
    this.reduceMotion = false,
  });

  @override
  State<FlowEntryOverlay> createState() => _FlowEntryOverlayState();
}

class _FlowEntryOverlayState extends State<FlowEntryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.reduceMotion ? 800 : 3800),
    );
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    _fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.15, 0.85, curve: Curves.easeInOut),
    );
    _c.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final s = 0.6 + 0.6 * _scale.value;
        return Container(
          color: FlowColors.bgDark.withValues(alpha: 0.92),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: s,
                  child: const FlowOrb(
                    size: 200,
                    isFocus: true,
                    isBreak: false,
                    flowStage: 'initiation',
                  ),
                ),
                const SizedBox(height: 36),
                Opacity(
                  opacity: _fade.value,
                  child: Text(
                    widget.guidance,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: FlowColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
