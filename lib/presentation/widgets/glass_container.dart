import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// A premium, reusable glassmorphic container for The Remainder Portal.
///
/// Implements the Apple-inspired translucent glass effect using a backdrop filter,
/// subtle outer borders, soft ambient drop shadows, and high-readability backing.
class GlassContainer extends StatelessWidget {
  /// The widget content placed inside the glass frame.
  final Widget child;

  /// Internal padding for the container. Defaults to [PortalTheme.spaceMD] (16px).
  final EdgeInsetsGeometry padding;

  /// External margin around the container.
  final EdgeInsetsGeometry? margin;

  /// The boundary clip shape. Defaults to [PortalTheme.clipRadiusPill] (30px).
  final BorderRadius borderRadius;

  /// Amount of horizontal blur applied to background layers. Default is 10.0.
  final double blurX;

  /// Amount of vertical blur applied to background layers. Default is 10.0.
  final double blurY;

  /// Custom background overlay color. Overrides theme default if provided.
  final Color? backgroundColor;

  /// Custom border color. Overrides theme default if provided.
  final Color? borderColor;

  /// The thickness of the surrounding capsule outline. Default is 1.0.
  final double borderWidth;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PortalTheme.spaceMD),
    this.margin,
    this.borderRadius = PortalTheme.clipRadiusPill,
    this.blurX = 10.0,
    this.blurY = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;

    final resolvedBgColor = backgroundColor ?? theme.surfaceOverlay;
    final resolvedBorderColor = borderColor ?? theme.glassBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: theme.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedBgColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: resolvedBorderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
