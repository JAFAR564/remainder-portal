import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  int _activeTab = 0;

  final List<Map<String, dynamic>> _codexChapters = [
    {
      'title': 'SECTOR ADMITTANCE',
      'icon': Icons.assignment_ind_outlined,
      'summary': 'How to apply for sanctuary and claim character slots.',
      'details': [
        '1. Open the Admittance Portal sidebar action.',
        '2. Fill in your Character Name, Bios, and choose your faction alignment.',
        '3. Enter your faceclaim actor name and run the check reservation scanner.',
        '4. Once verified, character sheet metadata automatically binds to your profile ledger.',
      ]
    },
    {
      'title': 'PORTFOLIO BINDER',
      'icon': Icons.folder_shared_outlined,
      'summary': 'Managing multiple alternate characters on a single account.',
      'details': [
        '1. Go to Profile Settings and scroll to the Character Portfolio Binder.',
        '2. All your approved roster sheets are listed as interactive cards.',
        '3. Tapping a card swaps your active avatar identity instantly across channels.',
        '4. Message headers, avatars, and logs will update live matching your selection.',
      ]
    },
    {
      'title': 'CHAT CHAMBERS',
      'icon': Icons.forum_outlined,
      'summary': 'Navigating location coordinates and in-line action dice checks.',
      'details': [
        '1. Public forums are open to all; restricted chambers filter rooms by active faction.',
        '2. Chat headers show the active presence list of other online writers in the chamber.',
        '3. Tap the casino-die button next to the message composer to prompt skill checks.',
        '4. Select a skill (Intellect, Willpower) to perform rolls, rendered as styled roll cards.',
      ]
    },
    {
      'title': 'CHRONICLE TIMELINE',
      'icon': Icons.history_toggle_off_outlined,
      'summary': 'Compiling scene logs and publishing timeline nodes.',
      'details': [
        '1. Tap the "START SCENE" logging button in the chat sub-header to initiate tracking.',
        '2. Once completed, tap "FINISH SCENE" to gather logs and open the compiler dialog.',
        '3. Enter your title, description, and submit to publish the scene to the Chronicles.',
        '4. The timeline updates with faction influence progress shift meters and transcripts.',
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REMAINDER PORTAL CODEX',
          style: PortalTheme.statsText.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: IridescentOverlay(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750.0),
                child: Column(
                  children: [
                    // Visual Logo Header
                    _buildLogoHeader(),
                    const SizedBox(height: 32.0),

                    // Codex Grid Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left sidebar tabs
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: List.generate(_codexChapters.length, (idx) {
                              final chap = _codexChapters[idx];
                              final isActive = _activeTab == idx;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SpringTapWrapper(
                                  onTap: () => setState(() => _activeTab = idx),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(16.0),
                                    backgroundColor: isActive
                                        ? PortalTheme.tealNavyAccent.withValues(alpha: 0.1)
                                        : null,
                                    hasBorder: isActive,
                                    child: Row(
                                      children: [
                                        Icon(
                                          chap['icon'],
                                          color: isActive ? PortalTheme.tealNavyAccent : PortalTheme.infoSlate,
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Text(
                                            chap['title'],
                                            style: PortalTheme.statsText.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.0,
                                              color: isActive ? PortalTheme.tealNavyAccent : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 24.0),

                        // Right content display
                        Expanded(
                          flex: 5,
                          child: GlassCard(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _codexChapters[_activeTab]['icon'],
                                  size: 32.0,
                                  color: PortalTheme.tealNavyAccent,
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  _codexChapters[_activeTab]['title'],
                                  style: PortalTheme.subsectionHeader.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  _codexChapters[_activeTab]['summary'],
                                  style: PortalTheme.bodyText.copyWith(
                                    color: PortalTheme.warmGrayBodyText,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                const Divider(),
                                const SizedBox(height: 24.0),
                                ...(_codexChapters[_activeTab]['details'] as List<String>).map((step) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Text(
                                      step,
                                      style: PortalTheme.bodyText.copyWith(
                                        fontSize: 13.0,
                                        height: 1.5,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // Vector-drawn representation of the logo mark
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                PortalTheme.infoSlate.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: PortalTheme.tealNavyAccent.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                blurRadius: 16.0,
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Portal horizon
                Container(
                  width: 54.0,
                  height: 54.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PortalTheme.tealNavyAccent,
                      width: 2.0,
                    ),
                  ),
                ),
                Text(
                  'R',
                  style: PortalTheme.displayHeadline.copyWith(
                    fontSize: 32.0,
                    color: PortalTheme.charcoalNearBlackText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'REMAINDER PORTAL',
          style: PortalTheme.statsText.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'CO-OP SANDBOX PLAYBOOK',
          style: PortalTheme.smallText.copyWith(color: PortalTheme.infoSlate),
        ),
      ],
    );
  }
}
