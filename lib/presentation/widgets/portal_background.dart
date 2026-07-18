import 'dart:math';
import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// A premium, immersive background widget for The Remainder Portal.
///
/// Implements the Deep Space Gray base canvas, an ambient Cyan nebula radial glow,
/// and a mathematically generated hexagonal honeycomb mesh with a vignette fade.
class PortalBackground extends StatelessWidget {
  /// The child widget to place on top of this background (typically the screen scaffold).
  final Widget child;

  /// Custom size for the hexagonal cells. Default is 24.0.
  final double hexRadius;

  /// The stroke width of the hexagon grid lines. Default is 0.5.
  final double gridStrokeWidth;

  const PortalBackground({
    super.key,
    required this.child,
    this.hexRadius = 28.0,
    this.gridStrokeWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;

    return Scaffold(
      backgroundColor: theme.baseBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Nebula Ambient Radial Glow Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    theme.primaryAccent.withValues(alpha: 0.08), // Cyan center glow
                    theme.baseBackground.withValues(alpha: 0.0), // Fades to base gray
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // 2. Hexagonal Grid Mesh Layer (with RepaintBoundary for GPU Caching)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _HexagonalGridPainter(
                  gridColor: theme.secondaryText.withValues(alpha: 0.025), // Ultra-subtle silver-gray
                  hexRadius: hexRadius,
                  strokeWidth: gridStrokeWidth,
                ),
              ),
            ),
          ),

          // 3. Vignette Blur/Fade overlay for the Hex Grid
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    Colors.transparent,
                    theme.baseBackground.withValues(alpha: 0.2),
                    theme.baseBackground, // Solid at screen edges
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 4. Foreground Content
          Positioned.fill(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw the continuous hexagonal grid.
class _HexagonalGridPainter extends CustomPainter {
  final Color gridColor;
  final double hexRadius;
  final double strokeWidth;

  _HexagonalGridPainter({
    required this.gridColor,
    required this.hexRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // Mathematics of Hexagonal Grids:
    // Width of a flat-topped hexagon is sqrt(3) * Radius.
    final double hexWidth = sqrt(3) * hexRadius;
    // Vertical spacing between adjacent hex rows is 1.5 * Radius.
    final double verticalSpacing = 1.5 * hexRadius;

    final int cols = (size.width / hexWidth).ceil() + 2;
    final int rows = (size.height / verticalSpacing).ceil() + 2;

    final Path gridPath = Path();

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        // Horizontal offset for staggered grid alignment (every odd row shifted)
        final double xOffset = (r % 2 == 0) ? 0 : (hexWidth / 2);
        final double cx = c * hexWidth + xOffset;
        final double cy = r * verticalSpacing;

        // Draw a single flat-topped hexagon path
        _drawHexagon(gridPath, cx, cy, hexRadius);
      }
    }

    canvas.drawPath(gridPath, paint);
  }

  void _drawHexagon(Path path, double cx, double cy, double radius) {
    // Generate the 6 vertex coordinates
    for (int i = 0; i < 6; i++) {
      final double angle = (pi / 3) * i;
      final double x = cx + radius * cos(angle);
      final double y = cy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }

  @override
  bool shouldRepaint(covariant _HexagonalGridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.hexRadius != hexRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
