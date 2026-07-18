import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';

/// The central dashboard widget for The Remainder Portal.
///
/// Serves as the primary coordinate system and structural layout for the central circular visor.
/// Features a circular frosted glass backing plate, concentric structural guidelines,
/// a centered vertical partition line, and designated zones for top, bottom, left, and right readouts.
class CircularDashboard extends StatelessWidget {
  /// Width and height of the circular dashboard. Default is 320.0.
  final double size;

  /// The radial progress ring widget (Widget 6 in the sequence). If null, a placeholder is rendered.
  final Widget? progressRing;

  /// The center emblem widget (Widget 7 in the sequence). If null, a vertical partition is drawn.
  final Widget? centerEmblem;

  /// The status readout placed at the top-center (Widget 8). If null, a simple placeholder is shown.
  final Widget? topReadout;

  /// The status readout placed at the center-left (Widget 8). If null, a simple placeholder is shown.
  final Widget? leftReadout;

  /// The status readout placed at the center-right (Widget 8). If null, a simple placeholder is shown.
  final Widget? rightReadout;

  /// The status readout placed at the bottom-center (Widget 8). If null, a simple placeholder is shown.
  final Widget? bottomReadout;

  const CircularDashboard({
    super.key,
    this.size = 320.0,
    this.progressRing,
    this.centerEmblem,
    this.topReadout,
    this.leftReadout,
    this.rightReadout,
    this.bottomReadout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.portalTheme;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: theme.glassShadow,
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.surfaceOverlay.withValues(alpha: 0.04), // Frosted plate background
                border: Border.all(
                  color: theme.glassBorder.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Concentric structural guidelines
                  Container(
                    width: size * 0.9,
                    height: size * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.glassBorder.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                    ),
                  ),

                  // 2. Radial Progress Ring (Delegated to Widget 6)
                  progressRing ??
                      // Fallback visual guide ring if no progress ring is supplied yet
                      Container(
                        width: size * 0.82,
                        height: size * 0.82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.primaryAccent.withValues(alpha: 0.1),
                            width: 2.0,
                          ),
                        ),
                      ),

                  // 3. Central HUD Readout Grid Layout
                  Padding(
                    padding: const EdgeInsets.all(PortalTheme.spaceLG),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Section Row
                        topReadout ??
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined, color: Colors.white24, size: 20.0),
                                Text('2000', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              ],
                            ),

                        // Middle Section (Left, Divider/Emblem, Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Left Reading
                            Expanded(
                              child: Center(
                                child: leftReadout ??
                                    const Text('36%', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              ),
                            ),

                            // Vertical Partition / Center Emblem (Delegated to Widget 7)
                            SizedBox(
                              width: 32.0,
                              height: 48.0,
                              child: centerEmblem ??
                                  Center(
                                    child: Container(
                                      width: 1.0,
                                      height: 40.0,
                                      color: theme.secondaryText.withValues(alpha: 0.15),
                                    ),
                                  ),
                            ),

                            // Right Reading
                            Expanded(
                              child: Center(
                                child: rightReadout ??
                                    const Text('31%', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),

                        // Bottom Section Row
                        bottomReadout ??
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, color: Colors.white24, size: 20.0),
                                Text('16.23', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              ],
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
