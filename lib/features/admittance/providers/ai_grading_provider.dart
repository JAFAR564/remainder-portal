import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ai_grading_result.dart';

/// Notifier driving the AI assessment details for all applications.
/// 
/// Stores evaluated grading results in a Map keyed by the Application ID.
class AIGradingNotifier extends AsyncNotifier<Map<String, AIGradingResult>> {
  @override
  FutureOr<Map<String, AIGradingResult>> build() {
    return const {}; // Initially no applications have been graded
  }

  /// Triggers a mock evaluation of the application, saving result to state map.
  Future<void> evaluateApplication(String appId) async {
    final currentMap = state.value ?? const {};
    if (currentMap.containsKey(appId)) return; // Already evaluated

    try {
      // Simulate background computation latency.
      await Future.delayed(const Duration(milliseconds: 800));

      final hashIndex = appId.hashCode.abs() % 3;
      final scores = [9.4, 8.2, 4.8];
      final flags = [
        ['Tone: Formal', 'Layout: Clean', 'Wordcount: Correct'],
        ['Tone: Ethereal', 'Warning: Missing Image URL', 'Layout: Clean'],
        ['Error: Lore Contradiction', 'Tone: Modern (Mismatched)', 'Layout: Short Answers'],
      ];
      final loreDiagnoses = [
        'DeepSeek-V4-Pro: Background checks out. Fully compliant with the Great Rift Peace accord of the Third Age.',
        'DeepSeek-V4-Pro: High compatibility score. Slight discrepancy concerning historical lineage of House Vance.',
        'DeepSeek-V4-Pro: Rejected. Claimant states they survived the Obsidian Purge, which is structurally impossible according to lore records.',
      ];
      final formattingDiagnoses = [
        'Groq-Llama-4: Structure matches guidelines. Text block density optimal.',
        'Groq-Llama-4: Missing faceclaim registry picture. Text block density optimal.',
        'Groq-Llama-4: Form failed validation. Answer #3 contains forbidden modern colloquialisms.',
      ];

      final result = AIGradingResult(
        appId: appId,
        deepseekScore: scores[hashIndex],
        groqFlags: flags[hashIndex],
        loreAnalysis: loreDiagnoses[hashIndex],
        formattingAnalysis: formattingDiagnoses[hashIndex],
      );

      state = AsyncValue.data({
        ...currentMap,
        appId: result,
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider exposing the AI evaluations map.
final aiGradingProvider =
    AsyncNotifierProvider<AIGradingNotifier, Map<String, AIGradingResult>>(() {
  return AIGradingNotifier();
});
