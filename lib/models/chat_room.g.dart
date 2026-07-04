// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => _ChatRoom(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  factionRestriction: json['faction_restriction'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ChatRoomToJson(_ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'faction_restriction': instance.factionRestriction,
  'created_at': instance.createdAt,
};
