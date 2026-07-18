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
          // 1. Core Screen Layout Structure
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

          // 2. Decorative Holographic Vector Overlay (Star sparkles & crosshairs)
          const HolographicDecorations(),
        ],
      ),
    );
  }

  /// Wide layout composition (Tablets, desktop, landscape orientations).
  Widget _buildWideLayout(BuildContext context) {
    return Column(
      children: [
        const AppHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spaceLG),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Column 1: Left stat pills
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildLeftCards(),
                  ),
                ),

                // Column 2: Center Circular Dashboard & FAB
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularDashboard(),
                      const SizedBox(height: PortalTheme.spaceLG),
                      _buildActionButton(context),
                    ],
                  ),
                ),

                // Column 3: Right stat pills
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildRightCards(),
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
          _buildCircularDashboard(),
          const SizedBox(height: PortalTheme.spaceLG),
          
          // Vertically list all cards in mobile view
          ..._buildLeftCards(),
          ..._buildRightCards(),
          
          const SizedBox(height: PortalTheme.spaceLG),
          _buildActionButton(context),
          const SizedBox(height: PortalTheme.spaceXL),
        ],
      ),
    );
  }

  // --- Layout Helper Creators ---

  Widget _buildCircularDashboard() {
    return const CircularDashboard(
      size: 300.0,
      progressRing: DashboardRadialProgressRing(
        size: 246.0,
        outerProgress: 0.65,
        innerProgress: 0.45,
      ),
      centerEmblem: CenterEmblem(
        size: 40.0,
      ),
      topReadout: DashboardStatusIcon(
        icon: Icons.access_time_rounded,
        value: '2000',
      ),
      leftReadout: DashboardStatusIcon(
        icon: Icons.explore_outlined,
        value: '36%',
      ),
      rightReadout: DashboardStatusIcon(
        icon: Icons.opacity_rounded,
        value: '31%',
      ),
      bottomReadout: DashboardStatusIcon(
        icon: Icons.bolt,
        value: '16.23',
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
