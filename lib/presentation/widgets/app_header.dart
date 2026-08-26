import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// The top-aligned app header widget for The Remainder Portal.
///
/// Implements a minimalist, Apple-inspired typography display in soft silver-white
/// with clean spacing, aligning to the center of the viewport.
class AppHeader extends StatelessWidget {
  /// The main application title to display. Defaults to "The Remainder Portal".
  final String title;

  /// Custom padding around the header. Defaults to top safe padding and vertical gaps.
  final EdgeInsetsGeometry padding;

  /// Optional subtitle or operator readout widget.
  final Widget? subtitle;

  /// Optional right-aligned header action widgets.
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title = 'The Remainder Portal',
    this.padding = const EdgeInsets.symmetric(
      vertical: PortalTheme.spaceLG,
      horizontal: PortalTheme.spaceMD,
    ),
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme details for text rendering
    final theme = context.portalTheme;

    return Padding(
      padding: padding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Elegant title with tracking adjustment
              Text(
                title,
                style: PortalTheme.titleStyle.copyWith(
                  color: PortalTheme.espresso,
                  shadows: [
                    Shadow(
                      color: theme.primaryAccent.withValues(alpha: 0.15),
                      offset: const Offset(0.0, 1.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                subtitle!,
              ],

              // Micro-accent line for subtle technological detail
              const SizedBox(height: PortalTheme.spaceXS),
              Container(
                width: 48.0,
                height: 2.0,
                decoration: BoxDecoration(
                  color: theme.primaryAccent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryAccent.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
