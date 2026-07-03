// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Application _$ApplicationFromJson(Map<String, dynamic> json) => _Application(
      id: json['id'] as String,
      submittedAt: json['submitted_at'] as String,
      applicantEmail: json['applicant_email'] as String,
      characterName: json['character_name'] as String,
      faction: json['faction'] as String,
      answers:
          (json['answers'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ApplicationToJson(_Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submitted_at': instance.submittedAt,
      'applicant_email': instance.applicantEmail,
      'character_name': instance.characterName,
      'faction': instance.faction,
      'answers': instance.answers,
      'status': instance.status,
    };
