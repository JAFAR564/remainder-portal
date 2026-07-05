import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application.dart';
import '../models/roster_member.dart';
import 'auth_service.dart';

/// Provider exposing the standard Dio client.
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Service class interfacing with the serverless CloudRunSheetsProxy over HTTPS.
/// 
/// Intercepts requests to inject the short-lived Supabase JWT bearer token,
/// protecting backend sheets access and preventing credentials leakage.
class SheetsService {
  final Dio _dio;
  final SupabaseClient _supabase;
  static const _baseProxyUrl = 'https://sheets-proxy-9gxz.onrender.com';

  SheetsService(this._dio, this._supabase) {
    // Dynamic token injection block
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final accessToken = _supabase.auth.currentSession?.accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('Sheets Proxy Request Failure: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Retrieves the roster list of character members from the sheets proxy.
  Future<List<RosterMember>> fetchRoster() async {
    try {
      final response = await _dio.get('$_baseProxyUrl/roster');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => RosterMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching roster from proxy: $e');
      rethrow;
    }
  }

  /// Fetches pending admittance applications from the spreadsheet.
  Future<List<Application>> fetchPendingApplications() async {
    try {
      final response = await _dio.get('$_baseProxyUrl/applications/pending');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => Application.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching pending applications from proxy: $e');
      rethrow;
    }
  }

  /// Writes an admittance log decision back to the admin Sheets database.
  Future<void> writeAdmittanceDecision({
    required String appId,
    required String decision,
    required double deepseekScore,
    required List<String> groqFlags,
  }) async {
    try {
      await _dio.post(
        '$_baseProxyUrl/admittance/decision',
        data: {
          'app_id': appId,
          'decision': decision,
          'deepseek_score': deepseekScore,
          'groq_flags': groqFlags,
        },
      );
    } catch (e) {
      debugPrint('Error writing admittance decision to proxy: $e');
      rethrow;
    }
  }
}

/// Provider exposing the SheetsService.
final sheetsServiceProvider = Provider<SheetsService>((ref) {
  final dio = ref.watch(dioProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return SheetsService(dio, supabase);
});
