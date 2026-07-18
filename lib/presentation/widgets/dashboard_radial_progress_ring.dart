import 'dart:math';
import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// The radial progress ring widget for The Remainder Portal's central HUD.
///
/// Custom-paints two concentric glowing progress arcs (outer thin, inner thick)
/// swept over track rings, featuring a hardware-accelerated neon shadow glow.
class DashboardRadialProgressRing extends StatelessWidget {
  /// The size of the progress ring bounding box. Default is 260.0.
  final double size;

  /// Progress fraction (0.0 to 1.0) for the outer ring. Defaults to 0.65.
  final double outerProgress;

  /// Progress fraction (0.0 to 1.0) for the inner ring. Defaults to 0.45.
  final double innerProgress;

  /// The width of the active progress stroke. Defaults to 6.0.
  final double strokeWidth;

  /// The active accent color. If null, [PortalTheme.primaryAccent] is used.
  final Color? activeColor;

  const DashboardRadialProgressRing({
    super.key,
    this.size = 260.0,
    this.outerProgress = 0.65,
    this.innerProgress = 0.45,
    this.strokeWidth = 6.0,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;
    final resolvedColor = activeColor ?? theme.primaryAccent;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RadialProgressPainter(
            outerProgress: outerProgress,
            innerProgress: innerProgress,
            strokeWidth: strokeWidth,
            activeColor: resolvedColor,
            trackColor: theme.glassBorder.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}

class _RadialProgressPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;

  _RadialProgressPainter({
    required this.outerProgress,
    required this.innerProgress,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = (min(size.width, size.height) - strokeWidth) / 2;

    // Define outer and inner radii
    final double outerRadius = maxRadius;
    final double innerRadius = maxRadius - strokeWidth - 6.0;

    // 1. Paint track rings (base backgrounds)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.4
      ..isAntiAlias = true;

    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    // 2. Setup progress paint with neon glow (dual-pass: shadow + solid)
    final double startAngle = -pi / 2; // -90 degrees (Top center)
    final double outerSweepAngle = 2 * pi * outerProgress.clamp(0.0, 1.0);
    final double innerSweepAngle = 2 * pi * innerProgress.clamp(0.0, 1.0);

    // Glow Paint Layer
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
      ..isAntiAlias = true;

    // Solid Active Paint Layer
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // --- Draw Outer Progress Arc ---
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawArc(outerRect, startAngle, outerSweepAngle, false, glowPaint);
    canvas.drawArc(outerRect, startAngle, outerSweepAngle, false, activePaint);

    // --- Draw Inner Progress Arc ---
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawArc(innerRect, startAngle, innerSweepAngle, false, glowPaint);
    canvas.drawArc(innerRect, startAngle, innerSweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
