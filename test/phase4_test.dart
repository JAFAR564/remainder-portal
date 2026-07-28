import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:remainder_portal/data/services/gemma_model_downloader_service.dart';
import 'package:remainder_portal/data/services/hardware_tier_service.dart';
import 'package:remainder_portal/data/services/litert_service.dart';
import 'package:remainder_portal/presentation/providers/presentation_provider.dart';

void main() {
  group('Phase 4: Hardware Tier Service Unit Tests', () {
    test('detectHardwareProfile returns a valid DeviceHardwareProfile', () {
      final profile = HardwareTierService.detectHardwareProfile();
      expect(profile.processorCores, greaterThan(0));
      expect(profile.totalRamMb, greaterThan(0));
      expect(profile.platformName.isNotEmpty, isTrue);
      expect(profile.tier, isNotNull);
    });
  });

  group('Phase 4: Gemma Model Downloader Service & SHA-256 Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gemma_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('verifyFileChecksum validates valid SHA-256 and rejects invalid SHA-256', () async {
      final testFile = File('${tempDir.path}/test_model.bin');
      const sampleText = 'Gemma Model Weight Content Baseline 12345';
      await testFile.writeAsString(sampleText);

      final expectedHash = sha256.convert(utf8.encode(sampleText)).toString();

      final isValid = await GemmaModelDownloaderService.verifyFileChecksum(
        testFile.path,
        expectedHash,
      );
      expect(isValid, isTrue);

      final isInvalid = await GemmaModelDownloaderService.verifyFileChecksum(
        testFile.path,
        '0000000000000000000000000000000000000000000000000000000000000000',
      );
      expect(isInvalid, isFalse);
    });

    test('Downloader Service handles download, verification, and file cleanup', () async {
      const samplePayload = 'Simulated 1.5GB Gemma Model Weights';
      final sampleBytes = utf8.encode(samplePayload);
      final expectedSha = sha256.convert(sampleBytes).toString();

      final mockClient = http_testing.MockClient((request) async {
        return http.Response.bytes(sampleBytes, 200);
      });

      final downloader = GemmaModelDownloaderService(
        targetDirOverride: tempDir.path,
        httpClient: mockClient,
      );

      await downloader.initialize();
      expect(downloader.currentProgress.status, equals(ModelDownloadState.notDownloaded));

      final progressEvents = <ModelDownloadProgress>[];
      final sub = downloader.progressStream.listen((p) => progressEvents.add(p));

      await downloader.startDownload(
        downloadUrl: 'https://example.com/gemma.bin',
        expectedSha256: expectedSha,
        totalBytes: sampleBytes.length,
      );

      // Wait briefly for stream to finalize async verification
      await Future.delayed(const Duration(milliseconds: 200));

      expect(downloader.currentProgress.status, equals(ModelDownloadState.ready));
      expect(downloader.isModelReady, isTrue);
      expect(await File(await downloader.getModelFilePath()).exists(), isTrue);

      // Test deleteModelWeights
      await downloader.deleteModelWeights();
      expect(downloader.currentProgress.status, equals(ModelDownloadState.notDownloaded));
      expect(await File(await downloader.getModelFilePath()).exists(), isFalse);

      await sub.cancel();
      downloader.dispose();
    });

    test('Downloader Service sets error status when SHA-256 verification fails', () async {
      const samplePayload = 'Corrupted Gemma Weights';
      final sampleBytes = utf8.encode(samplePayload);

      final mockClient = http_testing.MockClient((request) async {
        return http.Response.bytes(sampleBytes, 200);
      });

      final downloader = GemmaModelDownloaderService(
        targetDirOverride: tempDir.path,
        httpClient: mockClient,
      );

      await downloader.startDownload(
        downloadUrl: 'https://example.com/gemma.bin',
        expectedSha256: 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
        totalBytes: sampleBytes.length,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(downloader.currentProgress.status, equals(ModelDownloadState.error));
      expect(downloader.currentProgress.errorMessage, contains('SHA-256 checksum verification failed'));

      downloader.dispose();
    });
  });

  group('Phase 4: LiteRtService Weight Dependency & Fallback Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('litert_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('LiteRtService returns local response when enabled and model weights exist', () async {
      final weightFile = File('${tempDir.path}/gemma.bin');
      await weightFile.writeAsString('valid_model_data');

      final service = LiteRtService(
        isOnDeviceEnabled: true,
        modelWeightPath: weightFile.path,
      );

      expect(service.hasValidModelWeights, isTrue);
      final response = await service.generateStoryResponse('Test command');
      expect(response, contains('[On-Device Gemma 3 (1B) via LiteRT-LM]'));
    });

    test('LiteRtService falls back to d20/Cloud when model weights are missing', () async {
      final missingPath = '${tempDir.path}/non_existent_gemma.bin';

      final service = LiteRtService(
        isOnDeviceEnabled: true,
        modelWeightPath: missingPath,
        cloudEndpoint: 'http://invalid-localhost-endpoint/api',
      );

      expect(service.hasValidModelWeights, isFalse);
      final response = await service.generateStoryResponse('Test command');
      expect(response, contains('[OFFLINE RULE ENGINE]'));
    });
  });

  group('Phase 4: PresentationNotifier Gating & Integration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('notifier_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('setOnDeviceAi returns false when model weights are not ready', () {
      final downloader = GemmaModelDownloaderService(targetDirOverride: tempDir.path);
      final notifier = PresentationNotifier(customDownloader: downloader);

      final success = notifier.setOnDeviceAi(true);
      expect(success, isFalse);
      expect(notifier.state.enableOnDeviceAi, isFalse);

      notifier.dispose();
    });
  });
}
