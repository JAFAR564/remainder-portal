import 'package:freezed_annotation/freezed_annotation.dart';

part 'roster_member.freezed.dart';
part 'roster_member.g.dart';

@freezed
abstract class RosterMember with _$RosterMember {
  const factory RosterMember({
    required String id,
    @JsonKey(name: 'character_name') required String characterName,
    @JsonKey(name: 'player_name') required String playerName,
    required String faction,
    @JsonKey(name: 'faceclaim_name') required String faceclaimName,
    @JsonKey(name: 'faceclaim_img_url') required String faceclaimImgUrl,
    required String status,
    @JsonKey(name: 'joined_date') required String joinedDate,
  }) = _RosterMember;

  factory RosterMember.fromJson(Map<String, dynamic> json) =>
      _$RosterMemberFromJson(json);
}
