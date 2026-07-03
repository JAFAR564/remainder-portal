// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Application {
  String get id;
  @JsonKey(name: 'submitted_at')
  String get submittedAt;
  @JsonKey(name: 'applicant_email')
  String get applicantEmail;
  @JsonKey(name: 'character_name')
  String get characterName;
  String get faction;
  List<String> get answers;
  String get status;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ApplicationCopyWith<Application> get copyWith =>
      _$ApplicationCopyWithImpl<Application>(this as Application, _$identity);

  /// Serializes this Application to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Application &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.applicantEmail, applicantEmail) ||
                other.applicantEmail == applicantEmail) &&
            (identical(other.characterName, characterName) ||
                other.characterName == characterName) &&
            (identical(other.faction, faction) || other.faction == faction) &&
            const DeepCollectionEquality().equals(other.answers, answers) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      submittedAt,
      applicantEmail,
      characterName,
      faction,
      const DeepCollectionEquality().hash(answers),
      status);

  @override
  String toString() {
    return 'Application(id: $id, submittedAt: $submittedAt, applicantEmail: $applicantEmail, characterName: $characterName, faction: $faction, answers: $answers, status: $status)';
  }
}

/// @nodoc
abstract mixin class $ApplicationCopyWith<$Res> {
  factory $ApplicationCopyWith(
          Application value, $Res Function(Application) _then) =
      _$ApplicationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'submitted_at') String submittedAt,
      @JsonKey(name: 'applicant_email') String applicantEmail,
      @JsonKey(name: 'character_name') String characterName,
      String faction,
      List<String> answers,
      String status});
}

/// @nodoc
class _$ApplicationCopyWithImpl<$Res> implements $ApplicationCopyWith<$Res> {
  _$ApplicationCopyWithImpl(this._self, this._then);

  final Application _self;
  final $Res Function(Application) _then;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submittedAt = null,
    Object? applicantEmail = null,
    Object? characterName = null,
    Object? faction = null,
    Object? answers = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _self.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String,
      applicantEmail: null == applicantEmail
          ? _self.applicantEmail
          : applicantEmail // ignore: cast_nullable_to_non_nullable
              as String,
      characterName: null == characterName
          ? _self.characterName
          : characterName // ignore: cast_nullable_to_non_nullable
              as String,
      faction: null == faction
          ? _self.faction
          : faction // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _self.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Application].
extension ApplicationPatterns on Application {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Application value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Application() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Application value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Application():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Application value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Application() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'submitted_at') String submittedAt,
            @JsonKey(name: 'applicant_email') String applicantEmail,
            @JsonKey(name: 'character_name') String characterName,
            String faction,
            List<String> answers,
            String status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Application() when $default != null:
        return $default(_that.id, _that.submittedAt, _that.applicantEmail,
            _that.characterName, _that.faction, _that.answers, _that.status);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'submitted_at') String submittedAt,
            @JsonKey(name: 'applicant_email') String applicantEmail,
            @JsonKey(name: 'character_name') String characterName,
            String faction,
            List<String> answers,
            String status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Application():
        return $default(_that.id, _that.submittedAt, _that.applicantEmail,
            _that.characterName, _that.faction, _that.answers, _that.status);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            @JsonKey(name: 'submitted_at') String submittedAt,
            @JsonKey(name: 'applicant_email') String applicantEmail,
            @JsonKey(name: 'character_name') String characterName,
            String faction,
            List<String> answers,
            String status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Application() when $default != null:
        return $default(_that.id, _that.submittedAt, _that.applicantEmail,
            _that.characterName, _that.faction, _that.answers, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Application implements Application {
  const _Application(
      {required this.id,
      @JsonKey(name: 'submitted_at') required this.submittedAt,
      @JsonKey(name: 'applicant_email') required this.applicantEmail,
      @JsonKey(name: 'character_name') required this.characterName,
      required this.faction,
      required final List<String> answers,
      required this.status})
      : _answers = answers;
  factory _Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'submitted_at')
  final String submittedAt;
  @override
  @JsonKey(name: 'applicant_email')
  final String applicantEmail;
  @override
  @JsonKey(name: 'character_name')
  final String characterName;
  @override
  final String faction;
  final List<String> _answers;
  @override
  List<String> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  final String status;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ApplicationCopyWith<_Application> get copyWith =>
      __$ApplicationCopyWithImpl<_Application>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ApplicationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Application &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.applicantEmail, applicantEmail) ||
                other.applicantEmail == applicantEmail) &&
            (identical(other.characterName, characterName) ||
                other.characterName == characterName) &&
            (identical(other.faction, faction) || other.faction == faction) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      submittedAt,
      applicantEmail,
      characterName,
      faction,
      const DeepCollectionEquality().hash(_answers),
      status);

  @override
  String toString() {
    return 'Application(id: $id, submittedAt: $submittedAt, applicantEmail: $applicantEmail, characterName: $characterName, faction: $faction, answers: $answers, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$ApplicationCopyWith<$Res>
    implements $ApplicationCopyWith<$Res> {
  factory _$ApplicationCopyWith(
          _Application value, $Res Function(_Application) _then) =
      __$ApplicationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'submitted_at') String submittedAt,
      @JsonKey(name: 'applicant_email') String applicantEmail,
      @JsonKey(name: 'character_name') String characterName,
      String faction,
      List<String> answers,
      String status});
}

/// @nodoc
class __$ApplicationCopyWithImpl<$Res> implements _$ApplicationCopyWith<$Res> {
  __$ApplicationCopyWithImpl(this._self, this._then);

  final _Application _self;
  final $Res Function(_Application) _then;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? submittedAt = null,
    Object? applicantEmail = null,
    Object? characterName = null,
    Object? faction = null,
    Object? answers = null,
    Object? status = null,
  }) {
    return _then(_Application(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _self.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String,
      applicantEmail: null == applicantEmail
          ? _self.applicantEmail
          : applicantEmail // ignore: cast_nullable_to_non_nullable
              as String,
      characterName: null == characterName
          ? _self.characterName
          : characterName // ignore: cast_nullable_to_non_nullable
              as String,
      faction: null == faction
          ? _self.faction
          : faction // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _self._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
