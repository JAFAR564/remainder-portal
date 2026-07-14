import 'dart:convert';
import 'package:http/http.dart' as http;

class LiteRtService {
  final String _cloudEndpoint;
  final bool _isOnDeviceEnabled;

  LiteRtService({
    String? cloudEndpoint,
    bool? isOnDeviceEnabled,
  })  : _cloudEndpoint = cloudEndpoint ?? 'http://localhost:8080/api/gm',
        // On-device inference is blocked at startup for Tier A devices (e.g. Samsung Galaxy A04s)
        // because of low RAM (< 4GB) and no dedicated NPU accelerator.
        _isOnDeviceEnabled = isOnDeviceEnabled ?? false;

  Future<String> generateStoryResponse(String prompt, {String? characterClass}) async {
    if (_isOnDeviceEnabled) {
      // Local LiteRT-LM Gemma 3 (1B) execution placeholder (for Tier S/A+ devices)
      return '[On-Device Gemma 3 (1B) via LiteRT-LM]: $prompt';
    } else {
      // Hardware-routed Cloud fallback using Firebase Genkit API
      try {
        final response = await http.post(
          Uri.parse(_cloudEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'prompt': prompt,
            if (characterClass != null) 'characterClass': characterClass,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey('response')) {
            return data['response'] as String;
          } else if (data.containsKey('error')) {
            return 'Cloud Generation Error: ${data['error']}';
          }
        }
        return 'Network Error: Status code ${response.statusCode}';
      } catch (e) {
        return 'Offline or failed to reach cloud fallback: $e';
      }
    }
  }
}
