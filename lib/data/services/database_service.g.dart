// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeSectorMeta = const VerificationMeta(
    'activeSector',
  );
  @override
  late final GeneratedColumn<String> activeSector = GeneratedColumn<String>(
    'active_sector',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reputationRanksMeta = const VerificationMeta(
    'reputationRanks',
  );
  @override
  late final GeneratedColumn<String> reputationRanks = GeneratedColumn<String>(
    'reputation_ranks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedDateMeta = const VerificationMeta(
    'joinedDate',
  );
  @override
  late final GeneratedColumn<DateTime> joinedDate = GeneratedColumn<DateTime>(
    'joined_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trustScoreMeta = const VerificationMeta(
    'trustScore',
  );
  @override
  late final GeneratedColumn<double> trustScore = GeneratedColumn<double>(
    'trust_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    email,
    origin,
    activeSector,
    reputationRanks,
    joinedDate,
    trustScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('active_sector')) {
      context.handle(
        _activeSectorMeta,
        activeSector.isAcceptableOrUnknown(
          data['active_sector']!,
          _activeSectorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeSectorMeta);
    }
    if (data.containsKey('reputation_ranks')) {
      context.handle(
        _reputationRanksMeta,
        reputationRanks.isAcceptableOrUnknown(
          data['reputation_ranks']!,
          _reputationRanksMeta,
        ),
      );
    }
    if (data.containsKey('joined_date')) {
      context.handle(
        _joinedDateMeta,
        joinedDate.isAcceptableOrUnknown(data['joined_date']!, _joinedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedDateMeta);
    }
    if (data.containsKey('trust_score')) {
      context.handle(
        _trustScoreMeta,
        trustScore.isAcceptableOrUnknown(data['trust_score']!, _trustScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_trustScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      activeSector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_sector'],
      )!,
      reputationRanks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reputation_ranks'],
      ),
      joinedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_date'],
      )!,
      trustScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trust_score'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String displayName;
  final String email;
  final String origin;
  final String activeSector;
  final String? reputationRanks;
  final DateTime joinedDate;
  final double trustScore;
  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.origin,
    required this.activeSector,
    this.reputationRanks,
    required this.joinedDate,
    required this.trustScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['email'] = Variable<String>(email);
    map['origin'] = Variable<String>(origin);
    map['active_sector'] = Variable<String>(activeSector);
    if (!nullToAbsent || reputationRanks != null) {
      map['reputation_ranks'] = Variable<String>(reputationRanks);
    }
    map['joined_date'] = Variable<DateTime>(joinedDate);
    map['trust_score'] = Variable<double>(trustScore);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email: Value(email),
      origin: Value(origin),
      activeSector: Value(activeSector),
      reputationRanks: reputationRanks == null && nullToAbsent
          ? const Value.absent()
          : Value(reputationRanks),
      joinedDate: Value(joinedDate),
      trustScore: Value(trustScore),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String>(json['email']),
      origin: serializer.fromJson<String>(json['origin']),
      activeSector: serializer.fromJson<String>(json['activeSector']),
      reputationRanks: serializer.fromJson<String?>(json['reputationRanks']),
      joinedDate: serializer.fromJson<DateTime>(json['joinedDate']),
      trustScore: serializer.fromJson<double>(json['trustScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String>(email),
      'origin': serializer.toJson<String>(origin),
      'activeSector': serializer.toJson<String>(activeSector),
      'reputationRanks': serializer.toJson<String?>(reputationRanks),
      'joinedDate': serializer.toJson<DateTime>(joinedDate),
      'trustScore': serializer.toJson<double>(trustScore),
    };
  }

  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? origin,
    String? activeSector,
    Value<String?> reputationRanks = const Value.absent(),
    DateTime? joinedDate,
    double? trustScore,
  }) => User(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    origin: origin ?? this.origin,
    activeSector: activeSector ?? this.activeSector,
    reputationRanks: reputationRanks.present
        ? reputationRanks.value
        : this.reputationRanks,
    joinedDate: joinedDate ?? this.joinedDate,
    trustScore: trustScore ?? this.trustScore,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      origin: data.origin.present ? data.origin.value : this.origin,
      activeSector: data.activeSector.present
          ? data.activeSector.value
          : this.activeSector,
      reputationRanks: data.reputationRanks.present
          ? data.reputationRanks.value
          : this.reputationRanks,
      joinedDate: data.joinedDate.present
          ? data.joinedDate.value
          : this.joinedDate,
      trustScore: data.trustScore.present
          ? data.trustScore.value
          : this.trustScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('origin: $origin, ')
          ..write('activeSector: $activeSector, ')
          ..write('reputationRanks: $reputationRanks, ')
          ..write('joinedDate: $joinedDate, ')
          ..write('trustScore: $trustScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    email,
    origin,
    activeSector,
    reputationRanks,
    joinedDate,
    trustScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.origin == this.origin &&
          other.activeSector == this.activeSector &&
          other.reputationRanks == this.reputationRanks &&
          other.joinedDate == this.joinedDate &&
          other.trustScore == this.trustScore);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> email;
  final Value<String> origin;
  final Value<String> activeSector;
  final Value<String?> reputationRanks;
  final Value<DateTime> joinedDate;
  final Value<double> trustScore;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.origin = const Value.absent(),
    this.activeSector = const Value.absent(),
    this.reputationRanks = const Value.absent(),
    this.joinedDate = const Value.absent(),
    this.trustScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String displayName,
    required String email,
    required String origin,
    required String activeSector,
    this.reputationRanks = const Value.absent(),
    required DateTime joinedDate,
    required double trustScore,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       email = Value(email),
       origin = Value(origin),
       activeSector = Value(activeSector),
       joinedDate = Value(joinedDate),
       trustScore = Value(trustScore);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? origin,
    Expression<String>? activeSector,
    Expression<String>? reputationRanks,
    Expression<DateTime>? joinedDate,
    Expression<double>? trustScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (origin != null) 'origin': origin,
      if (activeSector != null) 'active_sector': activeSector,
      if (reputationRanks != null) 'reputation_ranks': reputationRanks,
      if (joinedDate != null) 'joined_date': joinedDate,
      if (trustScore != null) 'trust_score': trustScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? email,
    Value<String>? origin,
    Value<String>? activeSector,
    Value<String?>? reputationRanks,
    Value<DateTime>? joinedDate,
    Value<double>? trustScore,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      origin: origin ?? this.origin,
      activeSector: activeSector ?? this.activeSector,
      reputationRanks: reputationRanks ?? this.reputationRanks,
      joinedDate: joinedDate ?? this.joinedDate,
      trustScore: trustScore ?? this.trustScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (activeSector.present) {
      map['active_sector'] = Variable<String>(activeSector.value);
    }
    if (reputationRanks.present) {
      map['reputation_ranks'] = Variable<String>(reputationRanks.value);
    }
    if (joinedDate.present) {
      map['joined_date'] = Variable<DateTime>(joinedDate.value);
    }
    if (trustScore.present) {
      map['trust_score'] = Variable<double>(trustScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('origin: $origin, ')
          ..write('activeSector: $activeSector, ')
          ..write('reputationRanks: $reputationRanks, ')
          ..write('joinedDate: $joinedDate, ')
          ..write('trustScore: $trustScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoryThreadsTable extends StoryThreads
    with TableInfo<$StoryThreadsTable, StoryThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoryThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentSectorIdMeta = const VerificationMeta(
    'currentSectorId',
  );
  @override
  late final GeneratedColumn<String> currentSectorId = GeneratedColumn<String>(
    'current_sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastInteractionMeta = const VerificationMeta(
    'lastInteraction',
  );
  @override
  late final GeneratedColumn<DateTime> lastInteraction =
      GeneratedColumn<DateTime>(
        'last_interaction',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    currentSectorId,
    lastInteraction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'story_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoryThread> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('current_sector_id')) {
      context.handle(
        _currentSectorIdMeta,
        currentSectorId.isAcceptableOrUnknown(
          data['current_sector_id']!,
          _currentSectorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentSectorIdMeta);
    }
    if (data.containsKey('last_interaction')) {
      context.handle(
        _lastInteractionMeta,
        lastInteraction.isAcceptableOrUnknown(
          data['last_interaction']!,
          _lastInteractionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastInteractionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoryThread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoryThread(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      currentSectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_sector_id'],
      )!,
      lastInteraction: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_interaction'],
      )!,
    );
  }

  @override
  $StoryThreadsTable createAlias(String alias) {
    return $StoryThreadsTable(attachedDatabase, alias);
  }
}

class StoryThread extends DataClass implements Insertable<StoryThread> {
  final String id;
  final String userId;
  final String title;
  final String currentSectorId;
  final DateTime lastInteraction;
  const StoryThread({
    required this.id,
    required this.userId,
    required this.title,
    required this.currentSectorId,
    required this.lastInteraction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['current_sector_id'] = Variable<String>(currentSectorId);
    map['last_interaction'] = Variable<DateTime>(lastInteraction);
    return map;
  }

  StoryThreadsCompanion toCompanion(bool nullToAbsent) {
    return StoryThreadsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      currentSectorId: Value(currentSectorId),
      lastInteraction: Value(lastInteraction),
    );
  }

  factory StoryThread.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoryThread(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      currentSectorId: serializer.fromJson<String>(json['currentSectorId']),
      lastInteraction: serializer.fromJson<DateTime>(json['lastInteraction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'currentSectorId': serializer.toJson<String>(currentSectorId),
      'lastInteraction': serializer.toJson<DateTime>(lastInteraction),
    };
  }

  StoryThread copyWith({
    String? id,
    String? userId,
    String? title,
    String? currentSectorId,
    DateTime? lastInteraction,
  }) => StoryThread(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    currentSectorId: currentSectorId ?? this.currentSectorId,
    lastInteraction: lastInteraction ?? this.lastInteraction,
  );
  StoryThread copyWithCompanion(StoryThreadsCompanion data) {
    return StoryThread(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      currentSectorId: data.currentSectorId.present
          ? data.currentSectorId.value
          : this.currentSectorId,
      lastInteraction: data.lastInteraction.present
          ? data.lastInteraction.value
          : this.lastInteraction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoryThread(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('currentSectorId: $currentSectorId, ')
          ..write('lastInteraction: $lastInteraction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, currentSectorId, lastInteraction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryThread &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.currentSectorId == this.currentSectorId &&
          other.lastInteraction == this.lastInteraction);
}

class StoryThreadsCompanion extends UpdateCompanion<StoryThread> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> currentSectorId;
  final Value<DateTime> lastInteraction;
  final Value<int> rowid;
  const StoryThreadsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.currentSectorId = const Value.absent(),
    this.lastInteraction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoryThreadsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required String currentSectorId,
    required DateTime lastInteraction,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       currentSectorId = Value(currentSectorId),
       lastInteraction = Value(lastInteraction);
  static Insertable<StoryThread> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? currentSectorId,
    Expression<DateTime>? lastInteraction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (currentSectorId != null) 'current_sector_id': currentSectorId,
      if (lastInteraction != null) 'last_interaction': lastInteraction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoryThreadsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? currentSectorId,
    Value<DateTime>? lastInteraction,
    Value<int>? rowid,
  }) {
    return StoryThreadsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      currentSectorId: currentSectorId ?? this.currentSectorId,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (currentSectorId.present) {
      map['current_sector_id'] = Variable<String>(currentSectorId.value);
    }
    if (lastInteraction.present) {
      map['last_interaction'] = Variable<DateTime>(lastInteraction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoryThreadsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('currentSectorId: $currentSectorId, ')
          ..write('lastInteraction: $lastInteraction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES story_threads (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    role,
    content,
    timestamp,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String threadId;
  final String role;
  final String content;
  final DateTime timestamp;
  final int syncStatus;
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      role: Value(role),
      content: Value(content),
      timestamp: Value(timestamp),
      syncStatus: Value(syncStatus),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? threadId,
    String? role,
    String? content,
    DateTime? timestamp,
    int? syncStatus,
  }) => ChatMessage(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, threadId, role, content, timestamp, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.role == this.role &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.syncStatus == this.syncStatus);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> timestamp;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String threadId,
    required String role,
    required String content,
    required DateTime timestamp,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       threadId = Value(threadId),
       role = Value(role),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? timestamp,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? threadId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? timestamp,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterInventoryTable extends CharacterInventory
    with TableInfo<$CharacterInventoryTable, CharacterInventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterInventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemGenreMeta = const VerificationMeta(
    'itemGenre',
  );
  @override
  late final GeneratedColumn<String> itemGenre = GeneratedColumn<String>(
    'item_genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseAttributeKeyMeta = const VerificationMeta(
    'baseAttributeKey',
  );
  @override
  late final GeneratedColumn<String> baseAttributeKey = GeneratedColumn<String>(
    'base_attribute_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseAttributeValueMeta =
      const VerificationMeta('baseAttributeValue');
  @override
  late final GeneratedColumn<int> baseAttributeValue = GeneratedColumn<int>(
    'base_attribute_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _structuralDescriptionMeta =
      const VerificationMeta('structuralDescription');
  @override
  late final GeneratedColumn<String> structuralDescription =
      GeneratedColumn<String>(
        'structural_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    itemName,
    itemGenre,
    baseAttributeKey,
    baseAttributeValue,
    structuralDescription,
    quantity,
    syncStatus,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterInventoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_genre')) {
      context.handle(
        _itemGenreMeta,
        itemGenre.isAcceptableOrUnknown(data['item_genre']!, _itemGenreMeta),
      );
    } else if (isInserting) {
      context.missing(_itemGenreMeta);
    }
    if (data.containsKey('base_attribute_key')) {
      context.handle(
        _baseAttributeKeyMeta,
        baseAttributeKey.isAcceptableOrUnknown(
          data['base_attribute_key']!,
          _baseAttributeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseAttributeKeyMeta);
    }
    if (data.containsKey('base_attribute_value')) {
      context.handle(
        _baseAttributeValueMeta,
        baseAttributeValue.isAcceptableOrUnknown(
          data['base_attribute_value']!,
          _baseAttributeValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseAttributeValueMeta);
    }
    if (data.containsKey('structural_description')) {
      context.handle(
        _structuralDescriptionMeta,
        structuralDescription.isAcceptableOrUnknown(
          data['structural_description']!,
          _structuralDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_structuralDescriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  CharacterInventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterInventoryData(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      itemGenre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_genre'],
      )!,
      baseAttributeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_attribute_key'],
      )!,
      baseAttributeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_attribute_value'],
      )!,
      structuralDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structural_description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $CharacterInventoryTable createAlias(String alias) {
    return $CharacterInventoryTable(attachedDatabase, alias);
  }
}

class CharacterInventoryData extends DataClass
    implements Insertable<CharacterInventoryData> {
  final String itemId;
  final String itemName;
  final String itemGenre;
  final String baseAttributeKey;
  final int baseAttributeValue;
  final String structuralDescription;
  final int quantity;
  final int syncStatus;
  final DateTime lastModified;
  const CharacterInventoryData({
    required this.itemId,
    required this.itemName,
    required this.itemGenre,
    required this.baseAttributeKey,
    required this.baseAttributeValue,
    required this.structuralDescription,
    required this.quantity,
    required this.syncStatus,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['item_name'] = Variable<String>(itemName);
    map['item_genre'] = Variable<String>(itemGenre);
    map['base_attribute_key'] = Variable<String>(baseAttributeKey);
    map['base_attribute_value'] = Variable<int>(baseAttributeValue);
    map['structural_description'] = Variable<String>(structuralDescription);
    map['quantity'] = Variable<int>(quantity);
    map['sync_status'] = Variable<int>(syncStatus);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  CharacterInventoryCompanion toCompanion(bool nullToAbsent) {
    return CharacterInventoryCompanion(
      itemId: Value(itemId),
      itemName: Value(itemName),
      itemGenre: Value(itemGenre),
      baseAttributeKey: Value(baseAttributeKey),
      baseAttributeValue: Value(baseAttributeValue),
      structuralDescription: Value(structuralDescription),
      quantity: Value(quantity),
      syncStatus: Value(syncStatus),
      lastModified: Value(lastModified),
    );
  }

  factory CharacterInventoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterInventoryData(
      itemId: serializer.fromJson<String>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemGenre: serializer.fromJson<String>(json['itemGenre']),
      baseAttributeKey: serializer.fromJson<String>(json['baseAttributeKey']),
      baseAttributeValue: serializer.fromJson<int>(json['baseAttributeValue']),
      structuralDescription: serializer.fromJson<String>(
        json['structuralDescription'],
      ),
      quantity: serializer.fromJson<int>(json['quantity']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'itemGenre': serializer.toJson<String>(itemGenre),
      'baseAttributeKey': serializer.toJson<String>(baseAttributeKey),
      'baseAttributeValue': serializer.toJson<int>(baseAttributeValue),
      'structuralDescription': serializer.toJson<String>(structuralDescription),
      'quantity': serializer.toJson<int>(quantity),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  CharacterInventoryData copyWith({
    String? itemId,
    String? itemName,
    String? itemGenre,
    String? baseAttributeKey,
    int? baseAttributeValue,
    String? structuralDescription,
    int? quantity,
    int? syncStatus,
    DateTime? lastModified,
  }) => CharacterInventoryData(
    itemId: itemId ?? this.itemId,
    itemName: itemName ?? this.itemName,
    itemGenre: itemGenre ?? this.itemGenre,
    baseAttributeKey: baseAttributeKey ?? this.baseAttributeKey,
    baseAttributeValue: baseAttributeValue ?? this.baseAttributeValue,
    structuralDescription: structuralDescription ?? this.structuralDescription,
    quantity: quantity ?? this.quantity,
    syncStatus: syncStatus ?? this.syncStatus,
    lastModified: lastModified ?? this.lastModified,
  );
  CharacterInventoryData copyWithCompanion(CharacterInventoryCompanion data) {
    return CharacterInventoryData(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemGenre: data.itemGenre.present ? data.itemGenre.value : this.itemGenre,
      baseAttributeKey: data.baseAttributeKey.present
          ? data.baseAttributeKey.value
          : this.baseAttributeKey,
      baseAttributeValue: data.baseAttributeValue.present
          ? data.baseAttributeValue.value
          : this.baseAttributeValue,
      structuralDescription: data.structuralDescription.present
          ? data.structuralDescription.value
          : this.structuralDescription,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterInventoryData(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemGenre: $itemGenre, ')
          ..write('baseAttributeKey: $baseAttributeKey, ')
          ..write('baseAttributeValue: $baseAttributeValue, ')
          ..write('structuralDescription: $structuralDescription, ')
          ..write('quantity: $quantity, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    itemName,
    itemGenre,
    baseAttributeKey,
    baseAttributeValue,
    structuralDescription,
    quantity,
    syncStatus,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterInventoryData &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.itemGenre == this.itemGenre &&
          other.baseAttributeKey == this.baseAttributeKey &&
          other.baseAttributeValue == this.baseAttributeValue &&
          other.structuralDescription == this.structuralDescription &&
          other.quantity == this.quantity &&
          other.syncStatus == this.syncStatus &&
          other.lastModified == this.lastModified);
}

class CharacterInventoryCompanion
    extends UpdateCompanion<CharacterInventoryData> {
  final Value<String> itemId;
  final Value<String> itemName;
  final Value<String> itemGenre;
  final Value<String> baseAttributeKey;
  final Value<int> baseAttributeValue;
  final Value<String> structuralDescription;
  final Value<int> quantity;
  final Value<int> syncStatus;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const CharacterInventoryCompanion({
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemGenre = const Value.absent(),
    this.baseAttributeKey = const Value.absent(),
    this.baseAttributeValue = const Value.absent(),
    this.structuralDescription = const Value.absent(),
    this.quantity = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterInventoryCompanion.insert({
    required String itemId,
    required String itemName,
    required String itemGenre,
    required String baseAttributeKey,
    required int baseAttributeValue,
    required String structuralDescription,
    this.quantity = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime lastModified,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       itemName = Value(itemName),
       itemGenre = Value(itemGenre),
       baseAttributeKey = Value(baseAttributeKey),
       baseAttributeValue = Value(baseAttributeValue),
       structuralDescription = Value(structuralDescription),
       lastModified = Value(lastModified);
  static Insertable<CharacterInventoryData> custom({
    Expression<String>? itemId,
    Expression<String>? itemName,
    Expression<String>? itemGenre,
    Expression<String>? baseAttributeKey,
    Expression<int>? baseAttributeValue,
    Expression<String>? structuralDescription,
    Expression<int>? quantity,
    Expression<int>? syncStatus,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (itemGenre != null) 'item_genre': itemGenre,
      if (baseAttributeKey != null) 'base_attribute_key': baseAttributeKey,
      if (baseAttributeValue != null)
        'base_attribute_value': baseAttributeValue,
      if (structuralDescription != null)
        'structural_description': structuralDescription,
      if (quantity != null) 'quantity': quantity,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterInventoryCompanion copyWith({
    Value<String>? itemId,
    Value<String>? itemName,
    Value<String>? itemGenre,
    Value<String>? baseAttributeKey,
    Value<int>? baseAttributeValue,
    Value<String>? structuralDescription,
    Value<int>? quantity,
    Value<int>? syncStatus,
    Value<DateTime>? lastModified,
    Value<int>? rowid,
  }) {
    return CharacterInventoryCompanion(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemGenre: itemGenre ?? this.itemGenre,
      baseAttributeKey: baseAttributeKey ?? this.baseAttributeKey,
      baseAttributeValue: baseAttributeValue ?? this.baseAttributeValue,
      structuralDescription:
          structuralDescription ?? this.structuralDescription,
      quantity: quantity ?? this.quantity,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemGenre.present) {
      map['item_genre'] = Variable<String>(itemGenre.value);
    }
    if (baseAttributeKey.present) {
      map['base_attribute_key'] = Variable<String>(baseAttributeKey.value);
    }
    if (baseAttributeValue.present) {
      map['base_attribute_value'] = Variable<int>(baseAttributeValue.value);
    }
    if (structuralDescription.present) {
      map['structural_description'] = Variable<String>(
        structuralDescription.value,
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterInventoryCompanion(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemGenre: $itemGenre, ')
          ..write('baseAttributeKey: $baseAttributeKey, ')
          ..write('baseAttributeValue: $baseAttributeValue, ')
          ..write('structuralDescription: $structuralDescription, ')
          ..write('quantity: $quantity, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSectorsTable extends LocalSectors
    with TableInfo<$LocalSectorsTable, LocalSector> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeGenreMeta = const VerificationMeta(
    'activeGenre',
  );
  @override
  late final GeneratedColumn<String> activeGenre = GeneratedColumn<String>(
    'active_genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _environmentalStabilityMeta =
      const VerificationMeta('environmentalStability');
  @override
  late final GeneratedColumn<double> environmentalStability =
      GeneratedColumn<double>(
        'environmental_stability',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rawMarkdownBodyMeta = const VerificationMeta(
    'rawMarkdownBody',
  );
  @override
  late final GeneratedColumn<String> rawMarkdownBody = GeneratedColumn<String>(
    'raw_markdown_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sectorId,
    parentId,
    title,
    activeGenre,
    environmentalStability,
    rawMarkdownBody,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSector> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('active_genre')) {
      context.handle(
        _activeGenreMeta,
        activeGenre.isAcceptableOrUnknown(
          data['active_genre']!,
          _activeGenreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeGenreMeta);
    }
    if (data.containsKey('environmental_stability')) {
      context.handle(
        _environmentalStabilityMeta,
        environmentalStability.isAcceptableOrUnknown(
          data['environmental_stability']!,
          _environmentalStabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentalStabilityMeta);
    }
    if (data.containsKey('raw_markdown_body')) {
      context.handle(
        _rawMarkdownBodyMeta,
        rawMarkdownBody.isAcceptableOrUnknown(
          data['raw_markdown_body']!,
          _rawMarkdownBodyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawMarkdownBodyMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sectorId};
  @override
  LocalSector map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSector(
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      activeGenre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_genre'],
      )!,
      environmentalStability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}environmental_stability'],
      )!,
      rawMarkdownBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_markdown_body'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $LocalSectorsTable createAlias(String alias) {
    return $LocalSectorsTable(attachedDatabase, alias);
  }
}

class LocalSector extends DataClass implements Insertable<LocalSector> {
  final String sectorId;
  final String? parentId;
  final String title;
  final String activeGenre;
  final double environmentalStability;
  final String rawMarkdownBody;
  final DateTime lastModified;
  const LocalSector({
    required this.sectorId,
    this.parentId,
    required this.title,
    required this.activeGenre,
    required this.environmentalStability,
    required this.rawMarkdownBody,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sector_id'] = Variable<String>(sectorId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['title'] = Variable<String>(title);
    map['active_genre'] = Variable<String>(activeGenre);
    map['environmental_stability'] = Variable<double>(environmentalStability);
    map['raw_markdown_body'] = Variable<String>(rawMarkdownBody);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  LocalSectorsCompanion toCompanion(bool nullToAbsent) {
    return LocalSectorsCompanion(
      sectorId: Value(sectorId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      activeGenre: Value(activeGenre),
      environmentalStability: Value(environmentalStability),
      rawMarkdownBody: Value(rawMarkdownBody),
      lastModified: Value(lastModified),
    );
  }

  factory LocalSector.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSector(
      sectorId: serializer.fromJson<String>(json['sectorId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      activeGenre: serializer.fromJson<String>(json['activeGenre']),
      environmentalStability: serializer.fromJson<double>(
        json['environmentalStability'],
      ),
      rawMarkdownBody: serializer.fromJson<String>(json['rawMarkdownBody']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sectorId': serializer.toJson<String>(sectorId),
      'parentId': serializer.toJson<String?>(parentId),
      'title': serializer.toJson<String>(title),
      'activeGenre': serializer.toJson<String>(activeGenre),
      'environmentalStability': serializer.toJson<double>(
        environmentalStability,
      ),
      'rawMarkdownBody': serializer.toJson<String>(rawMarkdownBody),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  LocalSector copyWith({
    String? sectorId,
    Value<String?> parentId = const Value.absent(),
    String? title,
    String? activeGenre,
    double? environmentalStability,
    String? rawMarkdownBody,
    DateTime? lastModified,
  }) => LocalSector(
    sectorId: sectorId ?? this.sectorId,
    parentId: parentId.present ? parentId.value : this.parentId,
    title: title ?? this.title,
    activeGenre: activeGenre ?? this.activeGenre,
    environmentalStability:
        environmentalStability ?? this.environmentalStability,
    rawMarkdownBody: rawMarkdownBody ?? this.rawMarkdownBody,
    lastModified: lastModified ?? this.lastModified,
  );
  LocalSector copyWithCompanion(LocalSectorsCompanion data) {
    return LocalSector(
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      activeGenre: data.activeGenre.present
          ? data.activeGenre.value
          : this.activeGenre,
      environmentalStability: data.environmentalStability.present
          ? data.environmentalStability.value
          : this.environmentalStability,
      rawMarkdownBody: data.rawMarkdownBody.present
          ? data.rawMarkdownBody.value
          : this.rawMarkdownBody,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSector(')
          ..write('sectorId: $sectorId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('activeGenre: $activeGenre, ')
          ..write('environmentalStability: $environmentalStability, ')
          ..write('rawMarkdownBody: $rawMarkdownBody, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sectorId,
    parentId,
    title,
    activeGenre,
    environmentalStability,
    rawMarkdownBody,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSector &&
          other.sectorId == this.sectorId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.activeGenre == this.activeGenre &&
          other.environmentalStability == this.environmentalStability &&
          other.rawMarkdownBody == this.rawMarkdownBody &&
          other.lastModified == this.lastModified);
}

class LocalSectorsCompanion extends UpdateCompanion<LocalSector> {
  final Value<String> sectorId;
  final Value<String?> parentId;
  final Value<String> title;
  final Value<String> activeGenre;
  final Value<double> environmentalStability;
  final Value<String> rawMarkdownBody;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const LocalSectorsCompanion({
    this.sectorId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.activeGenre = const Value.absent(),
    this.environmentalStability = const Value.absent(),
    this.rawMarkdownBody = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSectorsCompanion.insert({
    required String sectorId,
    this.parentId = const Value.absent(),
    required String title,
    required String activeGenre,
    required double environmentalStability,
    required String rawMarkdownBody,
    required DateTime lastModified,
    this.rowid = const Value.absent(),
  }) : sectorId = Value(sectorId),
       title = Value(title),
       activeGenre = Value(activeGenre),
       environmentalStability = Value(environmentalStability),
       rawMarkdownBody = Value(rawMarkdownBody),
       lastModified = Value(lastModified);
  static Insertable<LocalSector> custom({
    Expression<String>? sectorId,
    Expression<String>? parentId,
    Expression<String>? title,
    Expression<String>? activeGenre,
    Expression<double>? environmentalStability,
    Expression<String>? rawMarkdownBody,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sectorId != null) 'sector_id': sectorId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (activeGenre != null) 'active_genre': activeGenre,
      if (environmentalStability != null)
        'environmental_stability': environmentalStability,
      if (rawMarkdownBody != null) 'raw_markdown_body': rawMarkdownBody,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSectorsCompanion copyWith({
    Value<String>? sectorId,
    Value<String?>? parentId,
    Value<String>? title,
    Value<String>? activeGenre,
    Value<double>? environmentalStability,
    Value<String>? rawMarkdownBody,
    Value<DateTime>? lastModified,
    Value<int>? rowid,
  }) {
    return LocalSectorsCompanion(
      sectorId: sectorId ?? this.sectorId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      activeGenre: activeGenre ?? this.activeGenre,
      environmentalStability:
          environmentalStability ?? this.environmentalStability,
      rawMarkdownBody: rawMarkdownBody ?? this.rawMarkdownBody,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (activeGenre.present) {
      map['active_genre'] = Variable<String>(activeGenre.value);
    }
    if (environmentalStability.present) {
      map['environmental_stability'] = Variable<double>(
        environmentalStability.value,
      );
    }
    if (rawMarkdownBody.present) {
      map['raw_markdown_body'] = Variable<String>(rawMarkdownBody.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSectorsCompanion(')
          ..write('sectorId: $sectorId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('activeGenre: $activeGenre, ')
          ..write('environmentalStability: $environmentalStability, ')
          ..write('rawMarkdownBody: $rawMarkdownBody, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLedgerTable extends SyncLedger
    with TableInfo<$SyncLedgerTable, SyncLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    lastModified,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SyncLedgerTable createAlias(String alias) {
    return $SyncLedgerTable(attachedDatabase, alias);
  }
}

class SyncLedgerData extends DataClass implements Insertable<SyncLedgerData> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String? payload;
  final DateTime lastModified;
  final int syncStatus;
  const SyncLedgerData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    required this.lastModified,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  SyncLedgerCompanion toCompanion(bool nullToAbsent) {
    return SyncLedgerCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
    );
  }

  factory SyncLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLedgerData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String?>(payload),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  SyncLedgerData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    Value<String?> payload = const Value.absent(),
    DateTime? lastModified,
    int? syncStatus,
  }) => SyncLedgerData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload.present ? payload.value : this.payload,
    lastModified: lastModified ?? this.lastModified,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SyncLedgerData copyWithCompanion(SyncLedgerCompanion data) {
    return SyncLedgerData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLedgerData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    lastModified,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLedgerData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.lastModified == this.lastModified &&
          other.syncStatus == this.syncStatus);
}

class SyncLedgerCompanion extends UpdateCompanion<SyncLedgerData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String?> payload;
  final Value<DateTime> lastModified;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const SyncLedgerCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncLedgerCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    this.payload = const Value.absent(),
    required DateTime lastModified,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       lastModified = Value(lastModified);
  static Insertable<SyncLedgerData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? lastModified,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (lastModified != null) 'last_modified': lastModified,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String?>? payload,
    Value<DateTime>? lastModified,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return SyncLedgerCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      lastModified: lastModified ?? this.lastModified,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLedgerCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('lastModified: $lastModified, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $StoryThreadsTable storyThreads = $StoryThreadsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $CharacterInventoryTable characterInventory =
      $CharacterInventoryTable(this);
  late final $LocalSectorsTable localSectors = $LocalSectorsTable(this);
  late final $SyncLedgerTable syncLedger = $SyncLedgerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    storyThreads,
    chatMessages,
    characterInventory,
    localSectors,
    syncLedger,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String displayName,
      required String email,
      required String origin,
      required String activeSector,
      Value<String?> reputationRanks,
      required DateTime joinedDate,
      required double trustScore,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> email,
      Value<String> origin,
      Value<String> activeSector,
      Value<String?> reputationRanks,
      Value<DateTime> joinedDate,
      Value<double> trustScore,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StoryThreadsTable, List<StoryThread>>
  _storyThreadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.storyThreads,
    aliasName: 'users__id__story_threads__user_id',
  );

  $$StoryThreadsTableProcessedTableManager get storyThreadsRefs {
    final manager = $$StoryThreadsTableTableManager(
      $_db,
      $_db.storyThreads,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_storyThreadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeSector => $composableBuilder(
    column: $table.activeSector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reputationRanks => $composableBuilder(
    column: $table.reputationRanks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedDate => $composableBuilder(
    column: $table.joinedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> storyThreadsRefs(
    Expression<bool> Function($$StoryThreadsTableFilterComposer f) f,
  ) {
    final $$StoryThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storyThreads,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoryThreadsTableFilterComposer(
            $db: $db,
            $table: $db.storyThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeSector => $composableBuilder(
    column: $table.activeSector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reputationRanks => $composableBuilder(
    column: $table.reputationRanks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedDate => $composableBuilder(
    column: $table.joinedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get activeSector => $composableBuilder(
    column: $table.activeSector,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reputationRanks => $composableBuilder(
    column: $table.reputationRanks,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get joinedDate => $composableBuilder(
    column: $table.joinedDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get trustScore => $composableBuilder(
    column: $table.trustScore,
    builder: (column) => column,
  );

  Expression<T> storyThreadsRefs<T extends Object>(
    Expression<T> Function($$StoryThreadsTableAnnotationComposer a) f,
  ) {
    final $$StoryThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storyThreads,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoryThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.storyThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool storyThreadsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> activeSector = const Value.absent(),
                Value<String?> reputationRanks = const Value.absent(),
                Value<DateTime> joinedDate = const Value.absent(),
                Value<double> trustScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                displayName: displayName,
                email: email,
                origin: origin,
                activeSector: activeSector,
                reputationRanks: reputationRanks,
                joinedDate: joinedDate,
                trustScore: trustScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String email,
                required String origin,
                required String activeSector,
                Value<String?> reputationRanks = const Value.absent(),
                required DateTime joinedDate,
                required double trustScore,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                displayName: displayName,
                email: email,
                origin: origin,
                activeSector: activeSector,
                reputationRanks: reputationRanks,
                joinedDate: joinedDate,
                trustScore: trustScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({storyThreadsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (storyThreadsRefs) db.storyThreads],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (storyThreadsRefs)
                    await $_getPrefetchedData<User, $UsersTable, StoryThread>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._storyThreadsRefsTable(db),
                      managerFromTypedResult: (p0) => $$UsersTableReferences(
                        db,
                        table,
                        p0,
                      ).storyThreadsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool storyThreadsRefs})
    >;
typedef $$StoryThreadsTableCreateCompanionBuilder =
    StoryThreadsCompanion Function({
      required String id,
      required String userId,
      required String title,
      required String currentSectorId,
      required DateTime lastInteraction,
      Value<int> rowid,
    });
typedef $$StoryThreadsTableUpdateCompanionBuilder =
    StoryThreadsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String> currentSectorId,
      Value<DateTime> lastInteraction,
      Value<int> rowid,
    });

final class $$StoryThreadsTableReferences
    extends BaseReferences<_$AppDatabase, $StoryThreadsTable, StoryThread> {
  $$StoryThreadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('story_threads__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'story_threads__id__chat_messages__thread_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoryThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $StoryThreadsTable> {
  $$StoryThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentSectorId => $composableBuilder(
    column: $table.currentSectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoryThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoryThreadsTable> {
  $$StoryThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentSectorId => $composableBuilder(
    column: $table.currentSectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StoryThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoryThreadsTable> {
  $$StoryThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get currentSectorId => $composableBuilder(
    column: $table.currentSectorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastInteraction => $composableBuilder(
    column: $table.lastInteraction,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoryThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoryThreadsTable,
          StoryThread,
          $$StoryThreadsTableFilterComposer,
          $$StoryThreadsTableOrderingComposer,
          $$StoryThreadsTableAnnotationComposer,
          $$StoryThreadsTableCreateCompanionBuilder,
          $$StoryThreadsTableUpdateCompanionBuilder,
          (StoryThread, $$StoryThreadsTableReferences),
          StoryThread,
          PrefetchHooks Function({bool userId, bool chatMessagesRefs})
        > {
  $$StoryThreadsTableTableManager(_$AppDatabase db, $StoryThreadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoryThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoryThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoryThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> currentSectorId = const Value.absent(),
                Value<DateTime> lastInteraction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoryThreadsCompanion(
                id: id,
                userId: userId,
                title: title,
                currentSectorId: currentSectorId,
                lastInteraction: lastInteraction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                required String currentSectorId,
                required DateTime lastInteraction,
                Value<int> rowid = const Value.absent(),
              }) => StoryThreadsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                currentSectorId: currentSectorId,
                lastInteraction: lastInteraction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoryThreadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, chatMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatMessagesRefs) db.chatMessages],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$StoryThreadsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$StoryThreadsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessagesRefs)
                    await $_getPrefetchedData<
                      StoryThread,
                      $StoryThreadsTable,
                      ChatMessage
                    >(
                      currentTable: table,
                      referencedTable: $$StoryThreadsTableReferences
                          ._chatMessagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StoryThreadsTableReferences(
                            db,
                            table,
                            p0,
                          ).chatMessagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.threadId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StoryThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoryThreadsTable,
      StoryThread,
      $$StoryThreadsTableFilterComposer,
      $$StoryThreadsTableOrderingComposer,
      $$StoryThreadsTableAnnotationComposer,
      $$StoryThreadsTableCreateCompanionBuilder,
      $$StoryThreadsTableUpdateCompanionBuilder,
      (StoryThread, $$StoryThreadsTableReferences),
      StoryThread,
      PrefetchHooks Function({bool userId, bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String threadId,
      required String role,
      required String content,
      required DateTime timestamp,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> threadId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> timestamp,
      Value<int> syncStatus,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StoryThreadsTable _threadIdTable(_$AppDatabase db) => db.storyThreads
      .createAlias('chat_messages__thread_id__story_threads__id');

  $$StoryThreadsTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<String>('thread_id')!;

    final manager = $$StoryThreadsTableTableManager(
      $_db,
      $_db.storyThreads,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$StoryThreadsTableFilterComposer get threadId {
    final $$StoryThreadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.storyThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoryThreadsTableFilterComposer(
            $db: $db,
            $table: $db.storyThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoryThreadsTableOrderingComposer get threadId {
    final $$StoryThreadsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.storyThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoryThreadsTableOrderingComposer(
            $db: $db,
            $table: $db.storyThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$StoryThreadsTableAnnotationComposer get threadId {
    final $$StoryThreadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.storyThreads,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoryThreadsTableAnnotationComposer(
            $db: $db,
            $table: $db.storyThreads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool threadId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                threadId: threadId,
                role: role,
                content: content,
                timestamp: timestamp,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String threadId,
                required String role,
                required String content,
                required DateTime timestamp,
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                threadId: threadId,
                role: role,
                content: content,
                timestamp: timestamp,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._threadIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._threadIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool threadId})
    >;
typedef $$CharacterInventoryTableCreateCompanionBuilder =
    CharacterInventoryCompanion Function({
      required String itemId,
      required String itemName,
      required String itemGenre,
      required String baseAttributeKey,
      required int baseAttributeValue,
      required String structuralDescription,
      Value<int> quantity,
      Value<int> syncStatus,
      required DateTime lastModified,
      Value<int> rowid,
    });
typedef $$CharacterInventoryTableUpdateCompanionBuilder =
    CharacterInventoryCompanion Function({
      Value<String> itemId,
      Value<String> itemName,
      Value<String> itemGenre,
      Value<String> baseAttributeKey,
      Value<int> baseAttributeValue,
      Value<String> structuralDescription,
      Value<int> quantity,
      Value<int> syncStatus,
      Value<DateTime> lastModified,
      Value<int> rowid,
    });

class $$CharacterInventoryTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterInventoryTable> {
  $$CharacterInventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemGenre => $composableBuilder(
    column: $table.itemGenre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseAttributeKey => $composableBuilder(
    column: $table.baseAttributeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseAttributeValue => $composableBuilder(
    column: $table.baseAttributeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structuralDescription => $composableBuilder(
    column: $table.structuralDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterInventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterInventoryTable> {
  $$CharacterInventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemGenre => $composableBuilder(
    column: $table.itemGenre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseAttributeKey => $composableBuilder(
    column: $table.baseAttributeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseAttributeValue => $composableBuilder(
    column: $table.baseAttributeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuralDescription => $composableBuilder(
    column: $table.structuralDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterInventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterInventoryTable> {
  $$CharacterInventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemGenre =>
      $composableBuilder(column: $table.itemGenre, builder: (column) => column);

  GeneratedColumn<String> get baseAttributeKey => $composableBuilder(
    column: $table.baseAttributeKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseAttributeValue => $composableBuilder(
    column: $table.baseAttributeValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structuralDescription => $composableBuilder(
    column: $table.structuralDescription,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$CharacterInventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterInventoryTable,
          CharacterInventoryData,
          $$CharacterInventoryTableFilterComposer,
          $$CharacterInventoryTableOrderingComposer,
          $$CharacterInventoryTableAnnotationComposer,
          $$CharacterInventoryTableCreateCompanionBuilder,
          $$CharacterInventoryTableUpdateCompanionBuilder,
          (
            CharacterInventoryData,
            BaseReferences<
              _$AppDatabase,
              $CharacterInventoryTable,
              CharacterInventoryData
            >,
          ),
          CharacterInventoryData,
          PrefetchHooks Function()
        > {
  $$CharacterInventoryTableTableManager(
    _$AppDatabase db,
    $CharacterInventoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterInventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterInventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterInventoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<String> itemGenre = const Value.absent(),
                Value<String> baseAttributeKey = const Value.absent(),
                Value<int> baseAttributeValue = const Value.absent(),
                Value<String> structuralDescription = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterInventoryCompanion(
                itemId: itemId,
                itemName: itemName,
                itemGenre: itemGenre,
                baseAttributeKey: baseAttributeKey,
                baseAttributeValue: baseAttributeValue,
                structuralDescription: structuralDescription,
                quantity: quantity,
                syncStatus: syncStatus,
                lastModified: lastModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String itemName,
                required String itemGenre,
                required String baseAttributeKey,
                required int baseAttributeValue,
                required String structuralDescription,
                Value<int> quantity = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                required DateTime lastModified,
                Value<int> rowid = const Value.absent(),
              }) => CharacterInventoryCompanion.insert(
                itemId: itemId,
                itemName: itemName,
                itemGenre: itemGenre,
                baseAttributeKey: baseAttributeKey,
                baseAttributeValue: baseAttributeValue,
                structuralDescription: structuralDescription,
                quantity: quantity,
                syncStatus: syncStatus,
                lastModified: lastModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterInventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterInventoryTable,
      CharacterInventoryData,
      $$CharacterInventoryTableFilterComposer,
      $$CharacterInventoryTableOrderingComposer,
      $$CharacterInventoryTableAnnotationComposer,
      $$CharacterInventoryTableCreateCompanionBuilder,
      $$CharacterInventoryTableUpdateCompanionBuilder,
      (
        CharacterInventoryData,
        BaseReferences<
          _$AppDatabase,
          $CharacterInventoryTable,
          CharacterInventoryData
        >,
      ),
      CharacterInventoryData,
      PrefetchHooks Function()
    >;
typedef $$LocalSectorsTableCreateCompanionBuilder =
    LocalSectorsCompanion Function({
      required String sectorId,
      Value<String?> parentId,
      required String title,
      required String activeGenre,
      required double environmentalStability,
      required String rawMarkdownBody,
      required DateTime lastModified,
      Value<int> rowid,
    });
typedef $$LocalSectorsTableUpdateCompanionBuilder =
    LocalSectorsCompanion Function({
      Value<String> sectorId,
      Value<String?> parentId,
      Value<String> title,
      Value<String> activeGenre,
      Value<double> environmentalStability,
      Value<String> rawMarkdownBody,
      Value<DateTime> lastModified,
      Value<int> rowid,
    });

class $$LocalSectorsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSectorsTable> {
  $$LocalSectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeGenre => $composableBuilder(
    column: $table.activeGenre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get environmentalStability => $composableBuilder(
    column: $table.environmentalStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMarkdownBody => $composableBuilder(
    column: $table.rawMarkdownBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSectorsTable> {
  $$LocalSectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeGenre => $composableBuilder(
    column: $table.activeGenre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get environmentalStability => $composableBuilder(
    column: $table.environmentalStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMarkdownBody => $composableBuilder(
    column: $table.rawMarkdownBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSectorsTable> {
  $$LocalSectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sectorId =>
      $composableBuilder(column: $table.sectorId, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get activeGenre => $composableBuilder(
    column: $table.activeGenre,
    builder: (column) => column,
  );

  GeneratedColumn<double> get environmentalStability => $composableBuilder(
    column: $table.environmentalStability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMarkdownBody => $composableBuilder(
    column: $table.rawMarkdownBody,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$LocalSectorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSectorsTable,
          LocalSector,
          $$LocalSectorsTableFilterComposer,
          $$LocalSectorsTableOrderingComposer,
          $$LocalSectorsTableAnnotationComposer,
          $$LocalSectorsTableCreateCompanionBuilder,
          $$LocalSectorsTableUpdateCompanionBuilder,
          (
            LocalSector,
            BaseReferences<_$AppDatabase, $LocalSectorsTable, LocalSector>,
          ),
          LocalSector,
          PrefetchHooks Function()
        > {
  $$LocalSectorsTableTableManager(_$AppDatabase db, $LocalSectorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSectorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sectorId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> activeGenre = const Value.absent(),
                Value<double> environmentalStability = const Value.absent(),
                Value<String> rawMarkdownBody = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSectorsCompanion(
                sectorId: sectorId,
                parentId: parentId,
                title: title,
                activeGenre: activeGenre,
                environmentalStability: environmentalStability,
                rawMarkdownBody: rawMarkdownBody,
                lastModified: lastModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sectorId,
                Value<String?> parentId = const Value.absent(),
                required String title,
                required String activeGenre,
                required double environmentalStability,
                required String rawMarkdownBody,
                required DateTime lastModified,
                Value<int> rowid = const Value.absent(),
              }) => LocalSectorsCompanion.insert(
                sectorId: sectorId,
                parentId: parentId,
                title: title,
                activeGenre: activeGenre,
                environmentalStability: environmentalStability,
                rawMarkdownBody: rawMarkdownBody,
                lastModified: lastModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSectorsTable,
      LocalSector,
      $$LocalSectorsTableFilterComposer,
      $$LocalSectorsTableOrderingComposer,
      $$LocalSectorsTableAnnotationComposer,
      $$LocalSectorsTableCreateCompanionBuilder,
      $$LocalSectorsTableUpdateCompanionBuilder,
      (
        LocalSector,
        BaseReferences<_$AppDatabase, $LocalSectorsTable, LocalSector>,
      ),
      LocalSector,
      PrefetchHooks Function()
    >;
typedef $$SyncLedgerTableCreateCompanionBuilder =
    SyncLedgerCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String operation,
      Value<String?> payload,
      required DateTime lastModified,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$SyncLedgerTableUpdateCompanionBuilder =
    SyncLedgerCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String?> payload,
      Value<DateTime> lastModified,
      Value<int> syncStatus,
      Value<int> rowid,
    });

class $$SyncLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLedgerTable> {
  $$SyncLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLedgerTable> {
  $$SyncLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLedgerTable> {
  $$SyncLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$SyncLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLedgerTable,
          SyncLedgerData,
          $$SyncLedgerTableFilterComposer,
          $$SyncLedgerTableOrderingComposer,
          $$SyncLedgerTableAnnotationComposer,
          $$SyncLedgerTableCreateCompanionBuilder,
          $$SyncLedgerTableUpdateCompanionBuilder,
          (
            SyncLedgerData,
            BaseReferences<_$AppDatabase, $SyncLedgerTable, SyncLedgerData>,
          ),
          SyncLedgerData,
          PrefetchHooks Function()
        > {
  $$SyncLedgerTableTableManager(_$AppDatabase db, $SyncLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLedgerCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                lastModified: lastModified,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                Value<String?> payload = const Value.absent(),
                required DateTime lastModified,
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLedgerCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                lastModified: lastModified,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLedgerTable,
      SyncLedgerData,
      $$SyncLedgerTableFilterComposer,
      $$SyncLedgerTableOrderingComposer,
      $$SyncLedgerTableAnnotationComposer,
      $$SyncLedgerTableCreateCompanionBuilder,
      $$SyncLedgerTableUpdateCompanionBuilder,
      (
        SyncLedgerData,
        BaseReferences<_$AppDatabase, $SyncLedgerTable, SyncLedgerData>,
      ),
      SyncLedgerData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$StoryThreadsTableTableManager get storyThreads =>
      $$StoryThreadsTableTableManager(_db, _db.storyThreads);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$CharacterInventoryTableTableManager get characterInventory =>
      $$CharacterInventoryTableTableManager(_db, _db.characterInventory);
  $$LocalSectorsTableTableManager get localSectors =>
      $$LocalSectorsTableTableManager(_db, _db.localSectors);
  $$SyncLedgerTableTableManager get syncLedger =>
      $$SyncLedgerTableTableManager(_db, _db.syncLedger);
}
