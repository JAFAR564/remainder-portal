import 'dart:convert';
import 'package:http/http.dart' as http;
import 'monitoring_service.dart';

class LiteRtService {
  final String _cloudEndpoint;
  final bool _isOnDeviceEnabled;
  final MonitoringService _monitoring = MonitoringService();

  LiteRtService({
    String? cloudEndpoint,
    bool? isOnDeviceEnabled,
  })  : _cloudEndpoint = cloudEndpoint ?? 'http://localhost:8080/api/gm',
        // On-device inference is blocked at startup for Tier A devices (e.g. Samsung Galaxy A04s)
        // because of low RAM (< 4GB) and no dedicated NPU accelerator.
        _isOnDeviceEnabled = isOnDeviceEnabled ?? false;

  Future<String> generateStoryResponse(String prompt, {String? characterClass}) async {
    final trace = await _monitoring.startTrace('generate_story_response');
    trace.putAttribute('mode', _isOnDeviceEnabled ? 'local' : 'cloud');
    if (characterClass != null) {
      trace.putAttribute('class', characterClass);
    }

    if (_isOnDeviceEnabled) {
      // Local LiteRT-LM Gemma 3 (1B) execution placeholder (for Tier S/A+ devices)
      await trace.stop();
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

        await trace.stop();

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey('response')) {
            return data['response'] as String;
          } else if (data.containsKey('error')) {
            await _monitoring.logError('Cloud Generation Error: ${data['error']}', null, reason: 'api_error');
            return 'Cloud Generation Error: ${data['error']}';
          }
        }
        await _monitoring.logError('Network Error: Status code ${response.statusCode}', null, reason: 'network_error');
        return 'Network Error: Status code ${response.statusCode}';
      } catch (e, stack) {
        await trace.stop();
        await _monitoring.logError(e, stack, reason: 'request_failed');
        return 'Offline or failed to reach cloud fallback: $e';
      }
    }
  }
}

