// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_grading_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIGradingResult {
  @JsonKey(name: 'app_id')
  String get appId;
  @JsonKey(name: 'deepseek_score')
  double get deepseekScore;
  @JsonKey(name: 'groq_flags')
  List<String> get groqFlags;
  @JsonKey(name: 'lore_analysis')
  String get loreAnalysis;
  @JsonKey(name: 'formatting_analysis')
  String get formattingAnalysis;

  /// Create a copy of AIGradingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIGradingResultCopyWith<AIGradingResult> get copyWith =>
      _$AIGradingResultCopyWithImpl<AIGradingResult>(
          this as AIGradingResult, _$identity);

  /// Serializes this AIGradingResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIGradingResult &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.deepseekScore, deepseekScore) ||
                other.deepseekScore == deepseekScore) &&
            const DeepCollectionEquality().equals(other.groqFlags, groqFlags) &&
            (identical(other.loreAnalysis, loreAnalysis) ||
                other.loreAnalysis == loreAnalysis) &&
            (identical(other.formattingAnalysis, formattingAnalysis) ||
                other.formattingAnalysis == formattingAnalysis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      appId,
      deepseekScore,
      const DeepCollectionEquality().hash(groqFlags),
      loreAnalysis,
      formattingAnalysis);

  @override
  String toString() {
    return 'AIGradingResult(appId: $appId, deepseekScore: $deepseekScore, groqFlags: $groqFlags, loreAnalysis: $loreAnalysis, formattingAnalysis: $formattingAnalysis)';
  }
}

/// @nodoc
abstract mixin class $AIGradingResultCopyWith<$Res> {
  factory $AIGradingResultCopyWith(
          AIGradingResult value, $Res Function(AIGradingResult) _then) =
      _$AIGradingResultCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'app_id') String appId,
      @JsonKey(name: 'deepseek_score') double deepseekScore,
      @JsonKey(name: 'groq_flags') List<String> groqFlags,
      @JsonKey(name: 'lore_analysis') String loreAnalysis,
      @JsonKey(name: 'formatting_analysis') String formattingAnalysis});
}

/// @nodoc
class _$AIGradingResultCopyWithImpl<$Res>
    implements $AIGradingResultCopyWith<$Res> {
  _$AIGradingResultCopyWithImpl(this._self, this._then);

  final AIGradingResult _self;
  final $Res Function(AIGradingResult) _then;

  /// Create a copy of AIGradingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? deepseekScore = null,
    Object? groqFlags = null,
    Object? loreAnalysis = null,
    Object? formattingAnalysis = null,
  }) {
    return _then(_self.copyWith(
      appId: null == appId
          ? _self.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      deepseekScore: null == deepseekScore
          ? _self.deepseekScore
          : deepseekScore // ignore: cast_nullable_to_non_nullable
              as double,
      groqFlags: null == groqFlags
          ? _self.groqFlags
          : groqFlags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      loreAnalysis: null == loreAnalysis
          ? _self.loreAnalysis
          : loreAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      formattingAnalysis: null == formattingAnalysis
          ? _self.formattingAnalysis
          : formattingAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIGradingResult].
extension AIGradingResultPatterns on AIGradingResult {
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
    TResult Function(_AIGradingResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult() when $default != null:
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
    TResult Function(_AIGradingResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult():
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
    TResult? Function(_AIGradingResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult() when $default != null:
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
            @JsonKey(name: 'app_id') String appId,
            @JsonKey(name: 'deepseek_score') double deepseekScore,
            @JsonKey(name: 'groq_flags') List<String> groqFlags,
            @JsonKey(name: 'lore_analysis') String loreAnalysis,
            @JsonKey(name: 'formatting_analysis') String formattingAnalysis)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult() when $default != null:
        return $default(_that.appId, _that.deepseekScore, _that.groqFlags,
            _that.loreAnalysis, _that.formattingAnalysis);
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
            @JsonKey(name: 'app_id') String appId,
            @JsonKey(name: 'deepseek_score') double deepseekScore,
            @JsonKey(name: 'groq_flags') List<String> groqFlags,
            @JsonKey(name: 'lore_analysis') String loreAnalysis,
            @JsonKey(name: 'formatting_analysis') String formattingAnalysis)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult():
        return $default(_that.appId, _that.deepseekScore, _that.groqFlags,
            _that.loreAnalysis, _that.formattingAnalysis);
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
            @JsonKey(name: 'app_id') String appId,
            @JsonKey(name: 'deepseek_score') double deepseekScore,
            @JsonKey(name: 'groq_flags') List<String> groqFlags,
            @JsonKey(name: 'lore_analysis') String loreAnalysis,
            @JsonKey(name: 'formatting_analysis') String formattingAnalysis)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIGradingResult() when $default != null:
        return $default(_that.appId, _that.deepseekScore, _that.groqFlags,
            _that.loreAnalysis, _that.formattingAnalysis);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AIGradingResult implements AIGradingResult {
  const _AIGradingResult(
      {@JsonKey(name: 'app_id') required this.appId,
      @JsonKey(name: 'deepseek_score') required this.deepseekScore,
      @JsonKey(name: 'groq_flags') required final List<String> groqFlags,
      @JsonKey(name: 'lore_analysis') required this.loreAnalysis,
      @JsonKey(name: 'formatting_analysis') required this.formattingAnalysis})
      : _groqFlags = groqFlags;
  factory _AIGradingResult.fromJson(Map<String, dynamic> json) =>
      _$AIGradingResultFromJson(json);

  @override
  @JsonKey(name: 'app_id')
  final String appId;
  @override
  @JsonKey(name: 'deepseek_score')
  final double deepseekScore;
  final List<String> _groqFlags;
  @override
  @JsonKey(name: 'groq_flags')
  List<String> get groqFlags {
    if (_groqFlags is EqualUnmodifiableListView) return _groqFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groqFlags);
  }

  @override
  @JsonKey(name: 'lore_analysis')
  final String loreAnalysis;
  @override
  @JsonKey(name: 'formatting_analysis')
  final String formattingAnalysis;

  /// Create a copy of AIGradingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIGradingResultCopyWith<_AIGradingResult> get copyWith =>
      __$AIGradingResultCopyWithImpl<_AIGradingResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AIGradingResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIGradingResult &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.deepseekScore, deepseekScore) ||
                other.deepseekScore == deepseekScore) &&
            const DeepCollectionEquality()
                .equals(other._groqFlags, _groqFlags) &&
            (identical(other.loreAnalysis, loreAnalysis) ||
                other.loreAnalysis == loreAnalysis) &&
            (identical(other.formattingAnalysis, formattingAnalysis) ||
                other.formattingAnalysis == formattingAnalysis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      appId,
      deepseekScore,
      const DeepCollectionEquality().hash(_groqFlags),
      loreAnalysis,
      formattingAnalysis);

  @override
  String toString() {
    return 'AIGradingResult(appId: $appId, deepseekScore: $deepseekScore, groqFlags: $groqFlags, loreAnalysis: $loreAnalysis, formattingAnalysis: $formattingAnalysis)';
  }
}

/// @nodoc
abstract mixin class _$AIGradingResultCopyWith<$Res>
    implements $AIGradingResultCopyWith<$Res> {
  factory _$AIGradingResultCopyWith(
          _AIGradingResult value, $Res Function(_AIGradingResult) _then) =
      __$AIGradingResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'app_id') String appId,
      @JsonKey(name: 'deepseek_score') double deepseekScore,
      @JsonKey(name: 'groq_flags') List<String> groqFlags,
      @JsonKey(name: 'lore_analysis') String loreAnalysis,
      @JsonKey(name: 'formatting_analysis') String formattingAnalysis});
}

/// @nodoc
class __$AIGradingResultCopyWithImpl<$Res>
    implements _$AIGradingResultCopyWith<$Res> {
  __$AIGradingResultCopyWithImpl(this._self, this._then);

  final _AIGradingResult _self;
  final $Res Function(_AIGradingResult) _then;

  /// Create a copy of AIGradingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? appId = null,
    Object? deepseekScore = null,
    Object? groqFlags = null,
    Object? loreAnalysis = null,
    Object? formattingAnalysis = null,
  }) {
    return _then(_AIGradingResult(
      appId: null == appId
          ? _self.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      deepseekScore: null == deepseekScore
          ? _self.deepseekScore
          : deepseekScore // ignore: cast_nullable_to_non_nullable
              as double,
      groqFlags: null == groqFlags
          ? _self._groqFlags
          : groqFlags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      loreAnalysis: null == loreAnalysis
          ? _self.loreAnalysis
          : loreAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      formattingAnalysis: null == formattingAnalysis
          ? _self.formattingAnalysis
          : formattingAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
