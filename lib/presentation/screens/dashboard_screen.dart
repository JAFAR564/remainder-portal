import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/equipment_slots_widget.dart';
import '../widgets/social_post_card.dart';
import 'descent_screen.dart';
import 'terminal_screen.dart';
import 'expedition_screen.dart';
import 'guild_screen.dart';
import 'chrono_loom_screen.dart';
import 'trade_screen.dart';

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
      backgroundColor: const Color(0xFFF8F6F0),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
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
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: Image.asset(
                          'assets/icon/app_icon.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFFB8860B)),
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
                              color: Color(0xFFB8860B),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'CLASS: $playerOrigin | RANK: S-RANK',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007791),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'LEVEL',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '88',
                            style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. MMORPG Equipment & Gear Slots Widget
              const EquipmentSlotsWidget(),
              const SizedBox(height: 16),

              // 3. Solo Leveling Holographic System Quest Window
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined, color: Color(0xFFB8860B), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'WORLD ARBITER QUEST DECREE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
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
                      'QUEST: Clear Anomaly Wave in Sanctuary 4 (Aether Spire)',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'The World Arbiter (Cardinal) has detected dimensional chaos. Assemble squad matrix or engage solo descent.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF555555), height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. High Fantasy Stat Meter Gauges
              const Text(
                'SOVEREIGN VITALITY & ESSENCE GAUGES',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFB8860B),
                ),
              ),
              const SizedBox(height: 10),
              
              // Vitality Meters
              Row(
                children: [
                  Expanded(child: _buildStatTile(label: 'VITALITY (HP)', value: '16 / 20', progress: 0.8, color: Colors.redAccent, icon: Icons.favorite)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatTile(label: 'AETHER (MP)', value: '18 / 20', progress: 0.9, color: const Color(0xFF007791), icon: Icons.auto_awesome)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatTile(label: 'SYSTEM (SP)', value: '14 / 20', progress: 0.7, color: const Color(0xFFB8860B), icon: Icons.shield)),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Sovereign Realms & Hubs
              const Text(
                'SOVEREIGN REALMS & COMMUNION HUBS',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFB8860B),
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  _buildSubsystemCard(
                    context,
                    title: 'Descent',
                    subtitle: 'Dungeons',
                    icon: Icons.explore_outlined,
                    color: const Color(0xFFB8860B),
                    targetScreen: const DescentScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Sanctuary Chat',
                    subtitle: 'IC/OOC RP',
                    icon: Icons.forum_outlined,
                    color: const Color(0xFF007791),
                    targetScreen: const TerminalScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Squads',
                    subtitle: 'Co-op P2P',
                    icon: Icons.shield_outlined,
                    color: Colors.purple.shade700,
                    targetScreen: const ExpeditionScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Guilds',
                    subtitle: 'Halls & Vault',
                    icon: Icons.fort_outlined,
                    color: Colors.amber.shade800,
                    targetScreen: const GuildScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Canon',
                    subtitle: 'Lore Votes',
                    icon: Icons.auto_stories_outlined,
                    color: Colors.teal.shade700,
                    targetScreen: const ChronoLoomScreen(),
                  ),
                  _buildSubsystemCard(
                    context,
                    title: 'Market',
                    subtitle: 'Trading',
                    icon: Icons.swap_horiz_outlined,
                    color: Colors.green.shade700,
                    targetScreen: const TradeScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Facebook-Style Social Roleplay Wall Feed
              const Text(
                'SOVEREIGN COMMUNITY WALL & NEWS FEED',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFB8860B),
                ),
              ),
              const SizedBox(height: 12),

              const SocialPostCard(
                authorName: 'Aegis Commander Kaelen',
                authorTitle: 'High Guardian | Guild: Covenant of Aegis',
                avatarPath: 'assets/icon/app_icon.jpg',
                timeAgo: '12m ago',
                content: 'Barrier wards holding strong at Sanctuary 4. Looking for two high-Aether sorcerers to join our raid party against the Shadow Serpent wave tonight!',
                isIC: true,
                initialLaurels: 24,
                initialComments: 7,
              ),

              const SocialPostCard(
                authorName: 'Archmage Nyx',
                authorTitle: 'Master Sorcerer | Guild: Spellweavers',
                avatarPath: 'assets/icon/app_icon.jpg',
                timeAgo: '45m ago',
                content: 'OOC: Just finished designing the new lore proposal for the Ancient Aether Spire in the Chrono-Loom! Please check out the proposal thread and cast your vote!',
                isIC: false,
                initialLaurels: 41,
                initialComments: 12,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
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
            style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFEFECE6),
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
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'serif', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, color: Color(0xFF777777), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
