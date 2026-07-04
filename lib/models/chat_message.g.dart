// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  roomId: json['room_id'] as String,
  senderId: json['sender_id'] as String,
  content: json['content'] as String,
  createdAt: json['created_at'] as String,
  sender: json['sender'] == null
      ? null
      : Profile.fromJson(json['sender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'created_at': instance.createdAt,
      'sender': instance.sender,
    };
