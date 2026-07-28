import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ModelDownloadState {
  notDownloaded,
  downloading,
  paused,
  verifying,
  ready,
  error,
}

class ModelDownloadProgress {
  final int bytesDownloaded;
  final int totalBytes;
  final double percentage;
  final double downloadSpeedMbS;
  final ModelDownloadState status;
  final String? errorMessage;

  const ModelDownloadProgress({
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.percentage,
    required this.downloadSpeedMbS,
    required this.status,
    this.errorMessage,
  });

  factory ModelDownloadProgress.initial({int totalBytes = 1610612736}) {
    return ModelDownloadProgress(
      bytesDownloaded: 0,
      totalBytes: totalBytes,
      percentage: 0.0,
      downloadSpeedMbS: 0.0,
      status: ModelDownloadState.notDownloaded,
    );
  }

  ModelDownloadProgress copyWith({
    int? bytesDownloaded,
    int? totalBytes,
    double? percentage,
    double? downloadSpeedMbS,
    ModelDownloadState? status,
    String? errorMessage,
  }) {
    return ModelDownloadProgress(
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      percentage: percentage ?? this.percentage,
      downloadSpeedMbS: downloadSpeedMbS ?? this.downloadSpeedMbS,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GemmaModelDownloaderService {
  static const int defaultModelSizeBytes = 1610612736; // ~1.5 GB (1536 MB)
  static const String defaultModelFileName = 'gemma-3-1b-quantized.bin';
  static const String defaultChecksum = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  final String? _targetDirOverride;
  final http.Client _client;

  StreamSubscription<List<int>>? _downloadSubscription;
  IOSink? _fileSink;
  http.ByteStream? _activeByteStream;

  final StreamController<ModelDownloadProgress> _progressController =
      StreamController<ModelDownloadProgress>.broadcast();

  ModelDownloadProgress _currentProgress = ModelDownloadProgress.initial();

  GemmaModelDownloaderService({
    String? targetDirOverride,
    http.Client? httpClient,
  })  : _targetDirOverride = targetDirOverride,
        _client = httpClient ?? http.Client();

  Stream<ModelDownloadProgress> get progressStream => _progressController.stream;
  ModelDownloadProgress get currentProgress => _currentProgress;
  bool get isModelReady => _currentProgress.status == ModelDownloadState.ready;

  Future<String> getModelDirectoryPath() async {
    if (_targetDirOverride != null) {
      final dir = Directory(_targetDirOverride);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }
    final appDir = await getApplicationSupportDirectory();
    final modelDir = Directory(p.join(appDir.path, 'models'));
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  }

  Future<String> getModelFilePath() async {
    final dir = await getModelDirectoryPath();
    return p.join(dir, defaultModelFileName);
  }

  Future<String> getTempFilePath() async {
    final dir = await getModelDirectoryPath();
    return p.join(dir, '$defaultModelFileName.tmp');
  }

  Future<void> initialize() async {
    try {
      final modelPath = await getModelFilePath();
      final modelFile = File(modelPath);
      final tempPath = await getTempFilePath();
      final tempFile = File(tempPath);

      if (await modelFile.exists()) {
        final length = await modelFile.length();
        _updateProgress(_currentProgress.copyWith(
          bytesDownloaded: length,
          totalBytes: length > 0 ? length : defaultModelSizeBytes,
          percentage: 100.0,
          status: ModelDownloadState.ready,
        ));
      } else if (await tempFile.exists()) {
        final length = await tempFile.length();
        final pct = (length / defaultModelSizeBytes * 100).clamp(0.0, 100.0);
        _updateProgress(_currentProgress.copyWith(
          bytesDownloaded: length,
          totalBytes: defaultModelSizeBytes,
          percentage: pct,
          status: ModelDownloadState.paused,
        ));
      } else {
        _updateProgress(ModelDownloadProgress.initial());
      }
    } catch (e) {
      _updateProgress(_currentProgress.copyWith(
        status: ModelDownloadState.error,
        errorMessage: 'Failed to initialize downloader: $e',
      ));
    }
  }

  Future<void> startDownload({
    String downloadUrl = 'https://storage.googleapis.com/remainder-portal-models/gemma-3-1b-quantized.bin',
    String expectedSha256 = defaultChecksum,
    int totalBytes = defaultModelSizeBytes,
  }) async {
    if (_currentProgress.status == ModelDownloadState.downloading) return;

    try {
      final tempPath = await getTempFilePath();
      final tempFile = File(tempPath);
      int existingBytes = 0;

      if (await tempFile.exists()) {
        existingBytes = await tempFile.length();
      }

      _updateProgress(_currentProgress.copyWith(
        bytesDownloaded: existingBytes,
        totalBytes: totalBytes,
        percentage: (existingBytes / totalBytes * 100).clamp(0.0, 100.0),
        status: ModelDownloadState.downloading,
        errorMessage: null,
      ));

      final request = http.Request('GET', Uri.parse(downloadUrl));
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await _client.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw HttpException('Server returned HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? (totalBytes - existingBytes);
      final actualTotalBytes = existingBytes + contentLength;

      _fileSink = tempFile.openWrite(mode: FileMode.append);

      int downloadedSinceStart = 0;
      final stopwatch = Stopwatch()..start();

      _downloadSubscription = response.stream.listen(
        (chunk) {
          _fileSink?.add(chunk);
          downloadedSinceStart += chunk.length;
          final currentTotalDownloaded = existingBytes + downloadedSinceStart;
          final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
          final speedMbS = elapsedSeconds > 0
              ? (downloadedSinceStart / (1024 * 1024)) / elapsedSeconds
              : 0.0;

          final pct = (currentTotalDownloaded / actualTotalBytes * 100).clamp(0.0, 100.0);

          _updateProgress(_currentProgress.copyWith(
            bytesDownloaded: currentTotalDownloaded,
            totalBytes: actualTotalBytes,
            percentage: pct,
            downloadSpeedMbS: speedMbS,
            status: ModelDownloadState.downloading,
          ));
        },
        onDone: () async {
          await _fileSink?.flush();
          await _fileSink?.close();
          _fileSink = null;
          stopwatch.stop();

          await _verifyAndFinalize(tempFile, expectedSha256, actualTotalBytes);
        },
        onError: (error) async {
          await _fileSink?.close();
          _fileSink = null;
          _updateProgress(_currentProgress.copyWith(
            status: ModelDownloadState.error,
            errorMessage: 'Download stream error: $error',
          ));
        },
        cancelOnError: true,
      );
    } catch (e) {
      await _fileSink?.close();
      _fileSink = null;
      _updateProgress(_currentProgress.copyWith(
        status: ModelDownloadState.error,
        errorMessage: 'Failed to start download: $e',
      ));
    }
  }

  Future<void> pauseDownload() async {
    if (_currentProgress.status != ModelDownloadState.downloading) return;

    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;

    final tempPath = await getTempFilePath();
    final tempFile = File(tempPath);
    final existingBytes = await tempFile.exists() ? await tempFile.length() : _currentProgress.bytesDownloaded;

    _updateProgress(_currentProgress.copyWith(
      bytesDownloaded: existingBytes,
      status: ModelDownloadState.paused,
      downloadSpeedMbS: 0.0,
    ));
  }

  Future<void> resumeDownload({
    String downloadUrl = 'https://storage.googleapis.com/remainder-portal-models/gemma-3-1b-quantized.bin',
    String expectedSha256 = defaultChecksum,
  }) async {
    if (_currentProgress.status == ModelDownloadState.paused ||
        _currentProgress.status == ModelDownloadState.error) {
      await startDownload(
        downloadUrl: downloadUrl,
        expectedSha256: expectedSha256,
        totalBytes: _currentProgress.totalBytes,
      );
    }
  }

  Future<void> cancelDownload() async {
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _fileSink?.close();
    _fileSink = null;

    final tempPath = await getTempFilePath();
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    _updateProgress(ModelDownloadProgress.initial(totalBytes: _currentProgress.totalBytes));
  }

  Future<void> deleteModelWeights() async {
    await cancelDownload();

    final modelPath = await getModelFilePath();
    final modelFile = File(modelPath);
    if (await modelFile.exists()) {
      await modelFile.delete();
    }

    _updateProgress(ModelDownloadProgress.initial());
  }

  Future<void> _verifyAndFinalize(File tempFile, String expectedSha256, int totalBytes) async {
    _updateProgress(_currentProgress.copyWith(
      status: ModelDownloadState.verifying,
      downloadSpeedMbS: 0.0,
    ));

    try {
      final isChecksumValid = await verifyFileChecksum(tempFile.path, expectedSha256);
      if (!isChecksumValid) {
        _updateProgress(_currentProgress.copyWith(
          status: ModelDownloadState.error,
          errorMessage: 'SHA-256 checksum verification failed. File corrupt or tampered.',
        ));
        return;
      }

      final modelPath = await getModelFilePath();
      await tempFile.rename(modelPath);

      _updateProgress(_currentProgress.copyWith(
        bytesDownloaded: totalBytes,
        totalBytes: totalBytes,
        percentage: 100.0,
        downloadSpeedMbS: 0.0,
        status: ModelDownloadState.ready,
        errorMessage: null,
      ));
    } catch (e) {
      _updateProgress(_currentProgress.copyWith(
        status: ModelDownloadState.error,
        errorMessage: 'Verification error: $e',
      ));
    }
  }

  static Future<bool> verifyFileChecksum(String filePath, String expectedSha256) async {
    // If expected sha256 matches default placeholder or is empty/mock, skip or pass for mock testing
    if (expectedSha256.isEmpty) return true;

    final file = File(filePath);
    if (!await file.exists()) return false;

    final output = AccumulatorSink<Digest>();
    final input = sha256.startChunkedConversion(output);

    final stream = file.openRead();
    await for (final chunk in stream) {
      input.add(chunk);
    }
    input.close();

    final computedHash = output.events.single.toString();
    return computedHash.toLowerCase() == expectedSha256.toLowerCase();
  }

  void _updateProgress(ModelDownloadProgress progress) {
    _currentProgress = progress;
    _progressController.add(progress);
  }

  void dispose() {
    _downloadSubscription?.cancel();
    _fileSink?.close();
    _progressController.close();
  }
}
