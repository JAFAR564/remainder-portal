import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/presentation_provider.dart';

class CrtOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const CrtOverlay({super.key, required this.child});

  @override
  ConsumerState<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends ConsumerState<CrtOverlay> with SingleTickerProviderStateMixin {
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
    final presentation = ref.watch(presentationProvider);

    if (presentation.reducedMotion || !presentation.enableCrtScanlines) {
      return widget.child;
    }

    final double flickerVal = presentation.scanlineOpacity + _random.nextDouble() * 0.01;

    return Stack(
      children: [
        widget.child,
        // Scanlines Overlay
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
                    Colors.black.withValues(alpha: presentation.enableChromaticAberration ? 0.55 : 0.35),
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
