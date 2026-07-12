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
        );
      },
    );
  }

  // --- MOBILE LAYOUT (< 600dp) ---
  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      children: [
        _buildHeader(isMobile: true),
        const SizedBox(height: 32.0),
        _buildHeroSection(),
        const SizedBox(height: 24.0),
        const FactionInfluenceBoard(),
        const SizedBox(height: 24.0),
        _buildCollectionGrid(crossAxisCount: 1, ref: ref),
      ],
    );
  }

  // --- TABLET LAYOUT (600dp - 899dp) ---
  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      children: [
        _buildHeader(isMobile: false),
        const SizedBox(height: 40.0),
        _buildHeroSection(),
        const SizedBox(height: 32.0),
        const FactionInfluenceBoard(),
        const SizedBox(height: 32.0),
        _buildCollectionGrid(crossAxisCount: 2, ref: ref),
      ],
    );
  }

  // --- DESKTOP LAYOUT (900dp+) ---
  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Navigation Sidebar (Gallery style)
        _buildSidebar(context, ref),
        const VerticalDivider(width: 1),
        // Main Scrollable Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile: false),
                const SizedBox(height: 40.0),
                _buildHeroSection(),
                const SizedBox(height: 40.0),
                const FactionInfluenceBoard(),
                const SizedBox(height: 40.0),
                _buildCollectionGrid(crossAxisCount: 3, ref: ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildHeader({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENNOIA',
          style: PortalTheme.displayHeadline.copyWith(
            fontSize: isMobile ? 32.0 : 48.0,
            letterSpacing: 0.04 * (isMobile ? 32.0 : 48.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'The official administrative hub for our chronicle timeline and roleplay sanctuary.',
          style: PortalTheme.bodyText,
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SpringTapWrapper(
      onTap: () {
        debugPrint('Hero Card tapped');
      },
      child: GlassCard(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: PortalTheme.tealNavyAccent,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'LATEST TRANSMISSION',
                    style: PortalTheme.statsText.copyWith(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'TIMELINE SPLIT',
                  style: PortalTheme.statsText.copyWith(
                    color: PortalTheme.alertTerracotta,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Text(
              'A Chronicle from the Timeworn Sanctuary',
              style: PortalTheme.sectionHeader,
            ),
            const SizedBox(height: 12.0),
            Text(
              'The temporal clockwork has ticked. We are currently recording the timeline events for the Elysium Syndicate and Aethelgard Alliance. All members must submit their chronicle updates to prevent desynchronization.',
              style: PortalTheme.bodyText,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SECTOR: SANCTUARY CORE',
                  style: PortalTheme.statsText,
                ),
                Text(
                  'STATUS: SYNCHRONIZED',
                  style: PortalTheme.statsText.copyWith(
                    color: PortalTheme.successMoss,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          itemBuilder: (context, index) {
            final room = rooms[index];
            
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
          },
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
                  }).toList(),
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
