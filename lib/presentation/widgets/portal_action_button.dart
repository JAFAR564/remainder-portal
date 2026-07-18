import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// The premium, interactive Floating Action Button for The Remainder Portal HUD.
///
/// Implements a circular neon-ring design with a centered vector navigation arrow.
/// Animates dynamically (press scaling, glow intensity changes) in response to touch events.
class PortalActionButton extends StatefulWidget {
  /// Callback triggered when the button is tapped.
  final VoidCallback onTap;

  /// The icon symbol to display in the center. Defaults to a right arrow.
  final IconData icon;

  /// Bounding size dimensions of the button. Default is 64.0.
  final double size;

  /// Highlight color. Defaults to [PortalTheme.primaryAccent].
  final Color? color;

  const PortalActionButton({
    super.key,
    required this.onTap,
    this.icon = Icons.arrow_forward_rounded,
    this.size = 64.0,
    this.color,
  });

  @override
  State<PortalActionButton> createState() => _PortalActionButtonState();
}

class _PortalActionButtonState extends State<PortalActionButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;
    final resolvedColor = widget.color ?? theme.primaryAccent;

    // Pulse active animation scale values
    final double scale = _isPressed ? 0.92 : 1.0;
    final double glowIntensity = _isPressed ? 0.7 : 0.35;
    final double blurRadius = _isPressed ? 20.0 : 12.0;

    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.baseBackground.withValues(alpha: 0.4), // Dark translucent core
              border: Border.all(
                color: resolvedColor.withValues(alpha: 0.8),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: resolvedColor.withValues(alpha: glowIntensity),
                  blurRadius: blurRadius,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: widget.size * 0.45,
              color: resolvedColor,
            ),
          ),
        ),
      ),
    );
  }
}
