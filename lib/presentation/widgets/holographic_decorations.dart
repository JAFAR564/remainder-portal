import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// Decorative holographic overlay widget adding high-tech HUD visual details.
///
/// Draws vector-based four-pointed lens flares (stars), alignment crosshairs,
/// and horizontal sweep line indicators to complete the premium visor HUD design language.
class HolographicDecorations extends StatelessWidget {
  /// Custom accent color for the ornaments. Defaults to [PortalTheme.primaryAccent].
  final Color? color;

  /// Custom secondary color. Defaults to [PortalTheme.secondaryText].
  final Color? secondaryColor;

  const HolographicDecorations({
    super.key,
    this.color,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;
    final resolvedColor = color ?? theme.primaryAccent;
    final resolvedSecColor = secondaryColor ?? theme.secondaryText;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Bottom-Right floating 4-pointed HUD Sparkle (as seen in mockup)
          Positioned(
            right: 48.0,
            bottom: sizeFactor(context, mobile: 120.0, desktop: 200.0),
            child: CustomPaint(
              size: const Size(24.0, 24.0),
              painter: _HUDSparklePainter(color: resolvedSecColor.withValues(alpha: 0.4)),
            ),
          ),

          // 2. Top-Left coordinates crosshair details
          Positioned(
            left: 24.0,
            top: 24.0,
            child: CustomPaint(
              size: const Size(32.0, 32.0),
              painter: _HUDCrosshairPainter(color: resolvedColor.withValues(alpha: 0.3)),
            ),
          ),

          // 3. Subtle horizontal scan grid guidelines
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.sizeOf(context).height * 0.35,
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    resolvedColor.withValues(alpha: 0.12),
                    resolvedColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Responsive layout helper based on screen sizing constraints.
  static double sizeFactor(BuildContext context, {required double mobile, required double desktop}) {
    return MediaQuery.sizeOf(context).width < 600 ? mobile : desktop;
  }
}

/// Paints a mathematical 4-pointed lens flare/sparkle.
class _HUDSparklePainter extends CustomPainter {
  final Color color;

  _HUDSparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    final Path path = Path();
    // Top point
    path.moveTo(center.dx, center.dy - radius);
    // Curves to Right point
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    // Curves to Bottom point
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    // Curves to Left point
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    // Curves to Top point
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    path.close();

    canvas.drawPath(path, paint);

    // Glowing core point
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, 2.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _HUDSparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Paints a technical layout crosshair.
class _HUDCrosshairPainter extends CustomPainter {
  final Color color;

  _HUDCrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    // Draw L-shaped corner indicators
    canvas.drawLine(Offset.zero, Offset(size.width * 0.4, 0.0), paint);
    canvas.drawLine(Offset.zero, Offset(0.0, size.height * 0.4), paint);
    
    // Draw central sub-indicator dot
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 1.0, paint);
  }

  @override
  bool shouldRepaint(covariant _HUDCrosshairPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
