import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';
import 'package:remainder_portal/presentation/widgets/glass_container.dart';

/// A horizontal pill-shaped status card for displaying metrics in columns.
///
/// Composes the frosted [GlassContainer] to create a 30px pill capsule shell
/// holding a title label, reading value, and a linear progress indicator slot.
class HorizontalStatCard extends StatelessWidget {
  /// The parameter category label (e.g. "Total Stats").
  final String label;

  /// The parameter telemetry value (e.g. "10 / 130", "3.7%").
  final String value;

  /// The progress fraction (0.0 to 1.0) for the track bar. Default is 0.5.
  /// Used by the default indicator if [progressBar] is null.
  final double progress;

  /// Custom progress bar widget slot (delegates to Widget 10 in the sequence).
  /// If null, a standard styled progress bar is rendered as a placeholder.
  final Widget? progressBar;

  /// The width of the card. If null, it takes the parent's width constraints.
  final double? width;

  const HorizontalStatCard({
    key,
    required this.label,
    required this.value,
    this.progress = 0.5,
    this.progressBar,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;

    // Default static progress indicator used as a compilation placeholder
    final Widget defaultProgressBar = SizedBox(
      height: 4.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.glassBorder.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryAccent),
        ),
      ),
    );

    return SizedBox(
      width: width ?? double.infinity,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: PortalTheme.spaceMD,
          vertical: PortalTheme.spaceSM + 2.0, // Clean vertical balancing
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Label and Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: PortalTheme.cardLabelStyle.copyWith(
                    color: theme.secondaryText.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  value,
                  style: PortalTheme.cardValueStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: PortalTheme.spaceSM),
            
            // Row 2: Progress Indicator (Delegated or Default)
            progressBar ?? defaultProgressBar,
          ],
        ),
      ),
    );
  }
}
