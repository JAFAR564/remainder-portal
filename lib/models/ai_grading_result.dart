import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_grading_result.freezed.dart';
part 'ai_grading_result.g.dart';

@freezed
abstract class AIGradingResult with _$AIGradingResult {
  const factory AIGradingResult({
    @JsonKey(name: 'app_id') required String appId,
    @JsonKey(name: 'deepseek_score') required double deepseekScore,
    @JsonKey(name: 'groq_flags') required List<String> groqFlags,
    @JsonKey(name: 'lore_analysis') required String loreAnalysis,
    @JsonKey(name: 'formatting_analysis') required String formattingAnalysis,
  }) = _AIGradingResult;

  factory AIGradingResult.fromJson(Map<String, dynamic> json) =>
      _$AIGradingResultFromJson(json);
}
