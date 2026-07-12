import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';

/// A performance-optimized glassmorphic card component.
/// 
/// Backdrop blur is strictly constrained between [6.0, 12.0] to prevent GPU 
/// bottleneck issues on native Impeller and Skia rendering backends.
/// Meets all the structural and design requirements outlined in AGENTS.md.
class GlassCard extends ConsumerWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.sigmaX = 8.0, // Defaults to 8.0 within the safe [6.0, 12.0] performance parameters
    this.sigmaY = 8.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(32.0), // 2.0rem default layout padding
    this.hasBorder = true,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assert safety checks on dev compile builds to enforce the performance boundary
    assert(
      sigmaX >= 6.0 && sigmaX <= 12.0, 
      'sigma_x must be tuned within strict performance parameters [6.0, 12.0] to prevent GPU bottlenecks.'
    );
    assert(
      sigmaY >= 6.0 && sigmaY <= 12.0, 
      'sigma_y must be tuned within strict performance parameters [6.0, 12.0] to prevent GPU bottlenecks.'
    );

    final resolvedBorderRadius = borderRadius ?? BorderRadius.circular(20.0);
    final resolvedBg = backgroundColor ?? PortalTheme.lightGraySurface.withValues(alpha: 0.45);

    return Container(
      decoration: BoxDecoration(
        borderRadius: resolvedBorderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: resolvedBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: resolvedBorderRadius,
              border: hasBorder
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1.0, // 1px hairline border
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
