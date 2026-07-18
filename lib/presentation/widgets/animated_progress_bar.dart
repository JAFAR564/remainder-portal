import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// A premium, implicitly animated progress bar for The Remainder Portal HUD.
///
/// Sweeps progress changes smoothly with customizable easing, featuring a capsule
/// track design and a soft, self-illuminating neon cyan glow along the active path.
class AnimatedProgressBar extends StatelessWidget {
  /// The target progress ratio (from 0.0 to 1.0) to animate towards.
  final double value;

  /// The vertical thickness of the bar. Default is 5.0.
  final double height;

  /// The duration of the slide transition. Default is 1200ms.
  final Duration duration;

  /// Easing interpolation curve. Default is [Curves.easeOutQuint] for smooth deceleration.
  final Curve curve;

  /// Custom active progress color. Defaults to [PortalTheme.primaryAccent].
  final Color? activeColor;

  /// Custom background track color. Defaults to [PortalTheme.glassBorder] at low opacity.
  final Color? trackColor;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 5.0,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutQuint,
    this.activeColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;

    final resolvedActiveColor = activeColor ?? theme.primaryAccent;
    final resolvedTrackColor = trackColor ?? theme.glassBorder.withValues(alpha: 0.12);
    final borderRadius = BorderRadius.circular(height / 2);

    return Semantics(
      label: 'Progress indicator',
      value: '${(value * 100).toInt()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Container(
            height: height,
            width: maxWidth,
            decoration: BoxDecoration(
              color: resolvedTrackColor,
              borderRadius: borderRadius,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
              duration: duration,
              curve: curve,
              builder: (context, animValue, child) {
                final double widthFraction = animValue * maxWidth;

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: widthFraction,
                    height: height,
                    decoration: BoxDecoration(
                      color: resolvedActiveColor,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: resolvedActiveColor.withValues(alpha: 0.35),
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
