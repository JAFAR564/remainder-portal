// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RosterMember _$RosterMemberFromJson(Map<String, dynamic> json) =>
    _RosterMember(
      id: json['id'] as String,
      characterName: json['character_name'] as String,
      playerName: json['player_name'] as String,
      faction: json['faction'] as String,
      faceclaimName: json['faceclaim_name'] as String,
      faceclaimImgUrl: json['faceclaim_img_url'] as String,
      status: json['status'] as String,
      joinedDate: json['joined_date'] as String,
    );

Map<String, dynamic> _$RosterMemberToJson(_RosterMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'character_name': instance.characterName,
      'player_name': instance.playerName,
      'faction': instance.faction,
      'faceclaim_name': instance.faceclaimName,
      'faceclaim_img_url': instance.faceclaimImgUrl,
      'status': instance.status,
      'joined_date': instance.joinedDate,
    };
