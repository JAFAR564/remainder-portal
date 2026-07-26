import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:remainder_portal/presentation/screens/genesis_screen.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';

import 'package:remainder_portal/presentation/screens/expedition_screen.dart';
import 'package:remainder_portal/presentation/screens/guild_screen.dart';
import 'package:remainder_portal/presentation/screens/chrono_loom_screen.dart';
import 'package:remainder_portal/presentation/screens/trade_screen.dart';
import 'package:remainder_portal/presentation/screens/creator_dashboard_screen.dart';
import 'package:remainder_portal/presentation/screens/settings_screen.dart';

/// The final screen composition for The Remainder Portal.
///
/// Coordinates all custom HUD visual units (background grid, frosted columns,
/// radial progress, animated stat cards, and decorations) into a responsive,
/// premium visor interface layout.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
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
                  return _buildWideLayout(context, profile);
                } else {
                  return _buildNarrowLayout(context, profile);
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
  Widget _buildWideLayout(BuildContext context, PlayerProfile? profile) {
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
          subtitle: Text(
            profile != null ? 'OPERATOR: ${profile.name.toUpperCase()} [${profile.origin.toUpperCase()}]' : 'SYSTEM ID: UNREGISTERED (DEFAULT PROTOTYPE)',
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            PopupMenuButton<Widget>(
              icon: const Icon(Icons.apps_rounded, color: Color(0xFF00E5FF), size: 26),
              tooltip: 'Navigation Matrix',
              color: const Color(0xFF161520),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
              ),
              onSelected: (Widget targetScreen) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => targetScreen),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: GenesisScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.person_add_outlined, color: Color(0xFF00E5FF), size: 18),
                      SizedBox(width: 12),
                      Text('Character Genesis', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExpeditionScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.groups_outlined, color: Color(0xFFE53170), size: 18),
                      SizedBox(width: 12),
                      Text('Expedition Squad Matrix', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: GuildScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFFFF8E3C), size: 18),
                      SizedBox(width: 12),
                      Text('Sovereign Guilds', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ChronoLoomScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_outlined, color: Color(0xFFFFD166), size: 18),
                      SizedBox(width: 12),
                      Text('Chrono-Loom Canon', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: TradeScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz_outlined, color: Color(0xFF38B000), size: 18),
                      SizedBox(width: 12),
                      Text('P2P Escrow Market', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: CreatorDashboardScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.design_services_outlined, color: Color(0xFFE53170), size: 18),
                      SizedBox(width: 12),
                      Text('Creator Authoring Suite', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SettingsScreen(),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: Colors.white70, size: 18),
                      SizedBox(width: 12),
                      Text('System Settings', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                      children: _buildLeftCards(profile),
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
                        profile: profile,
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
                      children: _buildRightCards(profile),
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
  Widget _buildNarrowLayout(BuildContext context, PlayerProfile? profile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppHeader(
            padding: const EdgeInsets.only(
              top: PortalTheme.spaceLG,
              bottom: PortalTheme.spaceMD,
            ),
            subtitle: Text(
              profile != null ? 'OPERATOR: ${profile.name.toUpperCase()}' : 'SYSTEM ID: UNREGISTERED',
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              PopupMenuButton<Widget>(
                icon: const Icon(Icons.apps_rounded, color: Color(0xFF00E5FF), size: 26),
                tooltip: 'Navigation Matrix',
                color: const Color(0xFF161520),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
                ),
                onSelected: (Widget targetScreen) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => targetScreen),
                  );
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: GenesisScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_outlined, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 12),
                        Text('Character Genesis', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: ExpeditionScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.groups_outlined, color: Color(0xFFE53170), size: 18),
                        SizedBox(width: 12),
                        Text('Expedition Squad Matrix', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: GuildScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFFFF8E3C), size: 18),
                        SizedBox(width: 12),
                        Text('Sovereign Guilds', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: ChronoLoomScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_outlined, color: Color(0xFFFFD166), size: 18),
                        SizedBox(width: 12),
                        Text('Chrono-Loom Canon', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: TradeScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_outlined, color: Color(0xFF38B000), size: 18),
                        SizedBox(width: 12),
                        Text('P2P Escrow Market', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: CreatorDashboardScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.design_services_outlined, color: Color(0xFFE53170), size: 18),
                        SizedBox(width: 12),
                        Text('Creator Authoring Suite', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: SettingsScreen(),
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, color: Colors.white70, size: 18),
                        SizedBox(width: 12),
                        Text('System Settings', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildCircularDashboard(
            size: 300.0,
            ringSize: 246.0,
            emblemSize: 40.0,
            iconSize: 20.0,
            profile: profile,
          ),
          const SizedBox(height: PortalTheme.spaceLG),
          
          // Vertically list all cards in mobile view
          ..._buildLeftCards(profile),
          ..._buildRightCards(profile),
          
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
    PlayerProfile? profile,
  }) {
    final computeVal = profile?.stats.computePower ?? 10;
    final shieldVal = profile?.stats.shieldIntegrity ?? 10;
    final energyVal = profile?.stats.energyReserve ?? 10;

    return CircularDashboard(
      size: size,
      progressRing: DashboardRadialProgressRing(
        size: ringSize,
        outerProgress: (computeVal / 20.0).clamp(0.0, 1.0),
        innerProgress: (shieldVal / 20.0).clamp(0.0, 1.0),
      ),
      centerEmblem: CenterEmblem(
        size: emblemSize,
      ),
      topReadout: DashboardStatusIcon(
        icon: Icons.bolt,
        value: '$computeVal',
        iconSize: iconSize,
      ),
      leftReadout: DashboardStatusIcon(
        icon: Icons.shield,
        value: '$shieldVal',
        iconSize: iconSize,
      ),
      rightReadout: DashboardStatusIcon(
        icon: Icons.battery_charging_full,
        value: '$energyVal',
        iconSize: iconSize,
      ),
      bottomReadout: DashboardStatusIcon(
        icon: Icons.wifi,
        value: profile != null ? 'SYNC' : '16.23',
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

  List<Widget> _buildLeftCards(PlayerProfile? profile) {
    final compute = profile?.stats.computePower ?? 10;
    final shield = profile?.stats.shieldIntegrity ?? 10;
    final energy = profile?.stats.energyReserve ?? 10;

    return [
      HorizontalStatCard(
        label: 'Compute Power',
        value: '$compute / 20',
        progressBar: AnimatedProgressBar(value: (compute / 20.0).clamp(0.0, 1.0)),
      ),
      const SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Shield Integrity',
        value: '$shield / 20',
        progressBar: AnimatedProgressBar(value: (shield / 20.0).clamp(0.0, 1.0)),
      ),
      const SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Energy Reserve',
        value: '$energy / 20',
        progressBar: AnimatedProgressBar(value: (energy / 20.0).clamp(0.0, 1.0)),
      ),
    ];
  }

  List<Widget> _buildRightCards(PlayerProfile? profile) {
    return [
      HorizontalStatCard(
        label: 'Origin Class',
        value: profile?.origin.toUpperCase() ?? 'VANGUARD',
        progressBar: const AnimatedProgressBar(value: 0.85),
      ),
      const SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Active Sector',
        value: profile?.activeSector.replaceAll('sectors_', '').toUpperCase() ?? 'NEON BASTION',
        progressBar: const AnimatedProgressBar(value: 0.70),
      ),
      const SizedBox(height: PortalTheme.spaceMD),
      HorizontalStatCard(
        label: 'Neural Sync',
        value: profile != null ? '100%' : 'DEMO MODE',
        progressBar: const AnimatedProgressBar(value: 0.95),
      ),
    ];
  }
}
