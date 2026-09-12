import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../models/player_wallet.dart';
import '../models/equipment_item_model.dart';
import '../models/quest_decree_model.dart';
import '../models/oracle_record.dart';
import '../models/social_bulletin_model.dart';

part 'database_service.g.dart';

// Represents user profiles synced with cloud
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text()();
  TextColumn get origin => text()();
  TextColumn get activeSector => text()();
  TextColumn get reputationRanks => text().nullable()(); // JSON string
  DateTimeColumn get joinedDate => dateTime()();
  RealColumn get trustScore => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// Manages ongoing storytelling sessions
class StoryThreads extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get currentSectorId => text()();
  DateTimeColumn get lastInteraction => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Caches individual chat interactions with GM
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get threadId => text().references(StoryThreads, #id)();
  TextColumn get role => text()(); // 'user', 'model', 'system'
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))(); // 0: Pending, 1: Synced

  @override
  Set<Column> get primaryKey => {id};
}

// Caches client items offline
class CharacterInventory extends Table {
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  TextColumn get itemGenre => text()();
  TextColumn get baseAttributeKey => text()();
  IntColumn get baseAttributeValue => integer()();
  TextColumn get structuralDescription => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))(); // 0: Pending, 1: Synced
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {itemId};
}

// Caches spatial maps offline
class LocalSectors extends Table {
  TextColumn get sectorId => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get activeGenre => text()();
  RealColumn get environmentalStability => real()();
  TextColumn get rawMarkdownBody => text()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {sectorId};
}

// Trace offline operations to sync back to Firestore
class SyncLedger extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'inventory_item', 'message', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'insert', 'update', 'delete'
  TextColumn get payload => text().nullable()(); // JSON string
  DateTimeColumn get lastModified => dateTime()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))(); // 0: Pending, 1: Synced

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 2: Expedition Groups Table
class Expeditions extends Table {
  TextColumn get id => text()();
  TextColumn get leaderId => text().references(Users, #id)();
  TextColumn get sectorId => text()();
  TextColumn get title => text()();
  IntColumn get status => integer()(); // 0: Recruiting, 1: Active, 2: Completed
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 2: Expedition Roster & Roles Table
class ExpeditionMembers extends Table {
  TextColumn get expeditionId => text().references(Expeditions, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get assignedRole => text()(); // 'Leader', 'Vanguard', 'Hacker', etc.
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {expeditionId, userId};
}

// Phase 2: Inter-Player Endorsements Table
class Endorsements extends Table {
  TextColumn get id => text()();
  TextColumn get giverId => text().references(Users, #id)();
  TextColumn get receiverId => text().references(Users, #id)();
  TextColumn get vector => text()(); // 'Vanguard', 'Arbiter', 'Merchant', 'Hacker'
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 2: Sovereign Guilds Table
class Guilds extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tag => text()();
  TextColumn get masterUserId => text().references(Users, #id)();
  IntColumn get treasuryBalance => integer().withDefault(const Constant(0))();
  TextColumn get announcement => text().nullable()();
  DateTimeColumn get foundedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 2: Guild Members Table
class GuildMembers extends Table {
  TextColumn get guildId => text().references(Guilds, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get rank => text()(); // 'Master', 'Marshal', 'Scribe', 'Initiate'
  DateTimeColumn get joinedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {guildId, userId};
}

// Phase 2: Sector Governance Table
class GovernanceRules extends Table {
  TextColumn get sectorId => text().references(LocalSectors, #sectorId)();
  TextColumn get governingGuildId => text().nullable().references(Guilds, #id)();
  RealColumn get taxRate => real().withDefault(const Constant(0.05))();
  TextColumn get sectorLawBody => text()(); // Custom rule parameters for AI GM
  DateTimeColumn get lastElectionDate => dateTime()();

  @override
  Set<Column> get primaryKey => {sectorId};
}

// Phase 2: Chrono-Loom Lore Proposals Table
class LoreProposals extends Table {
  TextColumn get id => text()();
  TextColumn get sectorId => text().references(LocalSectors, #sectorId)();
  TextColumn get authorUserId => text().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get proposedContent => text()();
  IntColumn get status => integer()(); // 0: Draft, 1: Voting, 2: Canonized, 3: Rejected
  IntColumn get yesVotes => integer().withDefault(const Constant(0))();
  IntColumn get noVotes => integer().withDefault(const Constant(0))();
  DateTimeColumn get votingEndsAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 2: Immutable Lore History Table
class LoreHistory extends Table {
  TextColumn get id => text()();
  TextColumn get sectorId => text().references(LocalSectors, #sectorId)();
  TextColumn get proposalId => text().references(LoreProposals, #id)();
  IntColumn get version => integer()();
  TextColumn get markdownContent => text()();
  DateTimeColumn get canonizedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 3: Offline Queue Table
class OfflineQueue extends Table {
  TextColumn get id => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get messageType => text()(); // 'chat_action', 'trade_commit', 'lore_proposal', 'endorsement'
  TextColumn get payload => text()(); // JSON string
  TextColumn get dependencyId => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0: Pending, 1: InFlight, 2: Synced, 3: Failed
  TextColumn get conflictMetadata => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 3: Player Trades Table
class PlayerTrades extends Table {
  TextColumn get id => text()();
  TextColumn get initiatorId => text().references(Users, #id)();
  TextColumn get receiverId => text().references(Users, #id)();
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0: Pending, 1: EscrowLocked, 2: Completed, 3: Cancelled
  TextColumn get offeredItemIds => text()(); // JSON string array
  IntColumn get offeredEnergy => integer().withDefault(const Constant(0))();
  TextColumn get requestedItemIds => text()(); // JSON string array
  IntColumn get requestedEnergy => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 3: Trade Escrow Table
class TradeEscrow extends Table {
  TextColumn get id => text()();
  TextColumn get tradeId => text().references(PlayerTrades, #id)();
  TextColumn get lockedByUserId => text().references(Users, #id)();
  TextColumn get lockedPayload => text()(); // JSON string
  TextColumn get lockStatus => text()(); // 'LOCKED', 'RELEASED', 'REFUNDED'
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 3: Creator Content Table (OKF Authoring)
class CreatorContent extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text().references(Users, #id)();
  TextColumn get contentType => text()(); // 'sector', 'settlement', 'npc', 'quest', 'lore_entry'
  TextColumn get title => text()();
  TextColumn get okfMarkdownBody => text()();
  IntColumn get lifecycleStage => integer().withDefault(const Constant(0))(); // 0: Draft .. 7: Published
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 4: Dedicated UTRCS Characters Persistence Table
class UtrcsCharacters extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().references(Users, #id)();
  TextColumn get schemaVersion => text().withDefault(const Constant('1.0.0'))();
  TextColumn get completionDepth => text()(); // 'quick', 'standard', 'deep'
  TextColumn get rawJsonPayload => text()();   // Full serialized UtrcsCharacterModel JSON
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 5: Player Wallet & Currencies Table
@DataClassName('PlayerWalletData')
class PlayerWallets extends Table {
  TextColumn get userId => text()();
  IntColumn get essenceBalance => integer().withDefault(const Constant(1000))();
  IntColumn get laurelBalance => integer().withDefault(const Constant(150))();
  IntColumn get experiencePoints => integer().withDefault(const Constant(765000))();
  IntColumn get currentLevel => integer().withDefault(const Constant(88))();
  IntColumn get unallocatedAttributePoints => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

// Phase 5: Imperial Relic Vault & Equipment Table
@DataClassName('EquipmentItemData')
class EquipmentItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get slot => text()(); // 'WEAPON', 'ARMOR', 'RELIC', 'CHARM'
  TextColumn get name => text()();
  TextColumn get rarity => text()(); // 'common', 'rare', 'celestial', 'sovereign'
  TextColumn get statBonus => text()();
  TextColumn get description => text()();
  TextColumn get iconName => text().withDefault(const Constant('shield'))();
  IntColumn get upgradeLevel => integer().withDefault(const Constant(0))();
  BoolColumn get isEquipped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get acquiredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 5: World Arbiter Quest Decrees Table
@DataClassName('QuestDecreeData')
class QuestDecrees extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get sectorId => text()();
  TextColumn get sectorName => text()();
  TextColumn get decreeText => text()();
  IntColumn get rewardEssence => integer().withDefault(const Constant(750))();
  IntColumn get rewardLaurels => integer().withDefault(const Constant(50))();
  RealColumn get progress => real().withDefault(const Constant(0.65))();
  BoolColumn get isUrgent => boolean().withDefault(const Constant(true))();
  BoolColumn get isClaimed => boolean().withDefault(const Constant(false))();
  TextColumn get difficulty => text().withDefault(const Constant('S-RANK'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 5: Oracle Divination History Table
@DataClassName('OracleHistoryData')
class OracleHistories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get d20Roll => integer()();
  TextColumn get outcomeTier => text()();
  TextColumn get blessingText => text()();
  TextColumn get buffGranted => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 5: Sanctuary Social Posts Table
@DataClassName('SocialPostData')
class SocialPosts extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text()();
  TextColumn get authorName => text()();
  TextColumn get authorTitle => text()();
  TextColumn get avatarPath => text().withDefault(const Constant('assets/icon/app_icon.png'))();
  TextColumn get content => text()();
  BoolColumn get isIc => boolean().withDefault(const Constant(true))();
  IntColumn get laurelsCount => integer().withDefault(const Constant(0))();
  IntColumn get commentsCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 5: Sanctuary Social Comments Table
@DataClassName('SocialCommentData')
class SocialComments extends Table {
  TextColumn get id => text()();
  TextColumn get postId => text().references(SocialPosts, #id)();
  TextColumn get authorName => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Users,
  StoryThreads,
  ChatMessages,
  CharacterInventory,
  LocalSectors,
  SyncLedger,
  Expeditions,
  ExpeditionMembers,
  Endorsements,
  Guilds,
  GuildMembers,
  GovernanceRules,
  LoreProposals,
  LoreHistory,
  OfflineQueue,
  PlayerTrades,
  TradeEscrow,
  CreatorContent,
  UtrcsCharacters,
  PlayerWallets,
  EquipmentItems,
  QuestDecrees,
  OracleHistories,
  SocialPosts,
  SocialComments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(expeditions);
          await m.createTable(expeditionMembers);
          await m.createTable(endorsements);
          await m.createTable(guilds);
          await m.createTable(guildMembers);
          await m.createTable(governanceRules);
          await m.createTable(loreProposals);
          await m.createTable(loreHistory);
        }
        if (from < 3) {
          await m.createTable(offlineQueue);
          await m.createTable(playerTrades);
          await m.createTable(tradeEscrow);
          await m.createTable(creatorContent);
        }
        if (from < 4) {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS utrcs_characters (
              id TEXT NOT NULL PRIMARY KEY,
              user_id TEXT REFERENCES users (id),
              schema_version TEXT NOT NULL DEFAULT '1.0.0',
              completion_depth TEXT NOT NULL,
              raw_json_payload TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            );
          ''');
        }
        if (from < 5) {
          await _createV5Tables();
        }
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA journal_mode = WAL;');
        // Ensure utrcs_characters table exists on cold boots & in-memory testing
        await customStatement('''
          CREATE TABLE IF NOT EXISTS utrcs_characters (
            id TEXT NOT NULL PRIMARY KEY,
            user_id TEXT REFERENCES users (id),
            schema_version TEXT NOT NULL DEFAULT '1.0.0',
            completion_depth TEXT NOT NULL,
            raw_json_payload TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          );
        ''');
        // Ensure Phase 5 tables exist on cold boots & in-memory testing
        await _createV5Tables();
      },
    );
  }

  Future<void> _createV5Tables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS player_wallets (
        user_id TEXT NOT NULL PRIMARY KEY,
        essence_balance INTEGER NOT NULL DEFAULT 1000,
        laurel_balance INTEGER NOT NULL DEFAULT 150,
        experience_points INTEGER NOT NULL DEFAULT 765000,
        current_level INTEGER NOT NULL DEFAULT 88,
        unallocated_attribute_points INTEGER NOT NULL DEFAULT 0,
        last_updated INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS equipment_items (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        slot TEXT NOT NULL,
        name TEXT NOT NULL,
        rarity TEXT NOT NULL,
        stat_bonus TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL DEFAULT 'shield',
        upgrade_level INTEGER NOT NULL DEFAULT 0,
        is_equipped INTEGER NOT NULL DEFAULT 0,
        acquired_at INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quest_decrees (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        sector_id TEXT NOT NULL,
        sector_name TEXT NOT NULL,
        decree_text TEXT NOT NULL,
        reward_essence INTEGER NOT NULL DEFAULT 750,
        reward_laurels INTEGER NOT NULL DEFAULT 50,
        progress REAL NOT NULL DEFAULT 0.65,
        is_urgent INTEGER NOT NULL DEFAULT 1,
        is_claimed INTEGER NOT NULL DEFAULT 0,
        difficulty TEXT NOT NULL DEFAULT 'S-RANK',
        created_at INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS oracle_histories (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        d20_roll INTEGER NOT NULL,
        outcome_tier TEXT NOT NULL,
        blessing_text TEXT NOT NULL,
        buff_granted TEXT,
        timestamp INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS social_posts (
        id TEXT NOT NULL PRIMARY KEY,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_title TEXT NOT NULL,
        avatar_path TEXT NOT NULL DEFAULT 'assets/icon/app_icon.png',
        content TEXT NOT NULL,
        is_ic INTEGER NOT NULL DEFAULT 1,
        laurels_count INTEGER NOT NULL DEFAULT 0,
        comments_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS social_comments (
        id TEXT NOT NULL PRIMARY KEY,
        post_id TEXT NOT NULL REFERENCES social_posts (id) ON DELETE CASCADE,
        author_name TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_equipment_user_slot ON equipment_items(user_id, slot);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_quests_user ON quest_decrees(user_id);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_oracle_user_time ON oracle_histories(user_id, timestamp DESC);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_social_posts_time ON social_posts(created_at DESC);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_social_comments_post ON social_comments(post_id, created_at ASC);');
  }

  // ==========================================
  // Phase 4: UTRCS Character Helpers
  // ==========================================
  Future<void> saveUtrcsCharacter({
    required String id,
    String? userId,
    required String schemaVersion,
    required String completionDepth,
    required String rawJsonPayload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    await customStatement('''
      INSERT INTO utrcs_characters (id, user_id, schema_version, completion_depth, raw_json_payload, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        completion_depth = excluded.completion_depth,
        raw_json_payload = excluded.raw_json_payload,
        updated_at = excluded.updated_at;
    ''', [
      id,
      userId,
      schemaVersion,
      completionDepth,
      rawJsonPayload,
      createdAt.millisecondsSinceEpoch,
      updatedAt.millisecondsSinceEpoch,
    ]);
  }

  Future<Map<String, dynamic>?> getActiveUtrcsCharacter() async {
    final rows = await customSelect('''
      SELECT id, user_id, schema_version, completion_depth, raw_json_payload, created_at, updated_at
      FROM utrcs_characters
      ORDER BY updated_at DESC
      LIMIT 1;
    ''').get();
    if (rows.isEmpty) return null;
    return rows.first.data;
  }

  // ==========================================
  // Phase 5: Player Wallet & Currency Engine
  // ==========================================
  Future<PlayerWallet?> getPlayerWallet(String userId) async {
    final rows = await customSelect(
      'SELECT user_id, essence_balance, laurel_balance, experience_points, current_level, unallocated_attribute_points, last_updated '
      'FROM player_wallets WHERE user_id = ? LIMIT 1;',
      variables: [Variable.withString(userId)],
    ).get();
    if (rows.isEmpty) return null;
    final row = rows.first.data;
    return PlayerWallet(
      userId: row['user_id'] as String,
      essenceBalance: (row['essence_balance'] as num).toInt(),
      laurelBalance: (row['laurel_balance'] as num).toInt(),
      experiencePoints: (row['experience_points'] as num).toInt(),
      currentLevel: (row['current_level'] as num).toInt(),
      unallocatedAttributePoints: (row['unallocated_attribute_points'] as num).toInt(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(row['last_updated'] as int),
    );
  }

  Future<void> savePlayerWallet(PlayerWallet wallet) async {
    await customStatement('''
      INSERT INTO player_wallets (user_id, essence_balance, laurel_balance, experience_points, current_level, unallocated_attribute_points, last_updated)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(user_id) DO UPDATE SET
        essence_balance = excluded.essence_balance,
        laurel_balance = excluded.laurel_balance,
        experience_points = excluded.experience_points,
        current_level = excluded.current_level,
        unallocated_attribute_points = excluded.unallocated_attribute_points,
        last_updated = excluded.last_updated;
    ''', [
      wallet.userId,
      wallet.essenceBalance,
      wallet.laurelBalance,
      wallet.experiencePoints,
      wallet.currentLevel,
      wallet.unallocatedAttributePoints,
      wallet.lastUpdated.millisecondsSinceEpoch,
    ]);
  }

  Future<PlayerWallet> adjustWalletBalance({
    required String userId,
    int essenceDelta = 0,
    int laurelDelta = 0,
    int xpDelta = 0,
    int pointsDelta = 0,
  }) async {
    return await transaction(() async {
      var current = await getPlayerWallet(userId);
      if (current == null) {
        current = PlayerWallet(
          userId: userId,
          essenceBalance: 1000,
          laurelBalance: 150,
          experiencePoints: 765000,
          currentLevel: 88,
          unallocatedAttributePoints: 0,
          lastUpdated: DateTime.now(),
        );
        await savePlayerWallet(current);
      }

      final newEssence = current.essenceBalance + essenceDelta;
      final newLaurel = current.laurelBalance + laurelDelta;
      if (newEssence < 0) {
        throw StateError('Insufficient Essence balance: required ${-essenceDelta}, available ${current.essenceBalance}');
      }
      if (newLaurel < 0) {
        throw StateError('Insufficient Laurel balance: required ${-laurelDelta}, available ${current.laurelBalance}');
      }

      final newXp = (current.experiencePoints + xpDelta).clamp(0, 9999999);
      final newPoints = (current.unallocatedAttributePoints + pointsDelta).clamp(0, 999);

      var level = current.currentLevel;
      while (newXp >= level * level * 100) {
        level++;
      }

      final updated = current.copyWith(
        essenceBalance: newEssence,
        laurelBalance: newLaurel,
        experiencePoints: newXp,
        currentLevel: level,
        unallocatedAttributePoints: newPoints,
        lastUpdated: DateTime.now(),
      );

      await savePlayerWallet(updated);
      return updated;
    });
  }

  // ==========================================
  // Phase 5: Imperial Relic Vault & Equipment
  // ==========================================
  Future<List<EquipmentItemModel>> getEquipmentForUser(String userId) async {
    final rows = await customSelect(
      'SELECT id, user_id, slot, name, rarity, stat_bonus, description, icon_name, upgrade_level, is_equipped, acquired_at '
      'FROM equipment_items WHERE user_id = ? ORDER BY acquired_at ASC;',
      variables: [Variable.withString(userId)],
    ).get();

    return rows.map((r) {
      final d = r.data;
      return EquipmentItemModel(
        id: d['id'] as String,
        userId: d['user_id'] as String,
        slot: d['slot'] as String,
        name: d['name'] as String,
        rarity: EquipmentRarity.values.firstWhere(
          (e) => e.name.toLowerCase() == (d['rarity'] as String).toLowerCase(),
          orElse: () => EquipmentRarity.common,
        ),
        statBonus: d['stat_bonus'] as String,
        description: d['description'] as String,
        iconName: d['icon_name'] as String? ?? 'shield',
        upgradeLevel: (d['upgrade_level'] as num).toInt(),
        isEquipped: d['is_equipped'] == 1,
        acquiredAt: DateTime.fromMillisecondsSinceEpoch(d['acquired_at'] as int),
      );
    }).toList();
  }

  Future<EquipmentItemModel?> getEquipmentById(String id) async {
    final rows = await customSelect(
      'SELECT id, user_id, slot, name, rarity, stat_bonus, description, icon_name, upgrade_level, is_equipped, acquired_at '
      'FROM equipment_items WHERE id = ? LIMIT 1;',
      variables: [Variable.withString(id)],
    ).get();
    if (rows.isEmpty) return null;
    final d = rows.first.data;
    return EquipmentItemModel(
      id: d['id'] as String,
      userId: d['user_id'] as String,
      slot: d['slot'] as String,
      name: d['name'] as String,
      rarity: EquipmentRarity.values.firstWhere(
        (e) => e.name.toLowerCase() == (d['rarity'] as String).toLowerCase(),
        orElse: () => EquipmentRarity.common,
      ),
      statBonus: d['stat_bonus'] as String,
      description: d['description'] as String,
      iconName: d['icon_name'] as String? ?? 'shield',
      upgradeLevel: (d['upgrade_level'] as num).toInt(),
      isEquipped: d['is_equipped'] == 1,
      acquiredAt: DateTime.fromMillisecondsSinceEpoch(d['acquired_at'] as int),
    );
  }

  Future<void> upsertEquipment(EquipmentItemModel item) async {
    await customStatement('''
      INSERT INTO equipment_items (id, user_id, slot, name, rarity, stat_bonus, description, icon_name, upgrade_level, is_equipped, acquired_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        user_id = excluded.user_id,
        slot = excluded.slot,
        name = excluded.name,
        rarity = excluded.rarity,
        stat_bonus = excluded.stat_bonus,
        description = excluded.description,
        icon_name = excluded.icon_name,
        upgrade_level = excluded.upgrade_level,
        is_equipped = excluded.is_equipped,
        acquired_at = excluded.acquired_at;
    ''', [
      item.id,
      item.userId,
      item.slot,
      item.name,
      item.rarity.name,
      item.statBonus,
      item.description,
      item.iconName,
      item.upgradeLevel,
      item.isEquipped ? 1 : 0,
      item.acquiredAt.millisecondsSinceEpoch,
    ]);
  }

  Future<void> equipItem({
    required String userId,
    required String itemId,
    required String slot,
  }) async {
    await transaction(() async {
      await customStatement(
        'UPDATE equipment_items SET is_equipped = 0 WHERE user_id = ? AND slot = ? AND is_equipped = 1;',
        [userId, slot],
      );
      await customStatement(
        'UPDATE equipment_items SET is_equipped = 1, slot = ? WHERE id = ? AND user_id = ?;',
        [slot, itemId, userId],
      );
    });
  }

  Future<void> unequipItem({
    required String userId,
    required String itemId,
  }) async {
    await customStatement(
      'UPDATE equipment_items SET is_equipped = 0 WHERE id = ? AND user_id = ?;',
      [itemId, userId],
    );
  }

  Future<EquipmentItemModel> upgradeEquipment({
    required String itemId,
    required String userId,
    required int costEssence,
  }) async {
    return await transaction(() async {
      await adjustWalletBalance(userId: userId, essenceDelta: -costEssence);

      await customStatement(
        'UPDATE equipment_items SET upgrade_level = upgrade_level + 1 WHERE id = ? AND user_id = ?;',
        [itemId, userId],
      );

      final updated = await getEquipmentById(itemId);
      if (updated == null) throw StateError('Item $itemId not found after upgrade');
      return updated;
    });
  }

  // ==========================================
  // Phase 5: World Arbiter Quest Decrees
  // ==========================================
  Future<List<QuestDecreeModel>> getQuestDecreesForUser(String userId) async {
    final rows = await customSelect(
      'SELECT id, user_id, title, sector_id, sector_name, decree_text, reward_essence, reward_laurels, progress, is_urgent, is_claimed, difficulty, created_at '
      'FROM quest_decrees WHERE user_id = ? ORDER BY created_at DESC;',
      variables: [Variable.withString(userId)],
    ).get();

    return rows.map((r) {
      final d = r.data;
      return QuestDecreeModel(
        id: d['id'] as String,
        userId: d['user_id'] as String,
        title: d['title'] as String,
        sectorId: d['sector_id'] as String,
        sectorName: d['sector_name'] as String,
        decreeText: d['decree_text'] as String,
        rewardEssence: (d['reward_essence'] as num).toInt(),
        rewardLaurels: (d['reward_laurels'] as num).toInt(),
        progress: (d['progress'] as num).toDouble(),
        isUrgent: d['is_urgent'] == 1 || d['is_urgent'] == true,
        isClaimed: d['is_claimed'] == 1 || d['is_claimed'] == true,
        difficulty: d['difficulty'] as String? ?? 'S-RANK',
        createdAt: DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
      );
    }).toList();
  }

  Future<QuestDecreeModel?> getQuestDecreeById(String id) async {
    final rows = await customSelect(
      'SELECT id, user_id, title, sector_id, sector_name, decree_text, reward_essence, reward_laurels, progress, is_urgent, is_claimed, difficulty, created_at '
      'FROM quest_decrees WHERE id = ? LIMIT 1;',
      variables: [Variable.withString(id)],
    ).get();
    if (rows.isEmpty) return null;
    final d = rows.first.data;
    return QuestDecreeModel(
      id: d['id'] as String,
      userId: d['user_id'] as String,
      title: d['title'] as String,
      sectorId: d['sector_id'] as String,
      sectorName: d['sector_name'] as String,
      decreeText: d['decree_text'] as String,
      rewardEssence: (d['reward_essence'] as num).toInt(),
      rewardLaurels: (d['reward_laurels'] as num).toInt(),
      progress: (d['progress'] as num).toDouble(),
      isUrgent: d['is_urgent'] == 1 || d['is_urgent'] == true,
      isClaimed: d['is_claimed'] == 1 || d['is_claimed'] == true,
      difficulty: d['difficulty'] as String? ?? 'S-RANK',
      createdAt: DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
    );
  }

  Future<void> upsertQuestDecree(QuestDecreeModel quest) async {
    await customStatement('''
      INSERT INTO quest_decrees (id, user_id, title, sector_id, sector_name, decree_text, reward_essence, reward_laurels, progress, is_urgent, is_claimed, difficulty, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        user_id = excluded.user_id,
        title = excluded.title,
        sector_id = excluded.sector_id,
        sector_name = excluded.sector_name,
        decree_text = excluded.decree_text,
        reward_essence = excluded.reward_essence,
        reward_laurels = excluded.reward_laurels,
        progress = excluded.progress,
        is_urgent = excluded.is_urgent,
        is_claimed = excluded.is_claimed,
        difficulty = excluded.difficulty,
        created_at = excluded.created_at;
    ''', [
      quest.id,
      quest.userId,
      quest.title,
      quest.sectorId,
      quest.sectorName,
      quest.decreeText,
      quest.rewardEssence,
      quest.rewardLaurels,
      quest.progress,
      quest.isUrgent ? 1 : 0,
      quest.isClaimed ? 1 : 0,
      quest.difficulty,
      quest.createdAt.millisecondsSinceEpoch,
    ]);
  }

  Future<void> updateQuestProgress({required String questId, required double progress}) async {
    await customStatement(
      'UPDATE quest_decrees SET progress = ? WHERE id = ?;',
      [progress.clamp(0.0, 1.0), questId],
    );
  }

  Future<QuestClaimResult> claimQuestReward({
    required String questId,
    required String userId,
    DateTime? nowOverride,
  }) async {
    return await transaction(() async {
      final rows = await customSelect(
        'SELECT id, user_id, reward_essence, reward_laurels, progress, is_claimed '
        'FROM quest_decrees WHERE id = ? AND user_id = ? LIMIT 1;',
        variables: [Variable.withString(questId), Variable.withString(userId)],
      ).get();

      if (rows.isEmpty) {
        throw StateError('Quest decree $questId not found for user $userId');
      }

      final row = rows.first.data;
      final isClaimed = row['is_claimed'] == 1 || row['is_claimed'] == true;
      final progress = (row['progress'] as num).toDouble();
      final rewardEssence = (row['reward_essence'] as num).toInt();
      final rewardLaurels = (row['reward_laurels'] as num).toInt();

      if (progress < 1.0) {
        throw StateError('Quest decree is not yet completed (progress: $progress)');
      }

      if (isClaimed) {
        return QuestClaimResult(
          success: false,
          questId: questId,
          baseEssence: rewardEssence,
          creditedEssence: 0,
          creditedLaurels: 0,
          multiplierBasisPoints: 1000,
        );
      }

      // Query latest Oracle divination to resolve active celestial resonance buffs
      final oracleRows = await customSelect(
        'SELECT id, user_id, d20_roll, outcome_tier, blessing_text, buff_granted, timestamp '
        'FROM oracle_histories WHERE user_id = ? ORDER BY timestamp DESC LIMIT 1;',
        variables: [Variable.withString(userId)],
      ).get();

      int multiplierBasisPoints = 1000;
      String? activeBuffTitle;

      if (oracleRows.isNotEmpty) {
        final oData = oracleRows.first.data;
        final oRecord = OracleRecord(
          id: oData['id'] as String,
          userId: oData['user_id'] as String,
          d20Roll: (oData['d20_roll'] as num).toInt(),
          outcomeTier: oData['outcome_tier'] as String,
          blessingText: oData['blessing_text'] as String,
          buffGranted: oData['buff_granted'] as String?,
          timestamp: DateTime.fromMillisecondsSinceEpoch(oData['timestamp'] as int),
        );

        final buff = oRecord.activeBuff;
        final currentTime = nowOverride ?? DateTime.now();
        if (buff != null && !currentTime.isAfter(buff.expiresAt)) {
          multiplierBasisPoints = buff.questEssenceBasisPoints;
          activeBuffTitle = buff.title;
        }
      }

      // Pure integer basis points arithmetic (1000 = 1.0x baseline, 1150 = 1.15x)
      // Bit-identical across ARM64 and x86_64, eliminates floating-point drift.
      final effectiveEssence = (rewardEssence * multiplierBasisPoints) ~/ 1000;

      await customStatement(
        'UPDATE quest_decrees SET is_claimed = 1 WHERE id = ?;',
        [questId],
      );

      await adjustWalletBalance(
        userId: userId,
        essenceDelta: effectiveEssence,
        laurelDelta: rewardLaurels,
      );

      return QuestClaimResult(
        success: true,
        questId: questId,
        baseEssence: rewardEssence,
        creditedEssence: effectiveEssence,
        creditedLaurels: rewardLaurels,
        multiplierBasisPoints: multiplierBasisPoints,
        activeBuffTitle: activeBuffTitle,
      );
    });
  }

  // ==========================================
  // Phase 5: Oracle Divination Chronicle
  // ==========================================
  Future<void> recordOracleDivination(OracleRecord record) async {
    await customStatement('''
      INSERT INTO oracle_histories (id, user_id, d20_roll, outcome_tier, blessing_text, buff_granted, timestamp)
      VALUES (?, ?, ?, ?, ?, ?, ?);
    ''', [
      record.id,
      record.userId,
      record.d20Roll,
      record.outcomeTier,
      record.blessingText,
      record.buffGranted,
      record.timestamp.millisecondsSinceEpoch,
    ]);
  }

  /// Atomically executes a divination communion: verifies sufficient Essence, debits Essence from
  /// player_wallets, and writes the OracleRecord to oracle_histories.
  Future<OracleRecord> performDivinationRoll({
    required String userId,
    required int costEssence,
    required int d20Roll,
    DateTime? timestamp,
    String? blessingTextOverride,
  }) async {
    return await transaction(() async {
      if (costEssence > 0) {
        final wallet = await getPlayerWallet(userId);
        if (wallet == null) {
          throw StateError('Player wallet not found for user: $userId');
        }
        if (wallet.essenceBalance < costEssence) {
          throw StateError(
            'Insufficient Essence balance for divination communion (${wallet.essenceBalance} < $costEssence)',
          );
        }
        await savePlayerWallet(wallet.copyWith(
          essenceBalance: wallet.essenceBalance - costEssence,
          lastUpdated: DateTime.now(),
        ));
      }

      final record = OracleRecord.createCalibratedRecord(
        userId: userId,
        d20Roll: d20Roll,
        timestamp: timestamp,
        blessingTextOverride: blessingTextOverride,
      );

      await recordOracleDivination(record);
      return record;
    });
  }

  Future<List<OracleRecord>> getOracleHistoryForUser(String userId, {int limit = 10}) async {
    final rows = await customSelect(
      'SELECT id, user_id, d20_roll, outcome_tier, blessing_text, buff_granted, timestamp '
      'FROM oracle_histories WHERE user_id = ? ORDER BY timestamp DESC LIMIT ?;',
      variables: [Variable.withString(userId), Variable.withInt(limit)],
    ).get();

    return rows.map((r) {
      final d = r.data;
      return OracleRecord(
        id: d['id'] as String,
        userId: d['user_id'] as String,
        d20Roll: (d['d20_roll'] as num).toInt(),
        outcomeTier: d['outcome_tier'] as String,
        blessingText: d['blessing_text'] as String,
        buffGranted: d['buff_granted'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(d['timestamp'] as int),
      );
    }).toList();
  }

  // ==========================================
  // Phase 5: Sanctuary Social Bulletin
  // ==========================================
  Future<List<SocialPostEntry>> getSocialPosts({int limit = 20}) async {
    final rows = await customSelect(
      'SELECT id, author_id, author_name, author_title, avatar_path, content, is_ic, laurels_count, comments_count, created_at '
      'FROM social_posts ORDER BY created_at DESC LIMIT ?;',
      variables: [Variable.withInt(limit)],
    ).get();

    return rows.map((r) {
      final d = r.data;
      return SocialPostEntry(
        id: d['id'] as String,
        authorId: d['author_id'] as String,
        authorName: d['author_name'] as String,
        authorTitle: d['author_title'] as String,
        avatarPath: d['avatar_path'] as String? ?? 'assets/icon/app_icon.png',
        content: d['content'] as String,
        isIC: d['is_ic'] == 1,
        laurelsCount: (d['laurels_count'] as num).toInt(),
        commentsCount: (d['comments_count'] as num).toInt(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
      );
    }).toList();
  }

  Future<void> createSocialPost(SocialPostEntry post) async {
    await customStatement('''
      INSERT INTO social_posts (id, author_id, author_name, author_title, avatar_path, content, is_ic, laurels_count, comments_count, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    ''', [
      post.id,
      post.authorId,
      post.authorName,
      post.authorTitle,
      post.avatarPath,
      post.content,
      post.isIC ? 1 : 0,
      post.laurelsCount,
      post.commentsCount,
      post.createdAt.millisecondsSinceEpoch,
    ]);
  }

  Future<void> addLaurelToPost({required String postId, required String userId}) async {
    await customStatement(
      'UPDATE social_posts SET laurels_count = laurels_count + 1 WHERE id = ?;',
      [postId],
    );
  }

  Future<List<SocialCommentEntry>> getCommentsForPost(String postId) async {
    final rows = await customSelect(
      'SELECT id, post_id, author_name, content, created_at '
      'FROM social_comments WHERE post_id = ? ORDER BY created_at ASC;',
      variables: [Variable.withString(postId)],
    ).get();

    return rows.map((r) {
      final d = r.data;
      return SocialCommentEntry(
        id: d['id'] as String,
        postId: d['post_id'] as String,
        authorName: d['author_name'] as String,
        content: d['content'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(d['created_at'] as int),
      );
    }).toList();
  }

  Future<void> addCommentToPost(SocialCommentEntry comment) async {
    await transaction(() async {
      await customStatement('''
        INSERT INTO social_comments (id, post_id, author_name, content, created_at)
        VALUES (?, ?, ?, ?, ?);
      ''', [
        comment.id,
        comment.postId,
        comment.authorName,
        comment.content,
        comment.createdAt.millisecondsSinceEpoch,
      ]);
      await customStatement(
        'UPDATE social_posts SET comments_count = comments_count + 1 WHERE id = ?;',
        [comment.postId],
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'remainder_portal.db'));
    return NativeDatabase(file, setup: (rawDb) {
      rawDb.execute('PRAGMA journal_mode=WAL;');
    });
  });
}
