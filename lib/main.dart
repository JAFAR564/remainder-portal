import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'services/roster_cache_service.dart';
import 'theme/portal_theme.dart';
import 'ui/animations/spring_tap_wrapper.dart';
import 'ui/components/glass_card.dart';
import 'ui/components/iridescent_overlay.dart';
import 'ui/components/responsive_layout.dart';

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
                mobile: _buildMobileLayout(context),
                tablet: _buildTabletLayout(context),
                desktop: _buildDesktopLayout(context, ref),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- MOBILE LAYOUT (< 600dp) ---
  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      children: [
        _buildHeader(isMobile: true),
        const SizedBox(height: 32.0),
        _buildHeroSection(),
        const SizedBox(height: 24.0),
        _buildCollectionGrid(crossAxisCount: 1),
      ],
    );
  }

  // --- TABLET LAYOUT (600dp - 899dp) ---
  Widget _buildTabletLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      children: [
        _buildHeader(isMobile: false),
        const SizedBox(height: 40.0),
        _buildHeroSection(),
        const SizedBox(height: 32.0),
        _buildCollectionGrid(crossAxisCount: 2),
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
                _buildCollectionGrid(crossAxisCount: 3),
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

  Widget _buildCollectionGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24.0,
        mainAxisSpacing: 24.0,
        mainAxisExtent: 220.0,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final titles = [
          'Faceclaim Registrar',
          'Timeline Sync',
          'Sanctuary Admission'
        ];
        final labels = ['REGISTRATIONS', 'TIMELINE STATUS', 'GRADING ENGINE'];
        final statusColor = [
          PortalTheme.successMoss,
          PortalTheme.infoSlate,
          PortalTheme.successMoss
        ];
        final statusText = ['ONLINE', 'STABLE', 'AI ROUTER ACTIVE'];
        final details = [
          '28 active claims registered in the database. Ensure faceclaims are unique to prevent duplicate warnings.',
          'The chronicles timeline shows active temporal splits. Review recent history under the Chronicles section.',
          'Admittance requests are graded under the Gemini RAG pipelines and DeepSeek verification rules.'
        ];
        final footerLeft = [
          'ACTIVE CLAIMS',
          'TEMPORAL SPLITS',
          'PENDING QUEUE'
        ];
        final footerRight = [
          '28 ACTIVE',
          '0 WARNS',
          'ACTIVE'
        ];

        return SpringTapWrapper(
          onTap: () {
            debugPrint('Grid Item ${index + 1} tapped');
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
                      labels[index],
                      style: PortalTheme.statsText.copyWith(fontSize: 9.0),
                    ),
                    Text(
                      statusText[index],
                      style: PortalTheme.statsText.copyWith(
                        color: statusColor[index],
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  titles[index],
                  style: PortalTheme.subsectionHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  details[index],
                  style: PortalTheme.smallText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      footerLeft[index],
                      style: PortalTheme.statsText.copyWith(
                        fontSize: 9.0,
                        color: PortalTheme.warmGrayBodyText,
                      ),
                    ),
                    Text(
                      footerRight[index],
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
                'RP PORTAL',
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
          _buildSidebarLink(context, ref, 'Admittance Portal', route: '/admittance'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Community Roster', route: '/roster'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Chronicles Timeline', route: '/chronicles'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Profile Settings', route: '/profile'),
          const SizedBox(height: 24.0),
          _buildSidebarLink(context, ref, 'Chat Channels', route: '/chat'),
          const Spacer(),
          // Profile Footer
          Row(
            children: [
              const CircleAvatar(
                radius: 18.0,
                backgroundColor: PortalTheme.silverGrayBorder,
                child: Icon(Icons.person_outline, color: PortalTheme.charcoalNearBlackText),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collector #01',
                    style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Premium Tier',
                    style: PortalTheme.statsText.copyWith(fontSize: 11.0, color: PortalTheme.infoSlate),
                  ),
                ],
              )
            ],
          )
        ],
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
