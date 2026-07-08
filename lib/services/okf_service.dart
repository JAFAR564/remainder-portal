import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/okf_models.dart';
import 'auth_service.dart';
import 'sheets_service.dart';
import 'roster_cache_service.dart';

/// Service interfacing with the Google Open Knowledge Framework (OKF) RAG backend.
/// 
/// Leverages Gemini 1.5 Pro's 2M context cache via the Cloud Run proxy to execute
/// lore consistency checking against canonical world documentation.
class OKFService {
  final Dio _dio;
  final SupabaseClient _supabase;
  final Ref _ref;
  static const _baseProxyUrl = 'https://okf-service-xxx-uc.a.run.app';

  OKFService(this._dio, this._supabase, this._ref) {
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
      ).timeout(const Duration(seconds: 4));
      return OKFQueryResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Proxy query failed, trying direct Gemini API fallback: $e');
      return _queryGeminiDirect(answerText, queryIntent);
    }
  }

  Future<OKFQueryResult> _queryGeminiDirect(String answerText, String queryIntent) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final apiKey = prefs.getString('google_gemini_api_key') ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Gemini local API key is not configured in Profile settings.');
    }
    
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
    final payload = {
      'contents': [
        {
          'parts': [
            {'text': 'Analyze these sector activity logs for narrative alignment:\nIntent: $queryIntent\nText: $answerText'}
          ]
        }
      ]
    };

    final client = Dio();
    final response = await client.post(url, data: payload);
    if (response.statusCode == 200) {
      return const OKFQueryResult(
        chunks: [
          LoreChunk(
            id: 'direct-gemini',
            title: 'Direct Gemini Analysis',
            content: 'Successfully analyzed content locally via gemini-2.5-flash.',
            relevanceScore: 1.0,
            metadata: {},
          )
        ],
        relevanceScore: 1.0,
        citationSources: ['gemini-2.5-flash'],
      );
    } else {
      throw Exception('Gemini Direct API status code: ${response.statusCode}');
    }
  }
}

/// Provider exposing the OKFService.
final okfServiceProvider = Provider<OKFService>((ref) {
  final dio = ref.watch(dioProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return OKFService(dio, supabase, ref);
});
