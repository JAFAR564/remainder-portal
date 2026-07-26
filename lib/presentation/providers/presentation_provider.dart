import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/hardware_tier_service.dart';

class PresentationSettingsModel {
  final DeviceHardwareProfile hardwareProfile;
  final bool enableOnDeviceAi;
  final bool enableCrtScanlines;
  final double scanlineOpacity;
  final bool enableChromaticAberration;
  final int particleDensity;
  final bool enableAudioVisorGlow;
  final bool reducedMotion;

  PresentationSettingsModel({
    required this.hardwareProfile,
    this.enableOnDeviceAi = false,
    this.enableCrtScanlines = true,
    this.scanlineOpacity = 0.025,
    this.enableChromaticAberration = true,
    this.particleDensity = 25,
    this.enableAudioVisorGlow = true,
    this.reducedMotion = false,
  });

  PresentationSettingsModel copyWith({
    bool? enableOnDeviceAi,
    bool? enableCrtScanlines,
    double? scanlineOpacity,
    bool? enableChromaticAberration,
    int? particleDensity,
    bool? enableAudioVisorGlow,
    bool? reducedMotion,
  }) {
    return PresentationSettingsModel(
      hardwareProfile: hardwareProfile,
      enableOnDeviceAi: enableOnDeviceAi ?? this.enableOnDeviceAi,
      enableCrtScanlines: enableCrtScanlines ?? this.enableCrtScanlines,
      scanlineOpacity: scanlineOpacity ?? this.scanlineOpacity,
      enableChromaticAberration: enableChromaticAberration ?? this.enableChromaticAberration,
      particleDensity: particleDensity ?? this.particleDensity,
      enableAudioVisorGlow: enableAudioVisorGlow ?? this.enableAudioVisorGlow,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

class PresentationNotifier extends StateNotifier<PresentationSettingsModel> {
  PresentationNotifier()
      : super(() {
          final profile = HardwareTierService.detectHardwareProfile();
          final isBudget = profile.tier == HardwareTier.budget;
          final isFlagship = profile.tier == HardwareTier.flagship;

          return PresentationSettingsModel(
            hardwareProfile: profile,
            enableOnDeviceAi: false,
            enableCrtScanlines: true,
            scanlineOpacity: isBudget ? 0.015 : 0.035,
            enableChromaticAberration: !isBudget,
            particleDensity: isBudget ? 10 : (isFlagship ? 40 : 25),
            enableAudioVisorGlow: !isBudget,
            reducedMotion: false,
          );
        }());

  bool setOnDeviceAi(bool enabled) {
    if (enabled && state.hardwareProfile.tier != HardwareTier.flagship) {
      return false; // Locked for non-flagship devices
    }
    state = state.copyWith(enableOnDeviceAi: enabled);
    return true;
  }

  void toggleCrtScanlines(bool enabled) {
    state = state.copyWith(enableCrtScanlines: enabled);
  }

  void toggleChromaticAberration(bool enabled) {
    state = state.copyWith(enableChromaticAberration: enabled);
  }

  void setParticleDensity(int density) {
    state = state.copyWith(particleDensity: density.clamp(0, 50));
  }

  void toggleReducedMotion(bool enabled) {
    state = state.copyWith(
      reducedMotion: enabled,
      enableCrtScanlines: !enabled,
      particleDensity: enabled ? 0 : state.particleDensity,
    );
  }
}

final presentationProvider = StateNotifierProvider<PresentationNotifier, PresentationSettingsModel>((ref) {
  return PresentationNotifier();
});
