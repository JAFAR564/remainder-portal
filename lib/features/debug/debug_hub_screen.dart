import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/portal_theme.dart';
import '../../ui/components/glass_card.dart';
import '../../services/debug_reports_service.dart';

class DebugHubScreen extends ConsumerWidget {
  const DebugHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(debugReportsProvider);

    return Scaffold(
      backgroundColor: PortalTheme.creamBg,
      appBar: AppBar(
        title: Text(
          'DEVELOPER DEBUGLOG HUB',
          style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: PortalTheme.charcoalNearBlackText),
            onPressed: () => ref.read(debugReportsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE INCOMING TRANSMISSIONS',
                style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: reportsAsync.when(
                  data: (reports) {
                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          'No debugging logs or feedback submitted yet.',
                          style: PortalTheme.bodyText.copyWith(color: PortalTheme.warmGrayBodyText),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, idx) {
                        final report = reports[idx];
                        final hasScreenshot = report.screenshotBase64 != null && report.screenshotBase64!.isNotEmpty;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            report.routePath?.toUpperCase() ?? 'UNKNOWN PATH',
                                            style: PortalTheme.statsText.copyWith(
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.bold,
                                              color: PortalTheme.tealNavyAccent,
                                            ),
                                          ),
                                        ),
                                        if (report.category != null) ...[
                                          const SizedBox(width: 8.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: (report.category == 'UI Bug' ? PortalTheme.alertTerracotta : PortalTheme.infoSlate).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              report.category!.toUpperCase(),
                                              style: PortalTheme.statsText.copyWith(
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.bold,
                                                color: report.category == 'UI Bug' ? PortalTheme.alertTerracotta : PortalTheme.infoSlate,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      report.createdAt?.substring(0, 10) ?? '',
                                      style: PortalTheme.statsText.copyWith(fontSize: 9.0, color: PortalTheme.warmGrayBodyText),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  report.comment ?? 'No additional description provided.',
                                  style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                                ),
                                const SizedBox(height: 16.0),
                                const Divider(),
                                const SizedBox(height: 8.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'SUBMITTER IDENTITY',
                                            style: PortalTheme.statsText.copyWith(fontSize: 8.0, color: PortalTheme.warmGrayBodyText),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            report.characterName,
                                            style: PortalTheme.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 11.5),
                                          ),
                                          Text(
                                            report.applicantEmail,
                                            style: PortalTheme.smallText.copyWith(color: PortalTheme.infoSlate),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasScreenshot) ...[
                                      const SizedBox(width: 12.0),
                                      GestureDetector(
                                        onTap: () => _showFullscreenScreenshot(context, report.screenshotBase64!),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 70.0,
                                              height: 70.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: PortalTheme.silverGrayBorder),
                                                borderRadius: BorderRadius.circular(6.0),
                                                image: DecorationImage(
                                                  image: MemoryImage(base64Decode(report.screenshotBase64!)),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 70.0,
                                              height: 70.0,
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius: BorderRadius.circular(6.0),
                                              ),
                                              child: const Icon(Icons.zoom_in, color: Colors.white, size: 20.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: PortalTheme.tealNavyAccent)),
                  error: (err, stack) => Center(child: Text('Error loading debug reports: $err', style: PortalTheme.bodyText)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenScreenshot(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(base64Image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
