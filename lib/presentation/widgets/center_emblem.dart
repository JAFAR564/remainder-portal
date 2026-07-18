import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// The center emblem widget representing the brand identity of The Remainder Portal.
///
/// Draws a stylized, glowing portal ring insignia containing a crescent loop (representing
/// the "remainder" node) in electric cyan using custom vector shapes.
class CenterEmblem extends StatelessWidget {
  /// The diameter of the emblem bounds. Default is 44.0.
  final double size;

  /// Custom color for the emblem lines. If null, [PortalTheme.primaryAccent] is used.
  final Color? color;

  /// Controls the pulse/glow factor of the background emblem.
  final double glowOpacity;

  const CenterEmblem({
    super.key,
    this.size = 44.0,
    this.color,
    this.glowOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;
    final resolvedColor = color ?? theme.primaryAccent;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: resolvedColor.withValues(alpha: glowOpacity),
              blurRadius: 12.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _EmblemPainter(
            color: resolvedColor,
          ),
        ),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  final Color color;

  _EmblemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw outer border ring of the emblem
    canvas.drawCircle(center, radius * 0.95, paint);

    // 2. Draw inner circular path representing the crescent portal gate
    final Path crescentPath = Path();
    
    // Draw outer crescent arc
    crescentPath.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -0.65 * 3.1415, // start angle
      1.3 * 3.1415,  // sweep angle
    );

    // Smooth transition inwards to represent the crescent overlap
    final innerCenter = Offset(center.dx - (radius * 0.15), center.dy);
    crescentPath.arcTo(
      Rect.fromCircle(center: innerCenter, radius: radius * 0.45),
      0.65 * 3.1415,
      -1.3 * 3.1415,
      false,
    );

    crescentPath.close();

    // Paint the inner crescent fill and borders
    canvas.drawPath(crescentPath, fillPaint);
    canvas.drawPath(crescentPath, paint);

    // 3. Draw a tiny core dot in the center of the crescent
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, 2.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
