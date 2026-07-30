import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

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
  TextColumn get giverId => text().references(Users, #id, relationName: 'givenEndorsements')();
  TextColumn get receiverId => text().references(Users, #id, relationName: 'receivedEndorsements')();
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
  TextColumn get initiatorId => text().references(Users, #id, relationName: 'initiatedTrades')();
  TextColumn get receiverId => text().references(Users, #id, relationName: 'receivedTrades')();
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA journal_mode = WAL;');
      },
    );
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
