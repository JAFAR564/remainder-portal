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

@DriftDatabase(tables: [
  Users,
  StoryThreads,
  ChatMessages,
  CharacterInventory,
  LocalSectors,
  SyncLedger,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'remainder_portal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
