// Ennoia System Entry Point
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'services/roster_cache_service.dart';
import 'services/chat_service.dart';
import 'services/auth_service.dart';
import 'theme/portal_theme.dart';
import 'ui/animations/spring_tap_wrapper.dart';
import 'ui/components/glass_card.dart';
import 'ui/components/iridescent_overlay.dart';
import 'ui/components/responsive_layout.dart';
import 'features/profile/providers/active_character_provider.dart';
import 'ui/components/relationship_web.dart';
import 'ui/components/global_feedback_overlay.dart';
import 'models/chat_room.dart';
import 'models/roster_member.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local preferences cache
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Supabase with project credentials
  await Supabase.initialize(
    url: 'https://dhqvrmchdzcqwkoqunsn.supabase.co',
    publishableKey: 'sb_publishable_nBUf8m5n_WjwG3zMNvSc3g_y4YYBSTS',
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const EnnoiaApp(),
    ),
  );
}

class EnnoiaApp extends ConsumerWidget {
  const EnnoiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Ennoia',
      theme: PortalTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return GlobalFeedbackOverlay(child: child!);
      },
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'THE REMAINDER PORTAL',
                    style: PortalTheme.statsText.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 11.0,
                      color: PortalTheme.charcoalNearBlackText,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: PortalTheme.charcoalNearBlackText, size: 20.0),
                      onPressed: () {},
                    ),
                  ],
                  iconTheme: const IconThemeData(color: PortalTheme.charcoalNearBlackText),
                ),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: _buildSidebar(context, ref),
                ),
          body: IridescentOverlay(
            child: SafeArea(
              child: ResponsiveLayout(
                mobile: _buildMobileLayout(context, ref),
                tablet: _buildTabletLayout(context, ref),
                desktop: _buildDesktopLayout(context, ref),
              ),
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : _buildBottomNavBar(context, ref),
        );
      },
    );
  }

  // --- MOBILE LAYOUT (< 600dp) ---
  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider).value;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      children: [
        _buildCharacterCard(activeChar),
        const SizedBox(height: 24.0),
        _buildStatsRow(activeChar),
        const SizedBox(height: 24.0),
        _buildChroniclesSection(),
        const SizedBox(height: 24.0),
        const FactionInfluenceBoard(),
        const SizedBox(height: 24.0),
        Text(
          'ACTIVE SECTOR BEACONS',
          style: PortalTheme.statsText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        _buildCollectionGrid(crossAxisCount: 1, ref: ref),
      ],
    );
  }

  // --- TABLET LAYOUT (600dp - 899dp) ---
  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider).value;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
      children: [
        _buildCharacterCard(activeChar),
        const SizedBox(height: 28.0),
        _buildStatsRow(activeChar),
        const SizedBox(height: 28.0),
        _buildChroniclesSection(),
        const SizedBox(height: 28.0),
        const FactionInfluenceBoard(),
        const SizedBox(height: 28.0),
        Text(
          'ACTIVE SECTOR BEACONS',
          style: PortalTheme.statsText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14.0),
        _buildCollectionGrid(crossAxisCount: 2, ref: ref),
      ],
    );
  }

  // --- DESKTOP LAYOUT (900dp+) ---
  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider).value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Navigation Sidebar (Gallery style)
        _buildSidebar(context, ref),
        const VerticalDivider(width: 1),
        // Main Scrollable Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE REMAINDER PORTAL',
                  style: PortalTheme.statsText.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 32.0),
                _buildCharacterCard(activeChar),
                const SizedBox(height: 32.0),
                _buildStatsRow(activeChar),
                const SizedBox(height: 32.0),
                _buildChroniclesSection(),
                const SizedBox(height: 32.0),
                const FactionInfluenceBoard(),
                const SizedBox(height: 32.0),
                Text(
                  'ACTIVE SECTOR BEACONS',
                  style: PortalTheme.statsText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 10.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                _buildCollectionGrid(crossAxisCount: 3, ref: ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildBottomNavBar(BuildContext context, WidgetRef ref) {
    return Container(
      height: 72.0,
      decoration: BoxDecoration(
        color: PortalTheme.lightGraySurface.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, ref, Icons.auto_stories_outlined, 'Chronicles', '/', true),
            _buildNavItem(context, ref, Icons.person_outline, 'Profile', '/profile', false),
            _buildNavItem(context, ref, Icons.people_outline, 'Roster', '/roster', false),
            _buildNavItem(context, ref, Icons.map_outlined, 'Timeline', '/chronicles', false),
            _buildNavItem(context, ref, Icons.question_answer_outlined, 'Chat', '/chat', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon, String label, String route, bool isActive) {
    return Expanded(
      child: SpringTapWrapper(
        onTap: () {
          ref.read(routerProvider).go(route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.warmGrayBodyText,
              size: 20.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: PortalTheme.statsText.copyWith(
                fontSize: 8.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.warmGrayBodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(RosterMember? activeChar) {
    final name = activeChar?.characterName ?? 'NO IDENTITY ACTIVATED';
    final faction = activeChar?.faction ?? 'Unknown Sector';
    final faceclaim = activeChar?.faceclaimName ?? 'Default Hologram';
    
    // Deterministic level and stats based on name hash for visual completion
    final hash = name.hashCode;
    final level = (hash % 15) + 5; 
    final classType = (hash % 3 == 0) ? 'Arcane Ranger' : ((hash % 3 == 1) ? 'Obsidian Rogue' : 'Chronicle Cleric');
    final race = (hash % 2 == 0) ? 'Wood Elf' : 'High Human';

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 76.0,
            height: 76.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PortalTheme.tealNavyAccent.withValues(alpha: 0.5), width: 1.5),
              image: activeChar != null && activeChar.faceclaimImgUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(activeChar.faceclaimImgUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: activeChar == null || activeChar.faceclaimImgUrl.isEmpty
                ? const Center(
                    child: Icon(Icons.person, color: PortalTheme.tealNavyAccent, size: 36.0),
                  )
                : null,
          ),
          const SizedBox(width: 20.0),
          // Character Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: PortalTheme.subsectionHeader.copyWith(fontSize: 18.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Level $level $classType • ${faction.toUpperCase()}',
                  style: PortalTheme.bodyText.copyWith(fontSize: 12.5, color: PortalTheme.tealNavyAccent),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    _buildCharacterBadge('RACE: $race'),
                    const SizedBox(width: 8.0),
                    _buildCharacterBadge('FC: $faceclaim'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: PortalTheme.statsText.copyWith(fontSize: 8.5, color: PortalTheme.warmGrayBodyText),
      ),
    );
  }

  Widget _buildStatsRow(RosterMember? activeChar) {
    final name = activeChar?.characterName ?? 'Default';
    final hash = name.hashCode;
    
    // Deterministic stats matching character name
    final str = (hash % 8) + 10;
    final dex = (hash % 10) + 11;
    final con = (hash % 7) + 12;
    final intel = (hash % 9) + 10;
    final wis = (hash % 6) + 13;
    final cha = (hash % 8) + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHARACTER ATTRIBUTES',
          style: PortalTheme.statsText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('STR', str, Icons.fitness_center_outlined),
            _buildStatCard('DEX', dex, Icons.insights_outlined),
            _buildStatCard('CON', con, Icons.favorite_border_outlined),
            _buildStatCard('INT', intel, Icons.psychology_outlined),
            _buildStatCard('WIS', wis, Icons.wb_sunny_outlined),
            _buildStatCard('CHA', cha, Icons.star_border_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12.0, color: PortalTheme.tealNavyAccent),
              const SizedBox(width: 4.0),
              Text(label, style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText)),
            ],
          ),
          const SizedBox(height: 2.0),
          Text('$value', style: PortalTheme.statsText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChroniclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE CHRONICLES',
          style: PortalTheme.statsText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        GlassCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CURRENT QUEST',
                    style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.tealNavyAccent),
                  ),
                  Text(
                    '85% COMPLETE',
                    style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.successMoss),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'The Whisper of Void',
                style: PortalTheme.subsectionHeader.copyWith(fontSize: 18.0),
              ),
              const SizedBox(height: 6.0),
              Text(
                'A desynchronization anomaly detected in the Sanctuary Core. The timeline clockwork has slipped. Archive operations must proceed to stabilize the memory grids.',
                style: PortalTheme.smallText,
              ),
              const SizedBox(height: 16.0),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: const LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 4.0,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(PortalTheme.tealNavyAccent),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('XP: 14,250 / 22,000', style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText)),
                  Row(
                    children: [
                      _buildMiniActionButton(Icons.edit_outlined, 'Edit'),
                      const SizedBox(width: 8.0),
                      _buildMiniActionButton(Icons.visibility_outlined, 'View'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.0, color: PortalTheme.tealNavyAccent),
          const SizedBox(width: 4.0),
          Text(label, style: PortalTheme.statsText.copyWith(fontSize: 8.5)),
        ],
      ),
    );
  }

  Widget _buildCollectionGrid({required int crossAxisCount, required WidgetRef ref}) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return roomsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Failed to load active scenes: $err',
            style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta),
          ),
        ),
      ),
      data: (rooms) {
        if (rooms.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No active timeline sectors detected.',
                style: PortalTheme.bodyText,
              ),
            ),
          );
        }

        Widget buildCard(ChatRoom room) {
          // Deterministic activity markers for realistic gameplay feel
          final mockWriters = (room.id.hashCode % 3) + 2; 
          final mockTotalLogs = (room.id.hashCode % 40) + 15;
          final isHighActivity = room.id.hashCode % 2 == 0;
          
          return SpringTapWrapper(
            onTap: () {
              ref.read(routerProvider).go('/chat');
            },
            child: GlassCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LOCATION BEACON',
                        style: PortalTheme.statsText.copyWith(fontSize: 9.0),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: (isHighActivity ? PortalTheme.successMoss : PortalTheme.infoSlate).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          isHighActivity ? 'HIGH ACTIVITY' : 'STABLE',
                          style: PortalTheme.statsText.copyWith(
                            color: isHighActivity ? PortalTheme.successMoss : PortalTheme.infoSlate,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    room.name.toUpperCase(),
                    style: PortalTheme.subsectionHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    room.factionRestriction != null
                        ? 'Exclusive coordinate restricted to members of the ${room.factionRestriction} faction.'
                        : 'A public narrative sector in the Ennoia timeline where players exchange character logs.',
                    style: PortalTheme.smallText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE WRITERS',
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 9.0,
                          color: PortalTheme.warmGrayBodyText,
                        ),
                      ),
                      Text(
                        '$mockWriters ONLINE • $mockTotalLogs LOGS',
                        style: PortalTheme.statsText.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (crossAxisCount == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20.0),
            itemBuilder: (context, index) => buildCard(rooms[index]),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24.0,
            mainAxisSpacing: 24.0,
            mainAxisExtent: 220.0,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) => buildCard(rooms[index]),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280.0,
      color: PortalTheme.lightGraySurface.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo/Brand Marker
          Row(
            children: [
              Container(
                width: 24.0,
                height: 24.0,
                decoration: const BoxDecoration(
                  color: PortalTheme.tealNavyAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'ENNOIA',
                style: PortalTheme.statsText.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 64.0),
          // Links
          _buildSidebarLink(context, ref, 'Dashboard', route: '/', isActive: true),
          const SizedBox(height: 24.0),
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);
              final email = (user?.email ?? '').toLowerCase().trim();
              final isAdmin = email.contains('admin') || email.contains('dev');
              if (!isAdmin) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebarLink(context, ref, 'Admittance Portal', route: '/admittance'),
                  const SizedBox(height: 24.0),
                  _buildSidebarLink(context, ref, 'Developer Debug Hub', route: '/debug-hub'),
                  const SizedBox(height: 24.0),
                ],
              );
            },
          ),
          _buildSidebarLink(context, ref, 'Community Roster', route: '/roster'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Chronicles Timeline', route: '/chronicles'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Profile Settings', route: '/profile'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Chat Channels', route: '/chat'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Playbook Codex', route: '/guide'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Codex Net Feed', route: '/feed'),
          const Spacer(),
          // Interactive Identity Swapper Profile Footer
          Consumer(
            builder: (context, ref, child) {
              final activeCharAsync = ref.watch(activeCharacterProvider);
              return activeCharAsync.maybeWhen(
                data: (activeChar) {
                  if (activeChar == null) return const SizedBox.shrink();
                  
                  final hasImg = activeChar.faceclaimImgUrl.isNotEmpty && activeChar.faceclaimImgUrl.startsWith('http');
                  
                  return SpringTapWrapper(
                    onTap: () => _showIdentitySwitcher(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: PortalTheme.lightGraySurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: PortalTheme.silverGrayBorder.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          if (hasImg)
                            CircleAvatar(
                              radius: 16.0,
                              backgroundImage: NetworkImage(activeChar.faceclaimImgUrl),
                            )
                          else
                            const CircleAvatar(
                              radius: 16.0,
                              backgroundColor: PortalTheme.silverGrayBorder,
                              child: Icon(Icons.person_outline, size: 16.0, color: PortalTheme.charcoalNearBlackText),
                            ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeChar.characterName,
                                  style: PortalTheme.statsText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  activeChar.faction.toUpperCase(),
                                  style: PortalTheme.statsText.copyWith(
                                    fontSize: 9.0,
                                    color: PortalTheme.infoSlate,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.unfold_more, size: 16.0, color: PortalTheme.warmGrayBodyText),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showIdentitySwitcher(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(activeCharacterProvider.notifier);
    final list = notifier.getMyCharacters();
    final active = ref.read(activeCharacterProvider).value;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320.0),
          child: GlassCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SWITCH NARRATIVE IDENTITY',
                  style: PortalTheme.statsText.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: PortalTheme.tealNavyAccent,
                  ),
                ),
                const SizedBox(height: 16.0),
                if (list.isEmpty)
                  Text('No alternative chronicle avatars found.', style: PortalTheme.bodyText)
                else
                  ...list.map((member) {
                    final isCurrent = member.id == active?.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SpringTapWrapper(
                        onTap: () {
                          ref.read(activeCharacterProvider.notifier).switchCharacter(member.id);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: isCurrent ? PortalTheme.tealNavyAccent.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: isCurrent ? PortalTheme.tealNavyAccent : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Small profile photo/placeholder
                              if (member.faceclaimImgUrl.isNotEmpty && member.faceclaimImgUrl.startsWith('http'))
                                CircleAvatar(
                                  radius: 12.0,
                                  backgroundImage: NetworkImage(member.faceclaimImgUrl),
                                )
                              else
                                const CircleAvatar(
                                  radius: 12.0,
                                  backgroundColor: PortalTheme.silverGrayBorder,
                                  child: Icon(Icons.person, size: 12.0, color: Colors.white),
                                ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.characterName,
                                      style: PortalTheme.statsText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    Text(
                                      member.faction.toUpperCase(),
                                      style: PortalTheme.statsText.copyWith(
                                        fontSize: 9.0,
                                        color: PortalTheme.infoSlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrent)
                                const Icon(Icons.check, size: 16.0, color: PortalTheme.tealNavyAccent),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarLink(BuildContext context, WidgetRef ref, String label, {required String route, bool isActive = false}) {
    return SpringTapWrapper(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ref.read(routerProvider).go(route);
      },
      child: Row(
        children: [
          if (isActive) ...[
            Container(
              width: 6.0,
              height: 6.0,
              decoration: const BoxDecoration(
                color: PortalTheme.tealNavyAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10.0),
          ],
          Text(
            label.toUpperCase(),
            style: PortalTheme.statsText.copyWith(
              fontSize: 12.0,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.warmGrayBodyText,
            ),
          ),
        ],
      ),
    );
  }
}
