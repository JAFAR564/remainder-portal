import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../models/debug_report.dart';
import 'auth_service.dart';
import '../features/profile/providers/active_character_provider.dart';
import 'roster_cache_service.dart';

class DebugReportsService {
  final SupabaseClient _client;
  final Ref _ref;

  DebugReportsService(this._client, this._ref);

  /// Submits a new debug report. Prioritizes Discord Webhook (instant notification),
  /// with a background fallback save to Supabase.
  Future<DebugReport> submitReport({
    required String applicantEmail,
    required String characterName,
    required String comment,
    required String screenshotBase64,
    required String routePath,
    required String category,
  }) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    
    // 1. Resolve Webhook URL: settings cache -> compile-time injection env
    String webhookUrl = prefs.getString('discord_webhook_url') ?? '';
    if (webhookUrl.isEmpty) {
      webhookUrl = const String.fromEnvironment('DISCORD_WEBHOOK_URL');
    }

    if (webhookUrl.isEmpty) {
      debugPrint('Discord Webhook URL not configured. Bypassing push notification.');
    } else {
      try {
        final rawBytes = base64Decode(screenshotBase64);
        
        final formData = FormData.fromMap({
          'files[0]': MultipartFile.fromBytes(rawBytes, filename: 'screenshot.png'),
          'payload_json': jsonEncode({
            'content': '📡 **NEW PORTAL LOG RECEIVED**',
            'embeds': [
              {
                'title': '🚨 DEBUG ALERT: ${category.toUpperCase()}',
                'description': comment.isNotEmpty ? comment : '*No description provided.*',
                'color': category == 'UI Bug' 
                    ? 15158332 // Red
                    : (category == 'Database / Auth' 
                        ? 15105570 // Orange
                        : (category == 'Lore / Story' ? 3066993 : 3447003)),
                'fields': [
                  {'name': 'Submitter Email', 'value': applicantEmail, 'inline': true},
                  {'name': 'Character Identity', 'value': characterName, 'inline': true},
                  {'name': 'Active Sector Route', 'value': routePath, 'inline': true},
                ],
                'image': {'url': 'attachment://screenshot.png'}
              }
            ]
          }),
        });

        final response = await Dio().post(webhookUrl, data: formData);
        if (response.statusCode != 200 && response.statusCode != 204) {
          debugPrint('Discord webhook responded with error: ${response.statusCode}');
        } else {
          debugPrint('Discord webhook notification transmitted successfully!');
        }
      } catch (e) {
        debugPrint('Failed to send Discord webhook: $e');
      }
    }

    // 2. Background attempt to write to Supabase (so we preserve historic data in feed if needed)
    try {
      final reportMap = {
        'applicant_email': applicantEmail,
        'character_name': characterName,
        'comment': comment,
        'screenshot_base64': screenshotBase64,
        'route_path': routePath,
        'category': category,
      };

      final response = await _client
          .from('debug_reports')
          .insert(reportMap)
          .select()
          .single();

      return DebugReport.fromJson(response);
    } catch (e) {
      debugPrint('Supabase background log save bypassed: $e');
      // Return a simulated DebugReport object so client can still render it locally in history
      return DebugReport(
        id: 'local-temp',
        createdAt: DateTime.now().toIso8601String(),
        applicantEmail: applicantEmail,
        characterName: characterName,
        comment: comment,
        screenshotBase64: screenshotBase64,
        routePath: routePath,
        category: category,
      );
    }
  }

  /// Fetches all debug reports from Supabase (ordered by newest first)
  Future<List<DebugReport>> fetchReports() async {
    try {
      final response = await _client
          .from('debug_reports')
          .select()
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((r) => DebugReport.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching debug reports: $e');
      return const []; // Graceful empty fallback if offline
    }
  }
}

/// Provider exposing the DebugReportsService.
final debugReportsServiceProvider = Provider<DebugReportsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DebugReportsService(client, ref);
});

/// AsyncNotifier provider managing the debug reports feed.
class DebugReportsNotifier extends AsyncNotifier<List<DebugReport>> {
  @override
  FutureOr<List<DebugReport>> build() async {
    return ref.read(debugReportsServiceProvider).fetchReports();
  }

  Future<void> addReport({
    required String comment,
    required String screenshotBase64,
    required String routePath,
    required String category,
  }) async {
    final user = ref.read(currentUserProvider);
    final activeChar = ref.read(activeCharacterProvider).value;

    final email = user?.email ?? 'anonymous@remainder.portal';
    final name = activeChar?.characterName ?? 'Anonymous Character';

    final report = await ref.read(debugReportsServiceProvider).submitReport(
      applicantEmail: email,
      characterName: name,
      comment: comment,
      screenshotBase64: screenshotBase64,
      routePath: routePath,
      category: category,
    );

    final currentList = state.value ?? [];
    state = AsyncValue.data([report, ...currentList]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(debugReportsServiceProvider).fetchReports());
  }
}

final debugReportsProvider =
    AsyncNotifierProvider<DebugReportsNotifier, List<DebugReport>>(() {
  return DebugReportsNotifier();
});
