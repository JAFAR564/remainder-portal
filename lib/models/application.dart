import 'package:freezed_annotation/freezed_annotation.dart';

part 'application.freezed.dart';
part 'application.g.dart';

@freezed
abstract class Application with _$Application {
  const factory Application({
    required String id,
    @JsonKey(name: 'submitted_at') required String submittedAt,
    @JsonKey(name: 'applicant_email') required String applicantEmail,
    @JsonKey(name: 'character_name') required String characterName,
    required String faction,
    required List<String> answers,
    required String status,
  }) = _Application;

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);
}
