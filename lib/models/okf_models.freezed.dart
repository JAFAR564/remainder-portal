// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'okf_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoreChunk {
  String get id;
  String get title;
  String get content;
  @JsonKey(name: 'relevance_score')
  double get relevanceScore;
  Map<String, dynamic> get metadata;

  /// Create a copy of LoreChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoreChunkCopyWith<LoreChunk> get copyWith =>
      _$LoreChunkCopyWithImpl<LoreChunk>(this as LoreChunk, _$identity);

  /// Serializes this LoreChunk to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoreChunk &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, content,
      relevanceScore, const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'LoreChunk(id: $id, title: $title, content: $content, relevanceScore: $relevanceScore, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $LoreChunkCopyWith<$Res> {
  factory $LoreChunkCopyWith(LoreChunk value, $Res Function(LoreChunk) _then) =
      _$LoreChunkCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      @JsonKey(name: 'relevance_score') double relevanceScore,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$LoreChunkCopyWithImpl<$Res> implements $LoreChunkCopyWith<$Res> {
  _$LoreChunkCopyWithImpl(this._self, this._then);

  final LoreChunk _self;
  final $Res Function(LoreChunk) _then;

  /// Create a copy of LoreChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? relevanceScore = null,
    Object? metadata = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [LoreChunk].
extension LoreChunkPatterns on LoreChunk {
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
    TResult Function(_LoreChunk value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoreChunk() when $default != null:
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
    TResult Function(_LoreChunk value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoreChunk():
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
    TResult? Function(_LoreChunk value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoreChunk() when $default != null:
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
            String title,
            String content,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            Map<String, dynamic> metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoreChunk() when $default != null:
        return $default(_that.id, _that.title, _that.content,
            _that.relevanceScore, _that.metadata);
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
            String title,
            String content,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            Map<String, dynamic> metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoreChunk():
        return $default(_that.id, _that.title, _that.content,
            _that.relevanceScore, _that.metadata);
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
            String title,
            String content,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            Map<String, dynamic> metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LoreChunk() when $default != null:
        return $default(_that.id, _that.title, _that.content,
            _that.relevanceScore, _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LoreChunk implements LoreChunk {
  const _LoreChunk(
      {required this.id,
      required this.title,
      required this.content,
      @JsonKey(name: 'relevance_score') required this.relevanceScore,
      required final Map<String, dynamic> metadata})
      : _metadata = metadata;
  factory _LoreChunk.fromJson(Map<String, dynamic> json) =>
      _$LoreChunkFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey(name: 'relevance_score')
  final double relevanceScore;
  final Map<String, dynamic> _metadata;
  @override
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// Create a copy of LoreChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoreChunkCopyWith<_LoreChunk> get copyWith =>
      __$LoreChunkCopyWithImpl<_LoreChunk>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LoreChunkToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoreChunk &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, content,
      relevanceScore, const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'LoreChunk(id: $id, title: $title, content: $content, relevanceScore: $relevanceScore, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$LoreChunkCopyWith<$Res>
    implements $LoreChunkCopyWith<$Res> {
  factory _$LoreChunkCopyWith(
          _LoreChunk value, $Res Function(_LoreChunk) _then) =
      __$LoreChunkCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      @JsonKey(name: 'relevance_score') double relevanceScore,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$LoreChunkCopyWithImpl<$Res> implements _$LoreChunkCopyWith<$Res> {
  __$LoreChunkCopyWithImpl(this._self, this._then);

  final _LoreChunk _self;
  final $Res Function(_LoreChunk) _then;

  /// Create a copy of LoreChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? relevanceScore = null,
    Object? metadata = null,
  }) {
    return _then(_LoreChunk(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: null == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$OKFQueryResult {
  List<LoreChunk> get chunks;
  @JsonKey(name: 'relevance_score')
  double get relevanceScore;
  @JsonKey(name: 'citation_sources')
  List<String> get citationSources;

  /// Create a copy of OKFQueryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OKFQueryResultCopyWith<OKFQueryResult> get copyWith =>
      _$OKFQueryResultCopyWithImpl<OKFQueryResult>(
          this as OKFQueryResult, _$identity);

  /// Serializes this OKFQueryResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OKFQueryResult &&
            const DeepCollectionEquality().equals(other.chunks, chunks) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            const DeepCollectionEquality()
                .equals(other.citationSources, citationSources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(chunks),
      relevanceScore,
      const DeepCollectionEquality().hash(citationSources));

  @override
  String toString() {
    return 'OKFQueryResult(chunks: $chunks, relevanceScore: $relevanceScore, citationSources: $citationSources)';
  }
}

/// @nodoc
abstract mixin class $OKFQueryResultCopyWith<$Res> {
  factory $OKFQueryResultCopyWith(
          OKFQueryResult value, $Res Function(OKFQueryResult) _then) =
      _$OKFQueryResultCopyWithImpl;
  @useResult
  $Res call(
      {List<LoreChunk> chunks,
      @JsonKey(name: 'relevance_score') double relevanceScore,
      @JsonKey(name: 'citation_sources') List<String> citationSources});
}

/// @nodoc
class _$OKFQueryResultCopyWithImpl<$Res>
    implements $OKFQueryResultCopyWith<$Res> {
  _$OKFQueryResultCopyWithImpl(this._self, this._then);

  final OKFQueryResult _self;
  final $Res Function(OKFQueryResult) _then;

  /// Create a copy of OKFQueryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunks = null,
    Object? relevanceScore = null,
    Object? citationSources = null,
  }) {
    return _then(_self.copyWith(
      chunks: null == chunks
          ? _self.chunks
          : chunks // ignore: cast_nullable_to_non_nullable
              as List<LoreChunk>,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      citationSources: null == citationSources
          ? _self.citationSources
          : citationSources // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [OKFQueryResult].
extension OKFQueryResultPatterns on OKFQueryResult {
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
    TResult Function(_OKFQueryResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult() when $default != null:
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
    TResult Function(_OKFQueryResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult():
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
    TResult? Function(_OKFQueryResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult() when $default != null:
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
            List<LoreChunk> chunks,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            @JsonKey(name: 'citation_sources') List<String> citationSources)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult() when $default != null:
        return $default(
            _that.chunks, _that.relevanceScore, _that.citationSources);
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
            List<LoreChunk> chunks,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            @JsonKey(name: 'citation_sources') List<String> citationSources)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult():
        return $default(
            _that.chunks, _that.relevanceScore, _that.citationSources);
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
            List<LoreChunk> chunks,
            @JsonKey(name: 'relevance_score') double relevanceScore,
            @JsonKey(name: 'citation_sources') List<String> citationSources)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OKFQueryResult() when $default != null:
        return $default(
            _that.chunks, _that.relevanceScore, _that.citationSources);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OKFQueryResult implements OKFQueryResult {
  const _OKFQueryResult(
      {required final List<LoreChunk> chunks,
      @JsonKey(name: 'relevance_score') required this.relevanceScore,
      @JsonKey(name: 'citation_sources')
      required final List<String> citationSources})
      : _chunks = chunks,
        _citationSources = citationSources;
  factory _OKFQueryResult.fromJson(Map<String, dynamic> json) =>
      _$OKFQueryResultFromJson(json);

  final List<LoreChunk> _chunks;
  @override
  List<LoreChunk> get chunks {
    if (_chunks is EqualUnmodifiableListView) return _chunks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chunks);
  }

  @override
  @JsonKey(name: 'relevance_score')
  final double relevanceScore;
  final List<String> _citationSources;
  @override
  @JsonKey(name: 'citation_sources')
  List<String> get citationSources {
    if (_citationSources is EqualUnmodifiableListView) return _citationSources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_citationSources);
  }

  /// Create a copy of OKFQueryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OKFQueryResultCopyWith<_OKFQueryResult> get copyWith =>
      __$OKFQueryResultCopyWithImpl<_OKFQueryResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OKFQueryResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OKFQueryResult &&
            const DeepCollectionEquality().equals(other._chunks, _chunks) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            const DeepCollectionEquality()
                .equals(other._citationSources, _citationSources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_chunks),
      relevanceScore,
      const DeepCollectionEquality().hash(_citationSources));

  @override
  String toString() {
    return 'OKFQueryResult(chunks: $chunks, relevanceScore: $relevanceScore, citationSources: $citationSources)';
  }
}

/// @nodoc
abstract mixin class _$OKFQueryResultCopyWith<$Res>
    implements $OKFQueryResultCopyWith<$Res> {
  factory _$OKFQueryResultCopyWith(
          _OKFQueryResult value, $Res Function(_OKFQueryResult) _then) =
      __$OKFQueryResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<LoreChunk> chunks,
      @JsonKey(name: 'relevance_score') double relevanceScore,
      @JsonKey(name: 'citation_sources') List<String> citationSources});
}

/// @nodoc
class __$OKFQueryResultCopyWithImpl<$Res>
    implements _$OKFQueryResultCopyWith<$Res> {
  __$OKFQueryResultCopyWithImpl(this._self, this._then);

  final _OKFQueryResult _self;
  final $Res Function(_OKFQueryResult) _then;

  /// Create a copy of OKFQueryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chunks = null,
    Object? relevanceScore = null,
    Object? citationSources = null,
  }) {
    return _then(_OKFQueryResult(
      chunks: null == chunks
          ? _self._chunks
          : chunks // ignore: cast_nullable_to_non_nullable
              as List<LoreChunk>,
      relevanceScore: null == relevanceScore
          ? _self.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      citationSources: null == citationSources
          ? _self._citationSources
          : citationSources // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
