import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/application.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../ui/components/responsive_layout.dart';
import 'providers/admittance_provider.dart';
import 'providers/ai_grading_provider.dart';

class AdmittanceScreen extends ConsumerStatefulWidget {
  const AdmittanceScreen({super.key});

  @override
  ConsumerState<AdmittanceScreen> createState() => _AdmittanceScreenState();
}

class _AdmittanceScreenState extends ConsumerState<AdmittanceScreen> {
  Application? _selectedApplication;

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(admittanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADMINISTRATIVE ADMITTANCE PORTAL',
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: IridescentOverlay(
        child: SafeArea(
          child: Column(
            children: [
              if (ref.watch(admittanceOfflineProvider))
                Container(
                  width: double.infinity,
                  color: PortalTheme.alertTerracotta.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: PortalTheme.alertTerracotta, size: 16.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'CONNECTION OFFLINE; DISPLAYING CACHED SYNC',
                          style: PortalTheme.statsText.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: PortalTheme.alertTerracotta,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: pendingAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Failed to load applications: $err',
                      style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta),
                    ),
                  ),
                  data: (applications) {
                    if (applications.isEmpty) {
                      return Center(
                        child: Text(
                          'No pending admittance applications.',
                          style: PortalTheme.bodyText,
                        ),
                      );
                    }

                    // Auto-select first application if none selected or if selected is no longer pending
                    if (_selectedApplication == null ||
                        !applications.any((a) => a.id == _selectedApplication!.id)) {
                      _selectedApplication = applications.first;
                    }

                    return ResponsiveLayout(
                      mobile: _buildMobileLayout(context, applications),
                      tablet: _buildTabletLayout(context, applications),
                      desktop: _buildDesktopLayout(context, applications),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context, List<Application> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final app = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
                    child: SpringTapWrapper(
            onTap: () => _showApplicationDetailsBottomSheet(context, app),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text(app.characterName, style: PortalTheme.sectionHeader.copyWith(fontSize: 18.0)),
                subtitle: Text('Faction: ${app.faction} • ${app.applicantEmail}', style: PortalTheme.bodyText),
                trailing: const Icon(Icons.chevron_right, color: PortalTheme.tealNavyAccent),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TABLET LAYOUT ---
  Widget _buildTabletLayout(BuildContext context, List<Application> list) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final app = list[index];
              final isSelected = app.id == _selectedApplication?.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SpringTapWrapper(
                  onTap: () => setState(() => _selectedApplication = app),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    backgroundColor: isSelected
                        ? PortalTheme.tealNavyAccent.withValues(alpha: 0.1)
                        : null,
                    child: ListTile(
                      title: Text(app.characterName, style: PortalTheme.sectionHeader.copyWith(fontSize: 18.0)),
                      subtitle: Text(app.faction, style: PortalTheme.bodyText),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: _selectedApplication != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildDetailsPanel(_selectedApplication!),
                )
              : const Center(child: Text('Select an application to grade.')),
        ),
      ],
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BuildContext context, List<Application> list) {
    return Row(
      children: [
        // Left Column: List of pending applicants
        Container(
          width: 320.0,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PENDING CLAIMS',
                style: PortalTheme.statsText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PortalTheme.warmGrayBodyText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final app = list[index];
                    final isSelected = app.id == _selectedApplication?.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SpringTapWrapper(
                        onTap: () => setState(() => _selectedApplication = app),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16.0),
                          backgroundColor: isSelected
                              ? PortalTheme.tealNavyAccent.withValues(alpha: 0.08)
                              : null,
                          hasBorder: isSelected,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.characterName,
                                  style: PortalTheme.sectionHeader.copyWith(
                                    fontSize: 16.0,
                                    color: isSelected ? PortalTheme.tealNavyAccent : null,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  app.faction.toUpperCase(),
                                  style: PortalTheme.statsText.copyWith(
                                    fontSize: 10.0,
                                    color: PortalTheme.infoSlate,
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Column: Side-by-Side Application Details & AI Diagnostics
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Applicant Sheet Answers
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildApplicantInfoCard(_selectedApplication!),
                ),
              ),
              const VerticalDivider(width: 1),
              // Column 2: AI Diagnostic Panel
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildAIDiagnosticCard(_selectedApplication!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- DETAILS BOTTOM SHEET FOR MOBILE ---
  void _showApplicationDetailsBottomSheet(BuildContext context, Application app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: PortalTheme.creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: _buildDetailsPanel(app),
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGET PANELS ---

  Widget _buildDetailsPanel(Application app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildApplicantInfoCard(app),
        const SizedBox(height: 24.0),
        const Divider(),
        const SizedBox(height: 24.0),
        _buildAIDiagnosticCard(app),
      ],
    );
  }

  Widget _buildApplicantInfoCard(Application app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(app.characterName, style: PortalTheme.displayHeadline.copyWith(fontSize: 28.0)),
        const SizedBox(height: 8.0),
        Text('FACTION: ${app.faction.toUpperCase()}', style: PortalTheme.statsText.copyWith(color: PortalTheme.infoSlate)),
        Text('APPLICANT: ${app.applicantEmail}', style: PortalTheme.bodyText),
        const SizedBox(height: 24.0),
        Text('ANSWER SHEET PROTOCOLS', style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        ...List.generate(app.answers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUERY #${index + 1}',
                  style: PortalTheme.statsText.copyWith(
                    fontSize: 10.0,
                    color: PortalTheme.warmGrayBodyText,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  app.answers[index],
                  style: PortalTheme.bodyText.copyWith(
                    color: PortalTheme.charcoalNearBlackText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAIDiagnosticCard(Application app) {
    final gradingAsync = ref.watch(aiGradingProvider);

    // Trigger evaluation on post-frame callback to avoid build-phase state modifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiGradingProvider.notifier).evaluateApplication(app.id);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI AUDIT OVERVIEW', style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24.0),
        gradingAsync.when(
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16.0),
                  Text('Executing parallel LLM evaluations...', style: PortalTheme.bodyText),
                ],
              ),
            ),
          ),
          error: (err, stack) => Text('Grading execution failed: $err', style: PortalTheme.bodyText.copyWith(color: PortalTheme.alertTerracotta)),
          data: (gradesMap) {
            final result = gradesMap[app.id];
            if (result == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16.0),
                      Text('Initializing parallel LLM evaluations...', style: PortalTheme.bodyText),
                    ],
                  ),
                ),
              );
            }
            final isFail = result.deepseekScore < 6.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score Card
                GlassCard(
                  backgroundColor: isFail
                      ? PortalTheme.alertTerracotta.withValues(alpha: 0.05)
                      : PortalTheme.successMoss.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LORE COMPLIANCE', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                            const SizedBox(height: 4.0),
                            Text(
                              '${result.deepseekScore} / 10.0',
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: isFail ? PortalTheme.alertTerracotta : PortalTheme.successMoss,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isFail ? PortalTheme.alertTerracotta : PortalTheme.successMoss,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            isFail ? 'WARNING' : 'PASSED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Rule validation flags
                Text('FORMATTING & STYLE FLAGS (GROQ)', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: result.groqFlags.map((flag) {
                    final isErr = flag.toLowerCase().contains('error') || flag.toLowerCase().contains('warning');
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isErr
                            ? PortalTheme.alertTerracotta.withValues(alpha: 0.1)
                            : PortalTheme.lightGraySurface,
                        border: Border.all(
                          color: isErr ? PortalTheme.alertTerracotta : PortalTheme.silverGrayBorder,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        flag,
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 10.0,
                          color: isErr ? PortalTheme.alertTerracotta : PortalTheme.charcoalNearBlackText,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),

                // Diagnostics textual summaries
                Text('LORE CRITIQUE (DEEPSEEK)', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                const SizedBox(height: 8.0),
                Text(result.loreAnalysis, style: PortalTheme.bodyText.copyWith(height: 1.5)),
                const SizedBox(height: 24.0),
                Text('FORMATTING DIAGNOSTIC', style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText)),
                const SizedBox(height: 8.0),
                Text(result.formattingAnalysis, style: PortalTheme.bodyText.copyWith(height: 1.5)),
                const SizedBox(height: 32.0),

                // Decision Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () => _submitDecision(app.id, 'Approved', result.deepseekScore, result.groqFlags),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.successMoss,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'APPROVE ENTRY',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () => _submitDecision(app.id, 'Rejected', result.deepseekScore, result.groqFlags),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.alertTerracotta,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'REJECT CLAIM',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _submitDecision(
    String appId,
    String decision,
    double score,
    List<String> flags,
  ) async {
    try {
      await ref.read(admittanceNotifierProvider.notifier).decideApplication(
            appId: appId,
            decision: decision,
            deepseekScore: score,
            groqFlags: flags,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application $decision successfully.'),
            backgroundColor: PortalTheme.tealNavyAccent,
          ),
        );
        // Dismiss the bottom sheet or pop route safely
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process decision: $e'),
            backgroundColor: PortalTheme.alertTerracotta,
          ),
        );
      }
    }
  }
}
