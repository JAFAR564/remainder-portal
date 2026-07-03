import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/okf_models.dart';
import 'auth_service.dart';
import 'sheets_service.dart';

/// Service interfacing with the Google Open Knowledge Framework (OKF) RAG backend.
/// 
/// Leverages Gemini 1.5 Pro's 2M context cache via the Cloud Run proxy to execute
/// lore consistency checking against canonical world documentation.
class OKFService {
  final Dio _dio;
  final SupabaseClient _supabase;
  static const _baseProxyUrl = 'https://okf-service-xxx-uc.a.run.app';

  OKFService(this._dio, this._supabase) {
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
          debugPrint('OKF Service Request Failure: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Queries the Gemini 1.5 Pro cache instance for lore alignment.
  /// 
  /// Receives the candidate text (e.g. application answers) and checks compliance,
  /// returning chunks, confidence scores, and citations.
  Future<OKFQueryResult> queryLoreContext({
    required String answerText,
    required String queryIntent,
    int topK = 5,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseProxyUrl/okf/query',
        data: {
          'query': answerText,
          'intent': queryIntent,
          'top_k': topK,
          'require_citations': true,
        },
      );
      return OKFQueryResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error querying OKF Lore Context: $e');
      rethrow;
    }
  }
}

/// Provider exposing the OKFService.
final okfServiceProvider = Provider<OKFService>((ref) {
  final dio = ref.watch(dioProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return OKFService(dio, supabase);
});
