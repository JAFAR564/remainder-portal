import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/presentation_provider.dart';
import '../../data/services/hardware_tier_service.dart';
import '../widgets/crt_overlay.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);
    final profile = settings.hardwareProfile;

    final String tierName = profile.tier == HardwareTier.flagship
        ? 'TIER S (FLAGSHIP / DESKTOP)'
        : (profile.tier == HardwareTier.midRange ? 'TIER A (MID-RANGE)' : 'TIER B (BUDGET)');

    final Color tierColor = profile.tier == HardwareTier.flagship
        ? const Color(0xFF00F0FF)
        : (profile.tier == HardwareTier.midRange ? const Color(0xFFFFD166) : const Color(0xFFFF8E3C));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'VISOR SYSTEM & HARDWARE SETTINGS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161520),
        elevation: 0,
        centerTitle: true,
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Hardware Profile Card
                Card(
                  color: const Color(0xFF161520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: tierColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'HARDWARE CLASSIFICATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: tierColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tierName,
                                style: TextStyle(
                                  color: tierColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PLATFORM: ${profile.platformName} | CORES: ${profile.processorCores} | EST. RAM: ${profile.totalRamMb} MB',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DEDICATED NPU ACCELERATOR: ${profile.hasDedicatedNpu ? "ACTIVE" : "UNAVAILABLE"}',
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Experimental On-Device LiteRT AI Section
                Card(
                  color: const Color(0xFF0A0910),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                  ),
                  child: SwitchListTile(
                    activeColor: const Color(0xFF00F0FF),
                    title: const Text(
                      'EXPERIMENTAL LOCAL LiteRT GEMMA AI',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    subtitle: Text(
                      profile.tier == HardwareTier.flagship
                          ? 'Runs quantized Gemma 3 (1B) directly on local hardware.'
                          : 'Locked on budget/mid-range devices to prevent memory crashes. Uses Cloud AI + d20 Rule Engine.',
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                    value: settings.enableOnDeviceAi,
                    onChanged: profile.tier == HardwareTier.flagship
                        ? (val) => notifier.setOnDeviceAi(val)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Presentation & Visual Preferences
                const Text(
                  'PRESENTATION & ACCESSIBILITY',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),

                Card(
                  color: const Color(0xFF161520),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: const Color(0xFFE53170),
                        title: const Text('CRT SCANLINES OVERLAY', style: TextStyle(color: Colors.white, fontSize: 12)),
                        subtitle: const TextStyle(color: Colors.white54, fontSize: 10) != null
                            ? Text('Retro CRT scanline effect (Adaptive Opacity: ${(settings.scanlineOpacity * 100).toStringAsFixed(1)}%)', style: const TextStyle(color: Colors.white54, fontSize: 10))
                            : null,
                        value: settings.enableCrtScanlines,
                        onChanged: (val) => notifier.toggleCrtScanlines(val),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      SwitchListTile(
                        activeColor: const Color(0xFFFF8E3C),
                        title: const Text('CHROMATIC ABERRATION & VIGNETTE', style: TextStyle(color: Colors.white, fontSize: 12)),
                        value: settings.enableChromaticAberration,
                        onChanged: (val) => notifier.toggleChromaticAberration(val),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      SwitchListTile(
                        activeColor: const Color(0xFF38B000),
                        title: const Text('REDUCED MOTION MODE', style: TextStyle(color: Colors.white, fontSize: 12)),
                        subtitle: const Text('Disables animations, scanlines, and particle effects for accessibility.', style: TextStyle(color: Colors.white54, fontSize: 10)),
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
      ),
    );
  }
}
