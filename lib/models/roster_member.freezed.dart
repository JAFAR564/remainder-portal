// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'roster_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RosterMember {

 String get id;@JsonKey(name: 'character_name') String get characterName;@JsonKey(name: 'player_name') String get playerName; String get faction;@JsonKey(name: 'faceclaim_name') String get faceclaimName;@JsonKey(name: 'faceclaim_img_url') String get faceclaimImgUrl; String get status;@JsonKey(name: 'joined_date') String get joinedDate;
/// Create a copy of RosterMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RosterMemberCopyWith<RosterMember> get copyWith => _$RosterMemberCopyWithImpl<RosterMember>(this as RosterMember, _$identity);

  /// Serializes this RosterMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RosterMember&&(identical(other.id, id) || other.id == id)&&(identical(other.characterName, characterName) || other.characterName == characterName)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.faction, faction) || other.faction == faction)&&(identical(other.faceclaimName, faceclaimName) || other.faceclaimName == faceclaimName)&&(identical(other.faceclaimImgUrl, faceclaimImgUrl) || other.faceclaimImgUrl == faceclaimImgUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedDate, joinedDate) || other.joinedDate == joinedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterName,playerName,faction,faceclaimName,faceclaimImgUrl,status,joinedDate);

@override
String toString() {
  return 'RosterMember(id: $id, characterName: $characterName, playerName: $playerName, faction: $faction, faceclaimName: $faceclaimName, faceclaimImgUrl: $faceclaimImgUrl, status: $status, joinedDate: $joinedDate)';
}


}

/// @nodoc
abstract mixin class $RosterMemberCopyWith<$Res>  {
  factory $RosterMemberCopyWith(RosterMember value, $Res Function(RosterMember) _then) = _$RosterMemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'character_name') String characterName,@JsonKey(name: 'player_name') String playerName, String faction,@JsonKey(name: 'faceclaim_name') String faceclaimName,@JsonKey(name: 'faceclaim_img_url') String faceclaimImgUrl, String status,@JsonKey(name: 'joined_date') String joinedDate
});




}
/// @nodoc
class _$RosterMemberCopyWithImpl<$Res>
    implements $RosterMemberCopyWith<$Res> {
  _$RosterMemberCopyWithImpl(this._self, this._then);

  final RosterMember _self;
  final $Res Function(RosterMember) _then;

/// Create a copy of RosterMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? characterName = null,Object? playerName = null,Object? faction = null,Object? faceclaimName = null,Object? faceclaimImgUrl = null,Object? status = null,Object? joinedDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,characterName: null == characterName ? _self.characterName : characterName // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,faction: null == faction ? _self.faction : faction // ignore: cast_nullable_to_non_nullable
as String,faceclaimName: null == faceclaimName ? _self.faceclaimName : faceclaimName // ignore: cast_nullable_to_non_nullable
as String,faceclaimImgUrl: null == faceclaimImgUrl ? _self.faceclaimImgUrl : faceclaimImgUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedDate: null == joinedDate ? _self.joinedDate : joinedDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RosterMember].
extension RosterMemberPatterns on RosterMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RosterMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RosterMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RosterMember value)  $default,){
final _that = this;
switch (_that) {
case _RosterMember():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RosterMember value)?  $default,){
final _that = this;
switch (_that) {
case _RosterMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'character_name')  String characterName, @JsonKey(name: 'player_name')  String playerName,  String faction, @JsonKey(name: 'faceclaim_name')  String faceclaimName, @JsonKey(name: 'faceclaim_img_url')  String faceclaimImgUrl,  String status, @JsonKey(name: 'joined_date')  String joinedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RosterMember() when $default != null:
return $default(_that.id,_that.characterName,_that.playerName,_that.faction,_that.faceclaimName,_that.faceclaimImgUrl,_that.status,_that.joinedDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'character_name')  String characterName, @JsonKey(name: 'player_name')  String playerName,  String faction, @JsonKey(name: 'faceclaim_name')  String faceclaimName, @JsonKey(name: 'faceclaim_img_url')  String faceclaimImgUrl,  String status, @JsonKey(name: 'joined_date')  String joinedDate)  $default,) {final _that = this;
switch (_that) {
case _RosterMember():
return $default(_that.id,_that.characterName,_that.playerName,_that.faction,_that.faceclaimName,_that.faceclaimImgUrl,_that.status,_that.joinedDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'character_name')  String characterName, @JsonKey(name: 'player_name')  String playerName,  String faction, @JsonKey(name: 'faceclaim_name')  String faceclaimName, @JsonKey(name: 'faceclaim_img_url')  String faceclaimImgUrl,  String status, @JsonKey(name: 'joined_date')  String joinedDate)?  $default,) {final _that = this;
switch (_that) {
case _RosterMember() when $default != null:
return $default(_that.id,_that.characterName,_that.playerName,_that.faction,_that.faceclaimName,_that.faceclaimImgUrl,_that.status,_that.joinedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RosterMember implements RosterMember {
  const _RosterMember({required this.id, @JsonKey(name: 'character_name') required this.characterName, @JsonKey(name: 'player_name') required this.playerName, required this.faction, @JsonKey(name: 'faceclaim_name') required this.faceclaimName, @JsonKey(name: 'faceclaim_img_url') required this.faceclaimImgUrl, required this.status, @JsonKey(name: 'joined_date') required this.joinedDate});
  factory _RosterMember.fromJson(Map<String, dynamic> json) => _$RosterMemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'character_name') final  String characterName;
@override@JsonKey(name: 'player_name') final  String playerName;
@override final  String faction;
@override@JsonKey(name: 'faceclaim_name') final  String faceclaimName;
@override@JsonKey(name: 'faceclaim_img_url') final  String faceclaimImgUrl;
@override final  String status;
@override@JsonKey(name: 'joined_date') final  String joinedDate;

/// Create a copy of RosterMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RosterMemberCopyWith<_RosterMember> get copyWith => __$RosterMemberCopyWithImpl<_RosterMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RosterMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RosterMember&&(identical(other.id, id) || other.id == id)&&(identical(other.characterName, characterName) || other.characterName == characterName)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.faction, faction) || other.faction == faction)&&(identical(other.faceclaimName, faceclaimName) || other.faceclaimName == faceclaimName)&&(identical(other.faceclaimImgUrl, faceclaimImgUrl) || other.faceclaimImgUrl == faceclaimImgUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedDate, joinedDate) || other.joinedDate == joinedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterName,playerName,faction,faceclaimName,faceclaimImgUrl,status,joinedDate);

@override
String toString() {
  return 'RosterMember(id: $id, characterName: $characterName, playerName: $playerName, faction: $faction, faceclaimName: $faceclaimName, faceclaimImgUrl: $faceclaimImgUrl, status: $status, joinedDate: $joinedDate)';
}


}

/// @nodoc
abstract mixin class _$RosterMemberCopyWith<$Res> implements $RosterMemberCopyWith<$Res> {
  factory _$RosterMemberCopyWith(_RosterMember value, $Res Function(_RosterMember) _then) = __$RosterMemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'character_name') String characterName,@JsonKey(name: 'player_name') String playerName, String faction,@JsonKey(name: 'faceclaim_name') String faceclaimName,@JsonKey(name: 'faceclaim_img_url') String faceclaimImgUrl, String status,@JsonKey(name: 'joined_date') String joinedDate
});




}
/// @nodoc
class __$RosterMemberCopyWithImpl<$Res>
    implements _$RosterMemberCopyWith<$Res> {
  __$RosterMemberCopyWithImpl(this._self, this._then);

  final _RosterMember _self;
  final $Res Function(_RosterMember) _then;

/// Create a copy of RosterMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? characterName = null,Object? playerName = null,Object? faction = null,Object? faceclaimName = null,Object? faceclaimImgUrl = null,Object? status = null,Object? joinedDate = null,}) {
  return _then(_RosterMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,characterName: null == characterName ? _self.characterName : characterName // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,faction: null == faction ? _self.faction : faction // ignore: cast_nullable_to_non_nullable
as String,faceclaimName: null == faceclaimName ? _self.faceclaimName : faceclaimName // ignore: cast_nullable_to_non_nullable
as String,faceclaimImgUrl: null == faceclaimImgUrl ? _self.faceclaimImgUrl : faceclaimImgUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedDate: null == joinedDate ? _self.joinedDate : joinedDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
