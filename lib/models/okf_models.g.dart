// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'okf_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoreChunk _$LoreChunkFromJson(Map<String, dynamic> json) => _LoreChunk(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      relevanceScore: (json['relevance_score'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LoreChunkToJson(_LoreChunk instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'relevance_score': instance.relevanceScore,
      'metadata': instance.metadata,
    };

_OKFQueryResult _$OKFQueryResultFromJson(Map<String, dynamic> json) =>
    _OKFQueryResult(
      chunks: (json['chunks'] as List<dynamic>)
          .map((e) => LoreChunk.fromJson(e as Map<String, dynamic>))
          .toList(),
      relevanceScore: (json['relevance_score'] as num).toDouble(),
      citationSources: (json['citation_sources'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OKFQueryResultToJson(_OKFQueryResult instance) =>
    <String, dynamic>{
      'chunks': instance.chunks,
      'relevance_score': instance.relevanceScore,
      'citation_sources': instance.citationSources,
    };
