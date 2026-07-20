import 'package:flutter/material.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';
import 'package:remainder_portal/presentation/widgets/portal_background.dart';
import 'package:remainder_portal/presentation/widgets/app_header.dart';
import 'package:remainder_portal/presentation/widgets/circular_dashboard.dart';
import 'package:remainder_portal/presentation/widgets/dashboard_radial_progress_ring.dart';
import 'package:remainder_portal/presentation/widgets/center_emblem.dart';
import 'package:remainder_portal/presentation/widgets/dashboard_status_icon.dart';
import 'package:remainder_portal/presentation/widgets/horizontal_stat_card.dart';
import 'package:remainder_portal/presentation/widgets/animated_progress_bar.dart';
import 'package:remainder_portal/presentation/widgets/portal_action_button.dart';
import 'package:remainder_portal/presentation/widgets/holographic_decorations.dart';
import 'package:remainder_portal/presentation/screens/descent_screen.dart';

/// The final screen composition for The Remainder Portal.
///
/// Coordinates all custom HUD visual units (background grid, frosted columns,
/// radial progress, animated stat cards, and decorations) into a responsive,
/// premium visor interface layout.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PortalBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Decorative Holographic Vector Overlay (Star sparkles & crosshairs) - In background
          const HolographicDecorations(),

          // 2. Core Screen Layout Structure
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720.0;

                if (isWide) {
                  return _buildWideLayout(context);
                } else {
                  return _buildNarrowLayout(context);
                }
              },
            ),
          ),

          // 3. Floating Action Button Overlay (Persistent, fixed bottom center)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: PortalTheme.spaceLG),
              child: _buildActionButton(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Wide layout composition (Tablets, desktop, landscape orientations).
  Widget _buildWideLayout(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    // Dynamically scale dashboard components based on available viewport height to prevent overflows
    final double dashboardSize = screenHeight < 550.0 ? 210.0 : 300.0;
    final double progressRingSize = screenHeight < 550.0 ? 172.0 : 246.0;
    final double emblemSize = screenHeight < 550.0 ? 28.0 : 40.0;
    final double iconSize = screenHeight < 550.0 ? 16.0 : 20.0;
    final double headerVerticalPadding = screenHeight < 550.0 ? PortalTheme.spaceSM : PortalTheme.spaceLG;

    return Column(
      children: [
        AppHeader(
          padding: EdgeInsets.symmetric(
            vertical: headerVerticalPadding,
            horizontal: PortalTheme.spaceMD,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spaceLG),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Column 1: Left stat pills (Scrollable on short viewports)
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildLeftCards(),
                    ),
                  ),
                ),

                // Column 2: Center Circular Dashboard
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularDashboard(
                        size: dashboardSize,
                        ringSize: progressRingSize,
                        emblemSize: emblemSize,
                        iconSize: iconSize,
                      ),
                      // Add bottom spacer to account for the floating FAB overlay
                      const SizedBox(height: 56.0),
                    ],
                  ),
                ),

                // Column 3: Right stat pills (Scrollable on short viewports)
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildRightCards(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Narrow layout composition (Mobile portrait orientations).
  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppHeader(
            padding: EdgeInsets.only(
              top: PortalTheme.spaceLG,
              bottom: PortalTheme.spaceMD,
            ),
          ),
          _buildCircularDashboard(
            size: 300.0,
            ringSize: 246.0,
            emblemSize: 40.0,
            iconSize: 20.0,
          ),
          const SizedBox(height: PortalTheme.spaceLG),
          
          // Vertically list all cards in mobile view
          ..._buildLeftCards(),
          ..._buildRightCards(),
          
          // Bottom scroll spacer to allow scrolling above the fixed floating FAB overlay
          const SizedBox(height: 96.0),
        ],
      ),
    );
  }

  // --- Layout Helper Creators ---

  Widget _buildCircularDashboard({
    required double size,
    required double ringSize,
    required double emblemSize,
    required double iconSize,
  }) {
    return CircularDashboard(
      size: size,
      progressRing: DashboardRadialProgressRing(
        size: ringSize,
        outerProgress: 0.65,
        innerProgress: 0.45,
      ),
      centerEmblem: CenterEmblem(
        size: emblemSize,
      ),
      topReadout: DashboardStatusIcon(
        icon: Icons.access_time_rounded,
        value: '2000',
        iconSize: iconSize,
      ),
      leftReadout: DashboardStatusIcon(
        icon: Icons.explore_outlined,
        value: '36%',
        iconSize: iconSize,
      ),
      rightReadout: DashboardStatusIcon(
        icon: Icons.opacity_rounded,
        value: '31%',
        iconSize: iconSize,
      ),
      bottomReadout: DashboardStatusIcon(
        icon: Icons.bolt,
        value: '16.23',
        iconSize: iconSize,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return PortalActionButton(
      onTap: () {
        // Navigate forward in game flow to descent screen selector matrix
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DescentScreen()),
        );
      },
    );
  }

  List<Widget> _buildLeftCards() {
    return const [
      HorizontalStatCard(
        label: 'Total Stats',
        value: '10 / 130',
        progressBar: AnimatedProgressBar(value: 0.60),
      ),
      SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Startlery',
        value: '#B0B3C1',
        progressBar: AnimatedProgressBar(value: 0.50),
      ),
      SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Speed',
        value: '3.7%',
        progressBar: AnimatedProgressBar(value: 0.65),
      ),
    ];
  }

  List<Widget> _buildRightCards() {
    return const [
      HorizontalStatCard(
        label: 'Contiimoss',
        value: '20 / 485',
        progressBar: AnimatedProgressBar(value: 0.75),
      ),
      SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Render Color',
        value: '#00E5FF',
        progressBar: AnimatedProgressBar(value: 0.65),
      ),
      SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Listening',
        value: '30px',
        progressBar: AnimatedProgressBar(value: 0.70),
      ),
    ];
  }
}
