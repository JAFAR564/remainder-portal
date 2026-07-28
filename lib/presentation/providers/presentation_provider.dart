import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/gemma_model_downloader_service.dart';
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
  final ModelDownloadProgress downloadProgress;

  PresentationSettingsModel({
    required this.hardwareProfile,
    this.enableOnDeviceAi = false,
    this.enableCrtScanlines = true,
    this.scanlineOpacity = 0.025,
    this.enableChromaticAberration = true,
    this.particleDensity = 25,
    this.enableAudioVisorGlow = true,
    this.reducedMotion = false,
    ModelDownloadProgress? downloadProgress,
  }) : downloadProgress = downloadProgress ?? ModelDownloadProgress.initial();

  PresentationSettingsModel copyWith({
    bool? enableOnDeviceAi,
    bool? enableCrtScanlines,
    double? scanlineOpacity,
    bool? enableChromaticAberration,
    int? particleDensity,
    bool? enableAudioVisorGlow,
    bool? reducedMotion,
    ModelDownloadProgress? downloadProgress,
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
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

class PresentationNotifier extends StateNotifier<PresentationSettingsModel> {
  final GemmaModelDownloaderService downloaderService;
  StreamSubscription<ModelDownloadProgress>? _downloadSub;

  PresentationNotifier({
    GemmaModelDownloaderService? customDownloader,
  })  : downloaderService = customDownloader ?? GemmaModelDownloaderService(),
        super(() {
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
        }()) {
    _downloadSub = downloaderService.progressStream.listen((progress) {
      final isReady = progress.status == ModelDownloadState.ready;
      state = state.copyWith(
        downloadProgress: progress,
        // Automatically turn off AI if model was deleted/errored
        enableOnDeviceAi: isReady ? state.enableOnDeviceAi : false,
      );
    });

    _initDownloader();
  }

  Future<void> _initDownloader() async {
    await downloaderService.initialize();
    state = state.copyWith(downloadProgress: downloaderService.currentProgress);
  }

  bool setOnDeviceAi(bool enabled) {
    if (enabled && state.hardwareProfile.tier != HardwareTier.flagship) {
      return false; // Locked for non-flagship devices
    }
    if (enabled && downloaderService.currentProgress.status != ModelDownloadState.ready) {
      return false; // Cannot enable unless Gemma model weights are downloaded & verified
    }
    state = state.copyWith(enableOnDeviceAi: enabled);
    return true;
  }

  Future<void> startModelDownload({String? url, String? expectedSha256}) async {
    if (state.hardwareProfile.tier != HardwareTier.flagship) return;
    await downloaderService.startDownload(
      downloadUrl: url ?? 'https://storage.googleapis.com/remainder-portal-models/gemma-3-1b-quantized.bin',
      expectedSha256: expectedSha256 ?? GemmaModelDownloaderService.defaultChecksum,
    );
  }

  Future<void> pauseModelDownload() async {
    await downloaderService.pauseDownload();
  }

  Future<void> resumeModelDownload({String? url, String? expectedSha256}) async {
    await downloaderService.resumeDownload(
      downloadUrl: url ?? 'https://storage.googleapis.com/remainder-portal-models/gemma-3-1b-quantized.bin',
      expectedSha256: expectedSha256 ?? GemmaModelDownloaderService.defaultChecksum,
    );
  }

  Future<void> cancelModelDownload() async {
    await downloaderService.cancelDownload();
  }

  Future<void> deleteModelWeights() async {
    await downloaderService.deleteModelWeights();
    state = state.copyWith(enableOnDeviceAi: false);
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

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }
}

final presentationProvider = StateNotifierProvider<PresentationNotifier, PresentationSettingsModel>((ref) {
  return PresentationNotifier();
});
