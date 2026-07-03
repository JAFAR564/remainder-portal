// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_grading_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIGradingResult _$AIGradingResultFromJson(Map<String, dynamic> json) =>
    _AIGradingResult(
      appId: json['app_id'] as String,
      deepseekScore: (json['deepseek_score'] as num).toDouble(),
      groqFlags: (json['groq_flags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      loreAnalysis: json['lore_analysis'] as String,
      formattingAnalysis: json['formatting_analysis'] as String,
    );

Map<String, dynamic> _$AIGradingResultToJson(_AIGradingResult instance) =>
    <String, dynamic>{
      'app_id': instance.appId,
      'deepseek_score': instance.deepseekScore,
      'groq_flags': instance.groqFlags,
      'lore_analysis': instance.loreAnalysis,
      'formatting_analysis': instance.formattingAnalysis,
    };
