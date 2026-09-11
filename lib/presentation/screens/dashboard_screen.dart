import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/utrcs_provider.dart';
import '../providers/sovereign_provider.dart';
import '../widgets/equipment_slots_widget.dart';
import '../widgets/social_post_card.dart';
import '../widgets/aether_resonance_oracle_widget.dart';
import '../widgets/quest_decree_widget.dart';
import '../widgets/celestial_panel.dart';
import '../widgets/astrolabe_section_header.dart';
import 'descent_screen.dart';
import 'terminal_screen.dart';
import 'expedition_screen.dart';
import 'guild_screen.dart';
import 'chrono_loom_screen.dart';
import 'trade_screen.dart';
import 'character_dossier_screen.dart';

/// Master Dashboard Screen in Celestial Astrolabe Imperial Parchment aesthetic.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showVesselAttributesSheet(BuildContext context, {required int vitality, required int aether, required int essence}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
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
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA78D78),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text('⟐ ', style: TextStyle(color: Color(0xFF6E473B), fontSize: 16)),
                  Text(
                    'SOUL VESSEL ATTRIBUTE TELEMETRY',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildAttributeRow('VITALITY (SHIELD INTEGRITY)', '$vitality / 20', 'Absorbs chaotic dimensional shock and physical damage.', const Color(0xFF6E473B)),
              const Divider(color: Color(0xFFBEB5A9), height: 16),
              _buildAttributeRow('AETHER (ENERGY RESERVE)', '$aether / 20', 'Fuels astral spells, leylines, and cooperative combo checks.', const Color(0xFFA78D78)),
              const Divider(color: Color(0xFFBEB5A9), height: 16),
              _buildAttributeRow('SYSTEM (COMPUTE POWER)', '$essence / 20', 'Powers local AI inference, decryption, and governance voting.', const Color(0xFF291C0E)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFF6E473B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Canonical Soul Vessel base attributes loaded from active UTRCS manifest. Transient depletion / restoration mechanics are currently sealed pending combat domain verification.',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 8.5, color: Color(0xFF6E473B)),
                      ),
                    ),
                  ],
                ),
              ),
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
    final character = ref.watch(utrcsCharacterProvider);
    final walletAsync = ref.watch(activeWalletProvider);
    final socialPosts = ref.watch(socialFeedProvider);

    // Canonical identity resolution:
    // Prefer active UTRCS character, fallback to legacy playerProfile, fallback to default
    final playerName = character?.identity.name ?? profile?.name ?? 'Operator Sung (Shadow Monarch)';
    final playerOrigin = character?.role.tacticalArchetype != null && character?.setting.sectorOrigin != null
        ? '${character!.role.tacticalArchetype} • ${character.setting.sectorOrigin}'
        : (profile?.origin ?? 'Vanguard Class • Sanctuary 4 (Aether Spire)');

    // Canonical attributes (HP/MP/SP) resolution:
    final stats = character?.mechanical.baseStats ?? profile?.stats;
    final vitality = stats?.shieldIntegrity ?? 16;
    final aether = stats?.energyReserve ?? 18;
    final essence = stats?.computePower ?? 14;

    // Progression (Level & XP) resolution from domain wallet:
    final wallet = walletAsync.valueOrNull;
    final int level = wallet?.currentLevel ?? 88;
    final double xpProgress = wallet?.levelProgress ?? 0.463;
    final bool isWalletLoading = walletAsync.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF6E473B),
          backgroundColor: const Color(0xFFFAF7F0),
          onRefresh: () async {
            await ref.read(socialFeedProvider.notifier).refreshFeed();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Operator Sovereign Crest (Section 8.1)
                Semantics(
                  label: 'Player Header: $playerName, $playerOrigin, Level $level. Tap to open UTRCS Character Dossier.',
                  button: true,
                  child: CelestialPanel(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CharacterDossierScreen()),
                      );
                    },
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Operator Avatar Crest Frame
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF6E473B), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6E473B).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.person_pin, size: 34, color: Color(0xFF6E473B)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle Info Area with Live XP Progression
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('✦ ', style: TextStyle(color: Color(0xFF6E473B), fontSize: 13)),
                                  Expanded(
                                    child: Text(
                                      playerName.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6E473B),
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                playerOrigin,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291C0E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'SECTOR: SANCTUARY 4 • UTRCS DOSSIER ↗',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA78D78),
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Live XP Progression Visualization
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.0, end: xpProgress.clamp(0.0, 1.0)),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, animatedXp, _) {
                                          return LinearProgressIndicator(
                                            value: isWalletLoading ? null : animatedXp,
                                            minHeight: 4,
                                            backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.35),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E473B)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(xpProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6E473B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Astrolabe Dial Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1D4C2).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA78D78), width: 1.4),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'LEVEL',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E473B),
                                ),
                              ),
                              Text(
                                '$level',
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291C0E),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Equipment Slots Widget (Section 8.2)
                const EquipmentSlotsWidget(),
                const SizedBox(height: 16),

                // 3. Aether Resonance Oracle (Section 8.3)
                const AetherResonanceOracleWidget(),
                const SizedBox(height: 16),

                // 4. Interactive Quest Decree Window (Section 8.4)
                const QuestDecreeWidget(),
                const SizedBox(height: 16),

                // 5. Stat Meter Gauges with AstrolabeSectionHeader (Fixes Defect 4: 24px overflow)
                AstrolabeSectionHeader(
                  title: 'SOVEREIGN VITALITY & ESSENCE GAUGES',
                  glyph: '✦',
                  fontSize: 11,
                  letterSpacing: 1.2,
                  trailing: InkWell(
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
                ),
                const SizedBox(height: 10),

                // Alchemical Capsule Meters (Section 8.5)
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

                // 6. Adaptive Sovereign Realms & Hubs (Section 8.6)
                const AstrolabeSectionHeader(
                  title: 'SOVEREIGN REALMS & COMMUNION HUBS',
                  glyph: '✦',
                  fontSize: 12,
                  letterSpacing: 1.4,
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

                // 7. Community Wall Feed (Section 8.7, Fixes Defect 5: 57px overflow)
                AstrolabeSectionHeader(
                  title: 'SOVEREIGN COMMUNITY WALL & NEWS FEED',
                  glyph: '✦',
                  fontSize: 12,
                  letterSpacing: 1.4,
                  trailing: Text(
                    '${socialPosts.length} POSTS',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA78D78),
                    ),
                  ),
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
    return RepaintBoundary(
      child: Semantics(
        label: '$label gauge: $value. Tap to inspect telemetry details.',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA78D78), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF291C0E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: targetProgress.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      return LinearProgressIndicator(
                        value: animatedValue,
                        backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
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
      label: 'Navigate to $title ($subtitle)',
      button: true,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetScreen),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA78D78), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E473B).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF291C0E),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
