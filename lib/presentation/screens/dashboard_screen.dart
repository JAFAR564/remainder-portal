import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'descent_screen.dart';
import 'terminal_screen.dart';
import 'expedition_screen.dart';
import 'guild_screen.dart';
import 'chrono_loom_screen.dart';
import 'trade_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    final playerName = profile?.name ?? 'Operator Sung (Shadow Monarch)';
    final playerOrigin = profile?.origin ?? 'Vanguard Class';
    final vitality = profile?.stats.shieldIntegrity ?? 16;
    final aether = profile?.stats.energyReserve ?? 18;
    final essence = profile?.stats.computePower ?? 14;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. System Administrator Header Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Operator Avatar Emblem
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: Image.asset(
                          'assets/icon/app_icon.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Name & Title Readouts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerName.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'CLASS: $playerOrigin | RANK: S-RANK',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Color(0xFF00B4D8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'LEVEL',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFFD4AF37)),
                          ),
                          Text(
                            '88',
                            style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Solo Leveling Holographic System Quest Window
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00B4D8).withValues(alpha: 0.15),
                      const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4D8).withValues(alpha: 0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, color: Color(0xFF00B4D8), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'SYSTEM ADMINISTRATOR QUEST NOTICE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B4D8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'QUEST: Clear Anomaly Wave in Sector 4 (Neon Bastion)',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'The System Administrator AI (Cardinal) has detected dimensional instability. Assemble squad matrix or engage solo descent.',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Sci-Fi / High Fantasy Stat Meter Gauges
              const Text(
                'SOVEREIGN VITALITY & ESSENCE GAUGES',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      label: 'VITALITY CORE (HP)',
                      value: '$vitality / 20',
                      progress: vitality / 20.0,
                      color: Colors.redAccent,
                      icon: Icons.favorite_outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatTile(
                      label: 'AETHER RESERVE (MP)',
                      value: '$aether / 20',
                      progress: aether / 20.0,
                      color: const Color(0xFF00B4D8),
                      icon: Icons.bolt_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatTile(
                      label: 'SYSTEM ESSENCE (SP)',
                      value: '$essence / 20',
                      progress: essence / 20.0,
                      color: const Color(0xFFD4AF37),
                      icon: Icons.auto_awesome_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Subsystem Quick-Action Community Grid
              const Text(
                'SOVEREIGN SUBSYSTEMS & NEXUS HUBS',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _buildSubsystemCard(
                    context,
                    title: 'Dungeon Descent',
                    subtitle: 'Engage Sector Anomalies',
                    icon: Icons.explore_outlined,
                    color: const Color(0xFFD4AF37),
                    targetScreen: const DescentScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Nexus Roleplay',
                    subtitle: 'IC/OOC Roleplay Chat',
                    icon: Icons.forum_outlined,
                    color: const Color(0xFF00B4D8),
                    targetScreen: const TerminalScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Squad Matrix',
                    subtitle: 'Co-op P2P Squads',
                    icon: Icons.shield_outlined,
                    color: Colors.purpleAccent,
                    targetScreen: const ExpeditionScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Sovereign Guilds',
                    subtitle: 'Guild Halls & Treasury',
                    icon: Icons.fort_outlined,
                    color: Colors.amber,
                    targetScreen: const GuildScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Chrono-Loom Canon',
                    subtitle: 'Community Lore Voting',
                    icon: Icons.auto_stories_outlined,
                    color: Colors.tealAccent,
                    targetScreen: const ChronoLoomScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Market Escrow',
                    subtitle: 'P2P Asset Trading',
                    icon: Icons.swap_horiz_outlined,
                    color: Colors.lightGreenAccent,
                    targetScreen: const TradeScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsystemCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget targetScreen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2541).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
