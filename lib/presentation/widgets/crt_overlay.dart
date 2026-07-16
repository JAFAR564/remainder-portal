import 'dart:math';
import 'package:flutter/material.dart';

class CrtOverlay extends StatefulWidget {
  final Widget child;
  const CrtOverlay({super.key, required this.child});

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _flickerController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      })..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate a random subtle opacity shift for the flicker
    final double flickerVal = 0.015 + _random.nextDouble() * 0.015;

    return Stack(
      children: [
        widget.child,
        // Scanlines
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(opacity: flickerVal),
            ),
          ),
        ),
        // Vignette & Glow Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  _ScanlinePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53170).withValues(alpha: opacity)
      ..strokeWidth = 1.2;
    
    // Draw horizontal lines across the screen representing retro scanlines
    for (double y = 0; y < size.height; y += 4.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
