import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'monitoring_service.dart';

class LiteRtService {
  final String _cloudEndpoint;
  final bool _isOnDeviceEnabled;
  final String? _modelWeightPath;
  final MonitoringService _monitoring = MonitoringService();

  LiteRtService({
    String? cloudEndpoint,
    bool? isOnDeviceEnabled,
    String? modelWeightPath,
  })  : _cloudEndpoint = cloudEndpoint ?? 'http://localhost:8080/api/gm',
        // On-device inference is blocked at startup for Tier A devices (e.g. Samsung Galaxy A04s)
        // because of low RAM (< 4GB) and no dedicated NPU accelerator.
        _isOnDeviceEnabled = isOnDeviceEnabled ?? false,
        _modelWeightPath = modelWeightPath;

  bool get hasValidModelWeights {
    if (_modelWeightPath == null) return false;
    final file = File(_modelWeightPath!);
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<String> generateStoryResponse(String prompt, {String? characterClass}) async {
    final trace = await _monitoring.startTrace('generate_story_response');
    final bool canRunOnDevice = _isOnDeviceEnabled && (_modelWeightPath == null || hasValidModelWeights);
    trace.putAttribute('mode', canRunOnDevice ? 'local' : 'cloud');
    if (characterClass != null) {
      trace.putAttribute('class', characterClass);
    }

    if (canRunOnDevice) {
      // Local LiteRT-LM Gemma 3 (1B) execution placeholder (for Tier S/A+ devices with verified model weights)
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
            return _generateOfflineStoryResponse(prompt, characterClass);
          }
        }
        await _monitoring.logError('Network Error: Status code ${response.statusCode}', null, reason: 'network_error');
        return _generateOfflineStoryResponse(prompt, characterClass);
      } catch (e, stack) {
        await trace.stop();
        await _monitoring.logError(e, stack, reason: 'request_failed');
        return _generateOfflineStoryResponse(prompt, characterClass);
      }
    }
  }

  String _generateOfflineStoryResponse(String prompt, String? characterClass) {
    final random = math.Random();
    final d20 = random.nextInt(20) + 1;
    final modifier = (characterClass == 'Vanguard' || characterClass == 'Cyber Hacker') ? 3 : 2;
    final total = d20 + modifier;

    String outcomeTitle;
    String narrativeDescription;

    if (total >= 18) {
      outcomeTitle = 'CRITICAL CONSENSUS REACHED';
      narrativeDescription = 'Your command "$prompt" overrides local sector defenses smoothly. System stability restored at +100% capacity.';
    } else if (total >= 10) {
      outcomeTitle = 'SUCCESSFUL COMMAND EXECUTION';
      narrativeDescription = 'Your action "$prompt" has been logged in the local sector node. Neural pathway stabilized.';
    } else if (total >= 6) {
      outcomeTitle = 'PARTIAL CONSENSUS WITH COMPLICATION';
      narrativeDescription = 'Your action "$prompt" succeeded, but triggered minor power fluctuations across your shield integrity.';
    } else {
      outcomeTitle = 'SYSTEM ANOMALY DETECTED';
      narrativeDescription = 'Local sector firewalls rejected the instruction "$prompt". Defense countermeasures engaged.';
    }

    return '[OFFLINE RULE ENGINE]\n'
           'D20 Roll: $d20 + $modifier (${characterClass ?? "Unknown"}) = $total\n'
           'Status: $outcomeTitle\n\n'
           '$narrativeDescription';
  }
}

