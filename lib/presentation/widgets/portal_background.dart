import 'package:flutter/material.dart';

/// A celestial astrolabe antique parchment background widget for The Remainder Portal.
///
/// Renders the high-resolution antique celestial astrolabe artwork featuring warm parchment tones,
/// astrolabe quadrants, celestial Leyline coordinates, and parchment grain texture.
class PortalBackground extends StatelessWidget {
  /// The foreground child widget to place on top of this background.
  final Widget child;

  /// Path to the background asset. Defaults to 'assets/images/portal_astrolabe_bg.png'.
  final String assetPath;

  /// Opacity multiplier for the background image (default 1.0).
  final double opacity;

  /// An optional overlay color or scrim (e.g. for high-contrast reading or dialogs).
  final Color? overlayColor;

  /// Image fit mode for responsive scaling. Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Alignment of the image within the viewport. Defaults to [Alignment.center].
  final Alignment alignment;

  const PortalBackground({
    super.key,
    required this.child,
    this.assetPath = 'assets/images/portal_astrolabe_bg.png',
    this.opacity = 1.0,
    this.overlayColor,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Base Imperial Parchment fallback color
        const ColoredBox(
          color: Color(0xFFE1D4C2),
        ),

        // 2. High-Resolution Celestial Astrolabe Parchment Asset
        Positioned.fill(
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Image.asset(
              assetPath,
              fit: fit,
              alignment: alignment,
              errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
            ),
          ),
        ),

        // 3. Optional Overlay Tint / Scrim
        if (overlayColor != null)
          Positioned.fill(
            child: ColoredBox(
              color: overlayColor!,
            ),
          ),

        // 4. Foreground Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
