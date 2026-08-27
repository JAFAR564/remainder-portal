import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/gemma_model_downloader_service.dart';
import '../../data/services/hardware_tier_service.dart';
import '../providers/presentation_provider.dart';
import '../widgets/crt_overlay.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);
    final profile = settings.hardwareProfile;
    final progress = settings.downloadProgress;

    final String tierName = profile.tier == HardwareTier.flagship
        ? 'TIER S (FLAGSHIP / DESKTOP)'
        : (profile.tier == HardwareTier.midRange ? 'TIER A (MID-RANGE)' : 'TIER B (BUDGET)');

    final Color tierColor = profile.tier == HardwareTier.flagship
        ? const Color(0xFF6E473B)
        : (profile.tier == HardwareTier.midRange ? const Color(0xFFA78D78) : const Color(0xFF291C0E));

    final bool isHardwareEligible = profile.tier == HardwareTier.flagship;
    final bool isModelInstalled = progress.status == ModelDownloadState.ready;

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'SOVEREIGN REALM & WORLD SETTINGS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF6E473B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Hardware Profile Card
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'SOUL VESSEL CLASSIFICATION',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF291C0E),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: tierColor),
                            ),
                            child: Text(
                              tierName,
                              style: TextStyle(
                                color: tierColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'PLATFORM: ${profile.platformName} | SPIRIT CORES: ${profile.processorCores} | ESSENCE: ${profile.totalRamMb} MB',
                        style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DIVINE ACCELERATOR: ${profile.hasDedicatedNpu ? "ACTIVE" : "UNAVAILABLE"}',
                        style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // AI Section Card
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ON-DEVICE SPIRITUAL ARBITER (GEMMA)',
                                  style: TextStyle(
                                    color: Color(0xFF291C0E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'On-demand inner realm intelligence execution.',
                                  style: TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            activeColor: const Color(0xFF6E473B),
                            value: settings.enableOnDeviceAi,
                            onChanged: isHardwareEligible && isModelInstalled
                                ? (val) => notifier.setOnDeviceAi(val)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFBEB5A9), height: 1),
                      const SizedBox(height: 12),
                      if (!isHardwareEligible) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFF6E473B), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'HARDWARE GATED: On-device execution locked to prevent memory collapse. Astral Cloud AI active.',
                                  style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        _buildModelDownloaderControls(context, ref, progress, notifier),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Presentation & Visual Preferences
              const Text(
                'PRESENTATION & ACCESSIBILITY',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF6E473B),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: const Color(0xFF6E473B),
                      title: const Text('ANCIENT RUNE GLOW OVERLAY', style: TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Subtle ancient rune aura overlay (Adaptive Opacity: ${(settings.scanlineOpacity * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                      ),
                      value: settings.enableCrtScanlines,
                      onChanged: (val) => notifier.toggleCrtScanlines(val),
                    ),
                    const Divider(color: Color(0xFFBEB5A9), height: 1),
                    SwitchListTile(
                      activeColor: const Color(0xFF6E473B),
                      title: const Text('AETHERIC VIGNETTE & SHADOWS', style: TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.w600)),
                      value: settings.enableChromaticAberration,
                      onChanged: (val) => notifier.toggleChromaticAberration(val),
                    ),
                    const Divider(color: Color(0xFFBEB5A9), height: 1),
                    SwitchListTile(
                      activeColor: const Color(0xFF6E473B),
                      title: const Text('REDUCED MOTION MODE', style: TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Disables animations, scanlines, and particle effects for accessibility.',
                        style: TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                      ),
                      value: settings.reducedMotion,
                      onChanged: (val) => notifier.toggleReducedMotion(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelDownloaderControls(
    BuildContext context,
    WidgetRef ref,
    ModelDownloadProgress progress,
    PresentationNotifier notifier,
  ) {
    String badgeText;
    Color badgeColor;

    switch (progress.status) {
      case ModelDownloadState.ready:
        badgeText = 'INSTALLED & READY';
        badgeColor = const Color(0xFF6E473B);
        break;
      case ModelDownloadState.downloading:
        badgeText = 'DOWNLOADING (${progress.percentage.toStringAsFixed(0)}%)';
        badgeColor = const Color(0xFFA78D78);
        break;
      case ModelDownloadState.paused:
        badgeText = 'PAUSED';
        badgeColor = const Color(0xFFBEB5A9);
        break;
      case ModelDownloadState.verifying:
        badgeText = 'VERIFYING SHA-256';
        badgeColor = const Color(0xFF6E473B);
        break;
      case ModelDownloadState.error:
        badgeText = 'ERROR';
        badgeColor = const Color(0xFF291C0E);
        break;
      case ModelDownloadState.notDownloaded:
      default:
        badgeText = 'NOT INSTALLED';
        badgeColor = const Color(0xFFBEB5A9);
        break;
    }

    final double mbDownloaded = progress.bytesDownloaded / (1024 * 1024);
    final double mbTotal = progress.totalBytes / (1024 * 1024);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GEMMA 3 (1B) WEIGHTS (1.5 GB)',
              style: TextStyle(color: Color(0xFF291C0E), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Progress Metrics and Bar
        if (progress.status == ModelDownloadState.downloading ||
            progress.status == ModelDownloadState.paused ||
            progress.status == ModelDownloadState.verifying) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.status == ModelDownloadState.verifying ? null : (progress.percentage / 100.0),
              backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mbDownloaded.toStringAsFixed(1)} MB / ${mbTotal.toStringAsFixed(1)} MB (${progress.percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace'),
              ),
              if (progress.status == ModelDownloadState.downloading)
                Text(
                  '${progress.downloadSpeedMbS.toStringAsFixed(2)} MB/s',
                  style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        if (progress.status == ModelDownloadState.error && progress.errorMessage != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'ERROR: ${progress.errorMessage}',
              style: const TextStyle(color: Color(0xFF291C0E), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
          ),
        ],

        // Control Buttons
        Row(
          children: [
            if (progress.status == ModelDownloadState.notDownloaded ||
                progress.status == ModelDownloadState.error) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text(
                  'DOWNLOAD MODEL (1.5 GB)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                onPressed: () => notifier.startModelDownload(),
              ),
            ] else if (progress.status == ModelDownloadState.downloading) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6E473B),
                  side: const BorderSide(color: Color(0xFF6E473B)),
                ),
                icon: const Icon(Icons.pause_rounded, size: 16),
                label: const Text('PAUSE', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                onPressed: () => notifier.pauseModelDownload(),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF291C0E)),
                icon: const Icon(Icons.cancel_rounded, size: 16),
                label: const Text('CANCEL', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                onPressed: () => notifier.cancelModelDownload(),
              ),
            ] else if (progress.status == ModelDownloadState.paused) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('RESUME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                onPressed: () => notifier.resumeModelDownload(),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF291C0E)),
                icon: const Icon(Icons.cancel_rounded, size: 16),
                label: const Text('CANCEL', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                onPressed: () => notifier.cancelModelDownload(),
              ),
            ] else if (progress.status == ModelDownloadState.ready) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6E473B),
                  side: const BorderSide(color: Color(0xFF6E473B)),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('DELETE MODEL', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                onPressed: () => notifier.deleteModelWeights(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
