import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  static const String currentVersion = '1.0.0';
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
      if (Platform.isWindows) {
        await Process.run('start', [url], runInShell: true);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isAndroid) {
        // Fallback for Android - can launch URL with shell or standard browser intents
        await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', url]);
      }
    } catch (e) {
      print('⚠️ Could not open update URL: $e');
    }
  }

  // Renders a premium, glassmorphic dialog to notify operator of update
  void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
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
                      const Icon(Icons.system_update_alt, color: Color(0xFFFF8E3C), size: 28),
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
                    'A new version of the world-portal is available.\nCurrent version: $currentVersion  |  Latest version: ${info.latestVersion}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RELEASE LOGS:',
                    style: TextStyle(color: Color(0xFFE53170), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
                        style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('DISMISS', style: TextStyle(color: Colors.white54)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          launchUpdateUrl(info.downloadUrl);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53170),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('DOWNLOAD & UPDATE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
