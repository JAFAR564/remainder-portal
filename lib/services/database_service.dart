import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database_service.g.dart';

/// Database table mapping character inventories.
class CharacterInventory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get characterName => text()();
  TextColumn get itemName => text()();
  IntColumn get count => integer()();
  TextColumn get rarity => text()();
}

/// Database table storing dynamic transaction and gameplay logs.
class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get characterName => text()();
  TextColumn get logMessage => text()();
  TextColumn get sector => text()();
}

/// Offline-first cache table mapping roster members.
class RosterProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get characterName => text()();
  TextColumn get playerName => text()();
  TextColumn get faction => text()();
  TextColumn get faceclaimName => text()();
  TextColumn get faceclaimImgUrl => text()();
  TextColumn get status => text()();
  TextColumn get joinedDate => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline-first cache table mapping membership applications.
class Applications extends Table {
  TextColumn get id => text()();
  TextColumn get submittedAt => text()();
  TextColumn get applicantEmail => text()();
  TextColumn get characterName => text()();
  TextColumn get faction => text()();
  TextColumn get answersJson => text()(); // Flat JSON list of answers
  TextColumn get status => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CharacterInventory, SessionLogs, RosterProfiles, Applications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Dynamic Inventory Calculations & Mutations ---

  Future<List<CharacterInventoryData>> getInventoryFor(String characterName) {
    return (select(characterInventory)..where((tbl) => tbl.characterName.equals(characterName))).get();
  }

  Future<int> addItemToInventory(String characterName, String itemName, int count, String rarity) {
    return into(characterInventory).insert(
      CharacterInventoryCompanion.insert(
        characterName: characterName,
        itemName: itemName,
        count: count,
        rarity: rarity,
      ),
    );
  }

  // --- Session Logs management ---

  Future<List<SessionLog>> getSessionLogs(String characterName) {
    return (select(sessionLogs)
          ..where((tbl) => tbl.characterName.equals(characterName))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> addSessionLog(String characterName, String message, String sectorName) {
    return into(sessionLogs).insert(
      SessionLogsCompanion.insert(
        timestamp: DateTime.now(),
        characterName: characterName,
        logMessage: message,
        sector: sectorName,
      ),
    );
  }

  // --- Offline Roster caching ---

  Future<List<RosterProfile>> getCachedRoster() {
    return select(rosterProfiles).get();
  }

  Future<void> cacheRoster(List<RosterProfile> profilesList) async {
    await batch((batch) {
      batch.insertAll(
        rosterProfiles, 
        profilesList, 
        mode: InsertMode.insertOrReplace
      );
    });
  }

  // --- Offline Application caching ---

  Future<List<ApplicationData>> getCachedApplications() {
    return select(applications).get();
  }

  Future<void> cacheApplications(List<ApplicationData> appsList) async {
    await batch((batch) {
      batch.insertAll(
        applications, 
        appsList, 
        mode: InsertMode.insertOrReplace
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'remainder_portal.sqlite'));
    return NativeDatabase(file);
  });
}

/// Provider exposing the AppDatabase instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
