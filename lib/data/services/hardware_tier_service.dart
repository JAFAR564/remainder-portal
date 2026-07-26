import 'dart:io';

enum HardwareTier { budget, midRange, flagship }

class DeviceHardwareProfile {
  final HardwareTier tier;
  final int totalRamMb;
  final int processorCores;
  final bool hasDedicatedNpu;
  final String platformName;

  DeviceHardwareProfile({
    required this.tier,
    required this.totalRamMb,
    required this.processorCores,
    required this.hasDedicatedNpu,
    required this.platformName,
  });

  bool get supportsOnDeviceAi => tier == HardwareTier.flagship && hasDedicatedNpu;
}

class HardwareTierService {
  /// Detects device hardware characteristics and classifies into Tier B (Budget), Tier A (Mid-Range), or Tier S (Flagship).
  static DeviceHardwareProfile detectHardwareProfile() {
    final cores = Platform.numberOfProcessors;
    final isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    // Simulated RAM detection baseline (Desktop gets 16GB, mobile scales by core count heuristics)
    int estimatedRamMb = isDesktop ? 16384 : (cores >= 8 ? 6144 : (cores >= 6 ? 4096 : 2048));
    bool npu = isDesktop || cores >= 8;

    HardwareTier tier;
    if (estimatedRamMb >= 8192 || (isDesktop && cores >= 8)) {
      tier = HardwareTier.flagship;
    } else if (estimatedRamMb >= 4096) {
      tier = HardwareTier.midRange;
    } else {
      tier = HardwareTier.budget;
    }

    return DeviceHardwareProfile(
      tier: tier,
      totalRamMb: estimatedRamMb,
      processorCores: cores,
      hasDedicatedNpu: npu,
      platformName: Platform.operatingSystem.toUpperCase(),
    );
  }
}
