import 'package:freezed_annotation/freezed_annotation.dart';

part 'debug_report.freezed.dart';
part 'debug_report.g.dart';

@freezed
abstract class DebugReport with _$DebugReport {
  const factory DebugReport({
    String? id,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'applicant_email') required String applicantEmail,
    @JsonKey(name: 'character_name') required String characterName,
    String? comment,
    @JsonKey(name: 'screenshot_base64') String? screenshotBase64,
    @JsonKey(name: 'route_path') String? routePath,
    String? category,
  }) = _DebugReport;

  factory DebugReport.fromJson(Map<String, dynamic> json) =>
      _$DebugReportFromJson(json);
}
