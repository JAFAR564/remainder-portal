import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Validated flavor text payload for Aether Resonance Oracle prophecies.
class OracleProphecyFlavor {
  final String prophecyText;

  const OracleProphecyFlavor({required this.prophecyText});

  @override
  String toString() => 'OracleProphecyFlavor(prophecyText: $prophecyText)';
}

/// Validated flavor text payload for World Arbiter quest decrees.
class ArbiterDecreeFlavor {
  final String title;
  final String description;

  const ArbiterDecreeFlavor({
    required this.title,
    required this.description,
  });

  @override
  String toString() => 'ArbiterDecreeFlavor(title: $title, description: $description)';
}

/// Communicates with on-device llama-server daemon at 127.0.0.1:8080 running Llama 3.2 1B.
/// Enforces strict validation, fails closed to deterministic seeds, and touches NO game mechanics.
class LocalLlmSidecarService {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  static const String defaultBaseUrl = 'http://127.0.0.1:8080';
  static const Duration defaultTimeout = Duration(seconds: 22);

  LocalLlmSidecarService({
    String? baseUrl,
    Duration? timeout,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        timeout = timeout ?? defaultTimeout,
        _client = client ?? http.Client();

  /// Checks if the local llama-server daemon is alive and listening.
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final body = response.body.trim();
        return body.contains('"ok"') || body.contains('"status"');
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Generates celestial prophecy flavor text for the Aether Resonance Oracle.
  /// Fails closed (returns null) on timeout, malformed JSON, or validation failure.
  Future<OracleProphecyFlavor?> generateOracleProphecy({
    required int d20Roll,
    required String outcomeTier,
    required String operatorClass,
    String? sector,
  }) async {
    final systemPrompt =
        'You are the Aether Resonance Oracle for The Remainder Portal RPG. '
        'Generate mystical prophecy flavor text under 25 words. '
        'Output strictly valid JSON with key "prophecy_text". Flavor text only.';

    final userPrompt =
        'Operator Archetype: $operatorClass. '
        'D20 Roll: $d20Roll (Tier: $outcomeTier). '
        'Sector: ${sector ?? 'Sanctuary 4'}.';

    final jsonContent = await _sendChatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 45,
    );

    if (jsonContent == null) return null;
    return _validateAndParseProphecy(jsonContent);
  }

  /// Generates narrative flavor text (title and description) for World Arbiter decrees.
  /// Fails closed (returns null) on timeout, malformed JSON, or validation failure.
  Future<ArbiterDecreeFlavor?> generateDecreeFlavor({
    required String operatorClass,
    required String sectorName,
    required String difficulty,
  }) async {
    final systemPrompt =
        'You are the World Arbiter for The Remainder Portal RPG. '
        'Generate quest decree flavor text. '
        'Output strictly valid JSON with keys "title" (under 10 words) and "description" (under 30 words). '
        'Flavor text only.';

    final userPrompt =
        'Operator Archetype: $operatorClass. '
        'Sector: $sectorName. '
        'Difficulty: $difficulty.';

    final jsonContent = await _sendChatCompletion(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 60,
    );

    if (jsonContent == null) return null;
    return _validateAndParseDecree(jsonContent);
  }

  /// Sends OpenAI-compatible chat completion request with hard timeout.
  Future<String?> _sendChatCompletion({
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/chat/completions');
      final payload = json.encode({
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'max_tokens': maxTokens,
        'temperature': 0.7,
        'stream': false,
      });

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;

      final message = choices.first['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      return content?.trim();
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extracts pure JSON string, stripping markdown code fences if present.
  static String extractJsonSubstring(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }
    text = text.trim();

    // Locate first '{' and last '}'
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  /// Validates Oracle prophecy response:
  /// - Drops unknown keys
  /// - Enforces non-empty prophecy_text (5..250 chars)
  /// - Fails closed (returns null) on malformed JSON or out-of-bound content
  static OracleProphecyFlavor? _validateAndParseProphecy(String rawContent) {
    try {
      final cleanJson = extractJsonSubstring(rawContent);
      final decoded = json.decode(cleanJson);
      if (decoded is! Map<String, dynamic>) return null;

      String? text;
      final rawVal = decoded['prophecy_text'] ?? decoded['blessing_text'] ?? decoded['prophecy'];
      if (rawVal is String) {
        text = rawVal;
      } else if (rawVal is List && rawVal.isNotEmpty) {
        final first = rawVal.first;
        if (first is String) {
          text = first;
        } else if (first is Map && first['text'] is String) {
          text = first['text'] as String;
        }
      }
      if (text == null) return null;

      final sanitized = text.trim();
      // Sanity bounds: 5 to 250 characters
      if (sanitized.length < 5 || sanitized.length > 250) {
        return null;
      }

      // Reject script / dangerous tags
      if (sanitized.contains('<script') || sanitized.contains('javascript:')) {
        return null;
      }

      return OracleProphecyFlavor(prophecyText: sanitized);
    } catch (_) {
      return null;
    }
  }

  /// Validates Arbiter decree response:
  /// - Drops unknown keys (any hallucinated reward, difficulty, etc. are ignored)
  /// - Enforces title (3..80 chars) and description (5..250 chars)
  /// - Fails closed (returns null) on malformed JSON or out-of-bound content
  static ArbiterDecreeFlavor? _validateAndParseDecree(String rawContent) {
    try {
      final cleanJson = extractJsonSubstring(rawContent);
      final decoded = json.decode(cleanJson);
      if (decoded is! Map<String, dynamic>) return null;

      final title = decoded['title'] as String?;
      final description = (decoded['description'] ?? decoded['flavor_text']) as String?;

      if (title == null || description == null) return null;

      final cleanTitle = title.trim();
      final cleanDescription = description.trim();

      // Sanity bounds: title 3..80 chars, description 5..250 chars
      if (cleanTitle.length < 3 || cleanTitle.length > 80) {
        return null;
      }
      if (cleanDescription.length < 5 || cleanDescription.length > 250) {
        return null;
      }

      // Reject script / dangerous tags
      if (cleanTitle.contains('<script') || cleanDescription.contains('<script')) {
        return null;
      }

      return ArbiterDecreeFlavor(
        title: cleanTitle,
        description: cleanDescription,
      );
    } catch (_) {
      return null;
    }
  }
}
