import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}

class UpdateService {
  static const String currentVersion = '1.0.1';
  static const String githubRepo = 'JAFAR564/remainder-portal';

  // Compares two semantic version strings (e.g. 1.0.0 and 1.0.1)
  bool _isNewer(String current, String latest) {
    try {
      final cleanCurrent = current.replaceAll(RegExp(r'[^\d.]'), '');
      final cleanLatest = latest.replaceAll(RegExp(r'[^\d.]'), '');
      
      final currentParts = cleanCurrent.split('.').map(int.parse).toList();
      final latestParts = cleanLatest.split('.').map(int.parse).toList();

      for (var i = 0; i < currentParts.length && i < latestParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return latestParts.length > currentParts.length;
    } catch (e) {
      // Fallback string check if format is different
      return latest != current;
    }
  }

  // Fetches release metadata from GitHub
  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Remainder-Portal-Client',
        },
      );

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final String latestVersion = data['tag_name'] as String? ?? '';
      final String releaseNotes = data['body'] as String? ?? 'No release notes provided.';
      final String htmlUrl = data['html_url'] as String? ?? '';

      if (!_isNewer(currentVersion, latestVersion)) {
        return null; // App is up to date
      }

      // Find appropriate asset URL based on target platform
      String downloadUrl = htmlUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];

      if (Platform.isAndroid) {
        // Look for Android APK asset
        final apkAsset = assets.firstWhere(
          (a) => (a['name'] as String? ?? '').endsWith('.apk'),
          orElse: () => null,
        );
        if (apkAsset != null) {
          downloadUrl = apkAsset['browser_download_url'] as String? ?? htmlUrl;
        }
      } else if (Platform.isWindows) {
        // Look for Windows Zip/Exe asset
        final winAsset = assets.firstWhere(
          (a) => (a['name'] as String? ?? '').contains('windows') || (a['name'] as String? ?? '').endsWith('.zip'),
          orElse: () => null,
        );
        if (winAsset != null) {
          downloadUrl = winAsset['browser_download_url'] as String? ?? htmlUrl;
        }
      }

      return UpdateInfo(
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );
    } catch (e) {
      print('⚠️ Failed to check for updates: $e');
      return null;
    }
  }

  // Opens browser to download URL
  Future<void> launchUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('⚠️ Could not open update URL: $e');
    }
  }

  // Checks if the target directory is writable by the current process context
  bool _isDirectoryWritable(String path) {
    try {
      final testFile = File('$path/.write_test');
      testFile.writeAsStringSync('test');
      testFile.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Downloads the update archive and spawns a background update.bat extraction script
  Future<void> downloadAndApplyUpdate(UpdateInfo info, Function(double progress) onProgress) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(info.downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP Error code ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final tempDir = Directory.systemTemp;
      final zipFile = File('${tempDir.path}/update.zip');
      
      // Open file stream
      final sink = zipFile.openWrite();
      int downloadedBytes = 0;

      await for (var chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(downloadedBytes / contentLength);
        }
      }
      await sink.close();

      // Formulate update.bat parameters
      final appDir = File(Platform.resolvedExecutable).parent.path;
      final batchFile = File('${tempDir.path}/update.bat');
      final currentPid = pid;

      // The batch script will wait for the main exe to stop, unzip files using PowerShell,
      // restart the new exe, and clean up the temporary files.
      final batContent = '''
@echo off
set "target_pid=%1"
echo ===================================================
echo   THE REMAINDER PORTAL: TRANSLATING RECONSTRUCTION
echo ===================================================

if "%target_pid%"=="" goto extract
echo Waiting for existing client (PID: %target_pid%) to close...

:wait_loop
%SystemRoot%\\System32\\tasklist.exe /fi "PID eq %target_pid%" 2>nul | %SystemRoot%\\System32\\find.exe "%target_pid%" >nul
if %errorlevel% == 0 (
    %SystemRoot%\\System32\\timeout.exe /t 1 /nobreak >nul
    goto wait_loop
)

:extract
echo Extracting code archives...
powershell -Command "Expand-Archive -Path '${zipFile.path}' -DestinationPath '$appDir' -Force"

echo Restarting client execution...
cd /d "$appDir"
start remainder_portal.exe

echo Cleaning temporary cache...
del /f /q "${zipFile.path}"
(goto) 2>nul & del "%~f0"
''';

      await batchFile.writeAsString(batContent);

      // Execute updater script detached and terminate current client
      if (Platform.isWindows) {
        final isWritable = _isDirectoryWritable(appDir);
        if (isWritable) {
          await Process.start(
            'cmd.exe',
            ['/c', batchFile.path, currentPid.toString()],
            mode: ProcessStartMode.detached,
          );
        } else {
          // Trigger standard Windows UAC dialog using powershell Start-Process -Verb RunAs
          await Process.start(
            'powershell.exe',
            [
              '-Command',
              'Start-Process cmd.exe -ArgumentList "/c \\"${batchFile.path}\\" ${currentPid}" -Verb RunAs'
            ],
            mode: ProcessStartMode.detached,
          );
        }
        exit(0);
      } else {
        throw Exception('Auto-restart is only supported on Windows.');
      }
    } finally {
      client.close();
    }
  }

  // Renders a premium, glassmorphic dialog to notify operator of update
  void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during critical updates
      builder: (context) {
        double progress = 0.0;
        bool isDownloading = false;
        String statusText = 'A new version of the world-portal is available.';

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Card(
                  color: const Color(0xFF161520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFFF8E3C), width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDownloading ? Icons.downloading : Icons.system_update_alt,
                              color: const Color(0xFFFF8E3C),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'UPDATE DETECTED',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isDownloading) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            color: const Color(0xFFE53170),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Downloading: ${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFFF8E3C),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'RELEASE LOGS:',
                            style: TextStyle(
                              color: Color(0xFFE53170),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 120),
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F0E17),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                info.releaseNotes,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (!isDownloading)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('DISMISS', style: TextStyle(color: Colors.white54)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (Platform.isWindows) {
                                    setState(() {
                                      isDownloading = true;
                                      statusText = 'Downloading the update package from GitHub...';
                                    });
                                    try {
                                      await downloadAndApplyUpdate(info, (p) {
                                        setState(() {
                                          progress = p;
                                        });
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isDownloading = false;
                                        statusText = 'Update failed: $e. You can still download manually.';
                                      });
                                    }
                                  } else {
                                    launchUpdateUrl(info.downloadUrl);
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53170),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'DOWNLOAD & UPDATE',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

