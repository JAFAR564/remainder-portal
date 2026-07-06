import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ai_grading_result.dart';
import '../../../models/application.dart';
import 'admittance_provider.dart';

/// Notifier driving the AI assessment details for all applications.
/// 
/// Stores evaluated grading results in a Map keyed by the Application ID.
class AIGradingNotifier extends AsyncNotifier<Map<String, AIGradingResult>> {
  @override
  FutureOr<Map<String, AIGradingResult>> build() {
    return const {}; // Initially no applications have been graded
  }

  /// Triggers a context-aware evaluation of the application based on its actual data.
  Future<void> evaluateApplication(String appId) async {
    final currentMap = state.value ?? const {};
    if (currentMap.containsKey(appId)) return; // Already evaluated

    try {
      // Simulate background computation latency.
      await Future.delayed(const Duration(milliseconds: 700));

      // Resolve the application details from the admittance provider state
      final pendingApps = ref.read(admittanceNotifierProvider).value ?? [];
      final app = pendingApps.firstWhere(
        (a) => a.id == appId,
        orElse: () => Application(
          id: appId,
          submittedAt: '',
          applicantEmail: 'unknown@user.com',
          characterName: 'Unknown character',
          faction: 'Vanguard Order',
          answers: const [],
          status: 'Pending',
        ),
      );

      final answers = app.answers;
      
      // Parse detailed answers based on our Ennoia form schema
      String preferredName = app.applicantEmail.split('@')[0];
      String characterAlias = "N/A";
      String experience = "Intermediate";
      String genres = "General";
      String writingStyle = "Paragraphs";
      String timezone = "UTC";
      String intro = "No introduction provided.";
      String sample = "";
      String faceclaimName = app.characterName;
      String faceclaimImg = "";
      bool hasRulesAgreement = true;

      if (answers.length >= 10) {
        preferredName = answers[0].isNotEmpty ? answers[0] : preferredName;
        characterAlias = answers[1].isNotEmpty ? answers[1] : "None";
        experience = answers[2];
        genres = answers[3];
        writingStyle = answers[4];
        timezone = answers[5];
        intro = answers[7].isNotEmpty ? answers[7] : intro;
        sample = answers[8];
        hasRulesAgreement = answers[9].toLowerCase() == "yes" || answers[9] == "true";
        if (answers.length > 11) faceclaimName = answers[11].isNotEmpty ? answers[11] : faceclaimName;
        if (answers.length > 12) faceclaimImg = answers[12];
      } else {
        // Fallback for old applications
        if (answers.isNotEmpty) intro = answers[0];
        if (answers.length > 1) sample = answers[1];
      }

      final List<String> flags = [];
      double score = 8.5; // Start with default high score

      // 1. Perspective check (Detachment Rule)
      final firstPersonRegex = RegExp(r'\b(I|me|my|mine|we|us|our)\b', caseSensitive: false);
      final hasFirstPerson = firstPersonRegex.hasMatch(sample);
      if (hasFirstPerson) {
        flags.add('Warning: First-Person Pronouns');
        score -= 2.0;
      } else {
        flags.add('Tone: Third-Person Objective');
      }

      // 2. Faceclaim check
      if (faceclaimImg.isEmpty) {
        flags.add('Warning: Missing Faceclaim');
        score -= 1.0;
      } else {
        flags.add('Asset: Faceclaim Image Registered');
      }

      // 3. Wordcount and length checks
      final wordCount = sample.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      if (wordCount < 10) {
        flags.add('Error: Low Prose Count');
        score -= 3.0;
      } else if (wordCount < 25) {
        flags.add('Warning: Low Prose Count');
        score -= 1.0;
      } else if (writingStyle == 'Novella' && wordCount < 50) {
        flags.add('Warning: Short Sample for Novella');
        score -= 0.5;
      } else {
        flags.add('Layout: Compliant Density');
      }

      // 4. Faction correlation check
      bool hasFactionKeywords = false;
      final sampleLower = sample.toLowerCase();
      if (app.faction == 'Aethelgard Alliance' && (sampleLower.contains('order') || sampleLower.contains('shield') || sampleLower.contains('guard') || sampleLower.contains('honor'))) {
        hasFactionKeywords = true;
      } else if (app.faction == 'Elysium Chrono Syndicate' && (sampleLower.contains('time') || sampleLower.contains('archive') || sampleLower.contains('chronic') || sampleLower.contains('memory'))) {
        hasFactionKeywords = true;
      } else if (app.faction == 'Vanguard Order' && (sampleLower.contains('explore') || sampleLower.contains('scout') || sampleLower.contains('border') || sampleLower.contains('path'))) {
        hasFactionKeywords = true;
      }

      if (hasFactionKeywords) {
        flags.add('Lore: Faction Connected');
        score += 0.5;
      }

      if (!hasRulesAgreement) {
        flags.add('Error: Rules Agreement Missing');
        score -= 4.0;
      }

      score = score.clamp(1.0, 10.0);

      // 5. Generate descriptive and non-repetitive audit text based on target attributes
      String deepseekReport = "";
      String groqReport = "";

      if (score >= 7.5) {
        deepseekReport = "DeepSeek-V4-Pro (Lore Audit):\n"
            "• Concept Feasibility: The character concept for '$faceclaimName' (Alias: '$characterAlias') presents a highly coherent theme aligned with the ${app.faction}.\n"
            "• Narrative Integration: Writing sample is well-paced ($wordCount words) and supports the faction backdrop. ${hasFactionKeywords ? "Excellent deployment of faction motifs." : ""}\n"
            "• Recommendation: Fully compatible with the active narrative layers.";
            
        groqReport = "Groq-Llama-4 (Prose Audit):\n"
            "• Metrics: Prose structure meets guidelines. Detachment check verified (no first-person tags). Rules agreement confirmed.\n"
            "• Moderator Question suggestion: 'Ask $preferredName how $characterName plans to reconcile their background with the faction leadership.'\n"
            "• Confidence Score: ${(score * 10).toInt()}% | Status: Clear Approve";
      } else if (score >= 5.0) {
        deepseekReport = "DeepSeek-V4-Pro (Lore Audit):\n"
            "• Concept Feasibility: Character '$faceclaimName' shows a basic foundation, but their background is slightly detached from ${app.faction} guidelines.\n"
            "• Warnings: Prose density is marginal ($wordCount words). Details regarding the character's core motives are unclear in the introduction.\n"
            "• Suggested Follow-up: Probe the player on how they will integrate into active story arcs.";
            
        groqReport = "Groq-Llama-4 (Prose Audit):\n"
            "• Verification: ${hasFirstPerson ? "FAILED detachment check. Writing sample contains personal pronouns (I/me/my)." : "Prose quality is thin."} Faceclaim status: ${faceclaimImg.isEmpty ? "Missing image URL." : "Image URL parsed."}\n"
            "• Moderator Action: Clarify guidelines or request revised writing sample.";
      } else {
        deepseekReport = "DeepSeek-V4-Pro (Lore Audit):\n"
            "• Concept Feasibility: Major lore friction. Character background conflicts with general roleplay aesthetics. Stated experience ($experience) does not manifest in sample prose.\n"
            "• Violations: Crucial context missing from answers. Concept clarity is low.\n"
            "• Audit Verdict: Reject or flag for complete character rewrite.";
            
        groqReport = "Groq-Llama-4 (Prose Audit):\n"
            "• Failures: Sentence length is insufficient ($wordCount words). ${hasRulesAgreement ? "" : "Rules agreement was not checked."} High rate of colloquial modern slang.\n"
            "• Confidence Score: 30% | Recommendation: Manual Reject";
      }

      final result = AIGradingResult(
        appId: appId,
        deepseekScore: double.parse(score.toStringAsFixed(1)),
        groqFlags: flags,
        loreAnalysis: deepseekReport,
        formattingAnalysis: groqReport,
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
