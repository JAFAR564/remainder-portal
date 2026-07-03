import 'package:freezed_annotation/freezed_annotation.dart';

part 'okf_models.freezed.dart';
part 'okf_models.g.dart';

@freezed
abstract class LoreChunk with _$LoreChunk {
  const factory LoreChunk({
    required String id,
    required String title,
    required String content,
    @JsonKey(name: 'relevance_score') required double relevanceScore,
    required Map<String, dynamic> metadata,
  }) = _LoreChunk;

  factory LoreChunk.fromJson(Map<String, dynamic> json) =>
      _$LoreChunkFromJson(json);
}

@freezed
abstract class OKFQueryResult with _$OKFQueryResult {
  const factory OKFQueryResult({
    required List<LoreChunk> chunks,
    @JsonKey(name: 'relevance_score') required double relevanceScore,
    @JsonKey(name: 'citation_sources') required List<String> citationSources,
  }) = _OKFQueryResult;

  factory OKFQueryResult.fromJson(Map<String, dynamic> json) =>
      _$OKFQueryResultFromJson(json);
}
