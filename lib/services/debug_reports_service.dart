import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/debug_report.dart';
import 'auth_service.dart';
import '../features/profile/providers/active_character_provider.dart';

class DebugReportsService {
  final SupabaseClient _client;

  DebugReportsService(this._client);

  /// Submits a new debug report to Supabase
  Future<DebugReport> submitReport({
    required String applicantEmail,
    required String characterName,
    required String comment,
    required String screenshotBase64,
    required String routePath,
  }) async {
    try {
      final report = {
        'applicant_email': applicantEmail,
        'character_name': characterName,
        'comment': comment,
        'screenshot_base64': screenshotBase64,
        'route_path': routePath,
      };

      final response = await _client
          .from('debug_reports')
          .insert(report)
          .select()
          .single();

      return DebugReport.fromJson(response);
    } catch (e) {
      debugPrint('Error submitting debug report: $e');
      rethrow;
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
      rethrow;
    }
  }
}

/// Provider exposing the DebugReportsService.
final debugReportsServiceProvider = Provider<DebugReportsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DebugReportsService(client);
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
