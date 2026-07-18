import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// A reusable status readout widget for The Remainder Portal's central HUD.
///
/// Lays out a vertical stack featuring a glowing vector status icon (e.g., timer,
/// humidity, energy) and its corresponding sensor telemetry value text.
class DashboardStatusIcon extends StatelessWidget {
  /// The icon symbol to display (e.g. CupertinoIcons.clock, Icons.bolt).
  final IconData icon;

  /// The reading value text (e.g. "2000", "36%", "16.23").
  final String value;

  /// Custom color for the icon. Defaults to [PortalTheme.primaryAccent].
  final Color? iconColor;

  /// Custom color for the text value. Defaults to [PortalTheme.secondaryText].
  final Color? textColor;

  /// Outer bounds size for the icon glyph. Defaults to 20.0.
  final double iconSize;

  const DashboardStatusIcon({
    super.key,
    required this.icon,
    required this.value,
    this.iconColor,
    this.textColor,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;
    final resolvedIconColor = iconColor ?? theme.primaryAccent;
    final resolvedTextColor = textColor ?? theme.secondaryText;

    return Semantics(
      label: 'HUD Status Sensor Value',
      value: value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Glowing Vector Icon Representation
          Icon(
            icon,
            size: iconSize,
            color: resolvedIconColor,
            shadows: [
              Shadow(
                color: resolvedIconColor.withValues(alpha: 0.4),
                blurRadius: 8.0,
              ),
            ],
          ),
          
          const SizedBox(height: PortalTheme.spaceXS),
          
          // 2. Telemetry Reading Value Text
          Text(
            value,
            style: PortalTheme.widgetValueStyle.copyWith(
              color: resolvedTextColor.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
