// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  characterName: json['character_name'] as String,
  faction: json['faction'] as String,
  faceclaim: json['faceclaim'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'character_name': instance.characterName,
  'faction': instance.faction,
  'faceclaim': instance.faceclaim,
  'updated_at': instance.updatedAt,
};
