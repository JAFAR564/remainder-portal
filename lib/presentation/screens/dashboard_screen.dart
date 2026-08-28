import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/equipment_slots_widget.dart';
import '../widgets/social_post_card.dart';
import '../widgets/aether_resonance_oracle_widget.dart';
import '../widgets/quest_decree_widget.dart';
import 'descent_screen.dart';
import 'terminal_screen.dart';
import 'expedition_screen.dart';
import 'guild_screen.dart';
import 'chrono_loom_screen.dart';
import 'trade_screen.dart';
import 'character_dossier_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showVesselAttributesSheet(BuildContext context, {required int vitality, required int aether, required int essence}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E473B).withValues(alpha: 0.18),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEB5A9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SOUL VESSEL ATTRIBUTE TELEMETRY',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E473B),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              _buildAttributeRow('VITALITY (SHIELD INTEGRITY)', '$vitality / 20', 'Absorbs chaotic dimensional shock and physical damage.', const Color(0xFF6E473B)),
              const Divider(color: Color(0xFFBEB5A9), height: 16),
              _buildAttributeRow('AETHER (ENERGY RESERVE)', '$aether / 20', 'Fuels astral spells, leylines, and cooperative combo checks.', const Color(0xFFA78D78)),
              const Divider(color: Color(0xFFBEB5A9), height: 16),
              _buildAttributeRow('SYSTEM (COMPUTE POWER)', '$essence / 20', 'Powers local AI inference, decryption, and governance voting.', const Color(0xFF291C0E)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E473B),
                    foregroundColor: const Color(0xFFE1D4C2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DISMISS TELEMETRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildAttributeRow(String title, String value, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              value,
              style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF6E473B))),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final socialPosts = ref.watch(socialFeedProvider);

    final playerName = profile?.name ?? 'Operator Sung (Shadow Monarch)';
    final playerOrigin = profile?.origin ?? 'Vanguard Class';
    final vitality = profile?.stats.shieldIntegrity ?? 16;
    final aether = profile?.stats.energyReserve ?? 18;
    final essence = profile?.stats.computePower ?? 14;

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF6E473B),
          backgroundColor: Colors.white,
          onRefresh: () async {
            await ref.read(socialFeedProvider.notifier).refreshFeed();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. System Administrator Header Card
                Semantics(
                  label: 'Player Header: $playerName, $playerOrigin, Level 88. Tap to open UTRCS Character Dossier.',
                  button: true,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CharacterDossierScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6E473B).withValues(alpha: 0.15),
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
                            border: Border.all(color: const Color(0xFFA78D78), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6E473B).withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFF6E473B)),
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
                                  color: Color(0xFF6E473B),
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
                                  color: Color(0xFF291C0E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1D4C2).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF291C0E).withValues(alpha: 0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'LEVEL',
                                style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFF6E473B), fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '88',
                                style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

                // 2. Equipment Slots Widget
                const EquipmentSlotsWidget(),
                const SizedBox(height: 16),

                // 3. Aether Resonance Oracle
                const AetherResonanceOracleWidget(),
                const SizedBox(height: 16),

                // 4. Interactive Quest Decree Window
                const QuestDecreeWidget(),
                const SizedBox(height: 16),

                // 5. Stat Meter Gauges with Smooth Animated Interpolation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SOVEREIGN VITALITY & ESSENCE GAUGES',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF6E473B),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showVesselAttributesSheet(context, vitality: vitality, aether: aether, essence: essence),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'INSPECT ℹ',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E473B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Animated Vitality Meters
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedStatTile(
                        context,
                        label: 'VITALITY (HP)',
                        value: '$vitality / 20',
                        targetProgress: vitality / 20.0,
                        color: const Color(0xFF6E473B),
                        icon: Icons.favorite,
                        onTap: () => _showVesselAttributesSheet(context, vitality: vitality, aether: aether, essence: essence),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAnimatedStatTile(
                        context,
                        label: 'AETHER (MP)',
                        value: '$aether / 20',
                        targetProgress: aether / 20.0,
                        color: const Color(0xFFA78D78),
                        icon: Icons.auto_awesome,
                        onTap: () => _showVesselAttributesSheet(context, vitality: vitality, aether: aether, essence: essence),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAnimatedStatTile(
                        context,
                        label: 'SYSTEM (SP)',
                        value: '$essence / 20',
                        targetProgress: essence / 20.0,
                        color: const Color(0xFF291C0E),
                        icon: Icons.shield,
                        onTap: () => _showVesselAttributesSheet(context, vitality: vitality, aether: aether, essence: essence),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. Adaptive Sovereign Realms & Hubs
                const Text(
                  'SOVEREIGN REALMS & COMMUNION HUBS',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF6E473B),
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final int crossAxisCount = width > 720 ? 6 : (width > 480 ? 3 : (width < 340 ? 2 : 3));
                    final double childAspectRatio = width < 340 ? 1.3 : (width > 720 ? 1.05 : 1.15);
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _buildSubsystemCard(
                          context,
                          title: 'Descent',
                          subtitle: 'Dungeons',
                          icon: Icons.explore_outlined,
                          color: const Color(0xFF6E473B),
                          targetScreen: const DescentScreen(),
                        ),
                        _buildSubsystemCard(
                          context,
                          title: 'Sanctuary Chat',
                          subtitle: 'IC/OOC RP',
                          icon: Icons.forum_outlined,
                          color: const Color(0xFFA78D78),
                          targetScreen: const TerminalScreen(),
                        ),
                        _buildSubsystemCard(
                          context,
                          title: 'Squads',
                          subtitle: 'Co-op P2P',
                          icon: Icons.shield_outlined,
                          color: const Color(0xFF291C0E),
                          targetScreen: const ExpeditionScreen(),
                        ),
                        _buildSubsystemCard(
                          context,
                          title: 'Guilds',
                          subtitle: 'Halls & Vault',
                          icon: Icons.fort_outlined,
                          color: const Color(0xFF6E473B),
                          targetScreen: const GuildScreen(),
                        ),
                        _buildSubsystemCard(
                          context,
                          title: 'Canon',
                          subtitle: 'Lore Votes',
                          icon: Icons.auto_stories_outlined,
                          color: const Color(0xFFA78D78),
                          targetScreen: const ChronoLoomScreen(),
                        ),
                        _buildSubsystemCard(
                          context,
                          title: 'Market',
                          subtitle: 'Trading',
                          icon: Icons.swap_horiz_outlined,
                          color: const Color(0xFF291C0E),
                          targetScreen: const TradeScreen(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 7. Community Wall Feed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SOVEREIGN COMMUNITY WALL & NEWS FEED',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF6E473B),
                      ),
                    ),
                    Text(
                      '${socialPosts.length} POSTS',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...socialPosts.map(
                  (post) => SocialPostCard(
                    key: ValueKey(post.id),
                    authorName: post.authorName,
                    authorTitle: post.authorTitle,
                    avatarPath: post.avatarPath,
                    timeAgo: post.timeAgo,
                    content: post.content,
                    isIC: post.isIC,
                    initialLaurels: post.laurels,
                    initialComments: post.comments,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required double targetProgress,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$label: $value',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E473B).withValues(alpha: 0.1),
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
                style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: targetProgress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: animatedValue,
                      backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
    return Semantics(
      label: 'Realm card: $title, $subtitle',
      button: true,
      child: GestureDetector(
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
            border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF291C0E).withValues(alpha: 0.05),
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
                style: const TextStyle(fontFamily: 'serif', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, color: Color(0xFF6E473B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
