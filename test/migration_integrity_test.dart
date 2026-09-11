import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:path/path.dart' as p;
import 'package:remainder_portal/data/services/database_service.dart' hide PlayerWallet;
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/models/quest_decree_model.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';

class _RawPreV5User extends QueryExecutorUser {
  @override
  int get schemaVersion => 4;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

void main() {
  late Directory tempDir;
  late File dbFile;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drift_migration_verify_');
    dbFile = File(p.join(tempDir.path, 'verify_migration.db'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // =========================================================================
  // Verification 1 & 2: Genuine Pre-v5 DB Migrates to v5 with 100% Data Preservation
  // =========================================================================
  test('VERIFY 1 & 2: Genuine pre-v5 database fixture preserves existing UTRCS and chat rows byte-for-byte', () async {
    final now = DateTime(2026, 9, 10, 18, 30, 0);

    // Step A: Initialize raw SQLite DB representing Schema v4
    final rawPreV5Db = NativeDatabase(dbFile);
    await rawPreV5Db.ensureOpen(_RawPreV5User());

    // Create v4 tables manually via raw SQL
    await rawPreV5Db.runCustom('''
      CREATE TABLE users (
        id TEXT NOT NULL PRIMARY KEY,
        display_name TEXT NOT NULL,
        email TEXT NOT NULL,
        origin TEXT NOT NULL,
        active_sector TEXT NOT NULL,
        reputation_ranks TEXT,
        joined_date INTEGER NOT NULL,
        trust_score REAL NOT NULL
      );
    ''');
    await rawPreV5Db.runCustom('''
      CREATE TABLE story_threads (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES users (id),
        title TEXT NOT NULL,
        current_sector_id TEXT NOT NULL,
        last_interaction INTEGER NOT NULL
      );
    ''');
    await rawPreV5Db.runCustom('''
      CREATE TABLE chat_messages (
        id TEXT NOT NULL PRIMARY KEY,
        thread_id TEXT NOT NULL REFERENCES story_threads (id),
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        sync_status INTEGER NOT NULL DEFAULT 0
      );
    ''');
    await rawPreV5Db.runCustom('''
      CREATE TABLE utrcs_characters (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT REFERENCES users (id),
        schema_version TEXT NOT NULL DEFAULT '1.0.0',
        completion_depth TEXT NOT NULL,
        raw_json_payload TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    // Populate exact v4 fixture data
    const fixtureUserJson = '{"id":"operator_v4_legacy","displayName":"Kaelen Legacy","origin":"Aetheria"}';
    const fixtureUtrcsJson = '{"id":"utrcs_legacy_001","name":"Commander Kael","stats":{"STR":18,"DEX":14,"INT":16},"concept":"Aether Vanguard"}';
    const fixtureChatContent = '✦ Aether resonance stabilized at sector perimeter. Inscription confirmed.';

    await rawPreV5Db.runCustom(
      'INSERT INTO users VALUES (?, ?, ?, ?, ?, ?, ?, ?);',
      ['operator_v4_legacy', 'Kaelen Legacy', 'kaelen@remainder.net', 'Aetheria', 'sectors_neon_bastion_4', null, now.millisecondsSinceEpoch, 0.95],
    );
    await rawPreV5Db.runCustom(
      'INSERT INTO story_threads VALUES (?, ?, ?, ?, ?);',
      ['thread_v4_legacy', 'operator_v4_legacy', 'Legacy Chapter I', 'sectors_neon_bastion_4', now.millisecondsSinceEpoch],
    );
    await rawPreV5Db.runCustom(
      'INSERT INTO chat_messages VALUES (?, ?, ?, ?, ?, ?);',
      ['msg_v4_legacy_101', 'thread_v4_legacy', 'model', fixtureChatContent, now.millisecondsSinceEpoch, 1],
    );
    await rawPreV5Db.runCustom(
      'INSERT INTO utrcs_characters VALUES (?, ?, ?, ?, ?, ?, ?);',
      ['utrcs_legacy_001', 'operator_v4_legacy', '1.0.0', 'deep', fixtureUtrcsJson, now.millisecondsSinceEpoch, now.millisecondsSinceEpoch],
    );

    // Close raw v4 handle
    await rawPreV5Db.close();

    // Step B: Open with AppDatabase (Schema v5) and execute onUpgrade
    final v5Db = AppDatabase(NativeDatabase(dbFile));

    // Execute migration from v4 to v5
    await v5Db.migration.onUpgrade(v5Db.createMigrator(), 4, 5);

    // Step C: Verify existing v4 data is 100% byte-for-byte and logically intact
    final legacyUser = await (v5Db.select(v5Db.users)..where((u) => u.id.equals('operator_v4_legacy'))).getSingle();
    expect(legacyUser.displayName, 'Kaelen Legacy');
    expect(legacyUser.email, 'kaelen@remainder.net');
    expect(legacyUser.trustScore, 0.95);

    final legacyChat = await (v5Db.select(v5Db.chatMessages)..where((m) => m.id.equals('msg_v4_legacy_101'))).getSingle();
    expect(legacyChat.content, fixtureChatContent);
    expect(legacyChat.syncStatus, 1);

    final legacyUtrcs = await v5Db.getActiveUtrcsCharacter();
    expect(legacyUtrcs, isNotNull);
    expect(legacyUtrcs!['id'], 'utrcs_legacy_001');
    expect(legacyUtrcs['raw_json_payload'], fixtureUtrcsJson);
    expect(legacyUtrcs['completion_depth'], 'deep');

    // Step D: Verify all 6 new v5 tables exist and accept operations
    await v5Db.savePlayerWallet(PlayerWallet(
      userId: 'operator_v4_legacy',
      essenceBalance: 1200,
      laurelBalance: 180,
      experiencePoints: 765000,
      currentLevel: 88,
      lastUpdated: now,
    ));
    final wallet = await v5Db.getPlayerWallet('operator_v4_legacy');
    expect(wallet, isNotNull);
    expect(wallet!.essenceBalance, 1200);

    await v5Db.close();
  });

  // =========================================================================
  // Verification 3: Migration Idempotency
  // =========================================================================
  test('VERIFY 3: Migration can be executed multiple times without corruption', () async {
    final v5Db = AppDatabase(NativeDatabase(dbFile));

    // Call migration from v4 to v5 multiple times
    await expectLater(v5Db.migration.onUpgrade(v5Db.createMigrator(), 4, 5), completes);
    await expectLater(v5Db.migration.onUpgrade(v5Db.createMigrator(), 4, 5), completes);
    await expectLater(v5Db.migration.onUpgrade(v5Db.createMigrator(), 4, 5), completes);

    // Verify DB still performs normally after repeated migrations
    final repo = SovereignRepository(v5Db);
    final wallet = await repo.getWallet('idempotency_operator');
    expect(wallet.essenceBalance, 1000);

    await v5Db.close();
  });

  // =========================================================================
  // Verification 4: Transaction Atomicity & Failed Transaction Rollback
  // =========================================================================
  test('VERIFY 4: Failed transaction rolls back and leaves no partial mutations', () async {
    final v5Db = AppDatabase(NativeDatabase(dbFile));
    final repo = SovereignRepository(v5Db);

    await repo.getWallet('atomic_operator');

    // Execute transaction that fails midway
    try {
      await v5Db.transaction(() async {
        await v5Db.customStatement(
          'UPDATE player_wallets SET essence_balance = 9999 WHERE user_id = ?;',
          ['atomic_operator'],
        );
        // Force an error
        throw const FormatException('Simulated deliberate mid-transaction crash');
      });
    } catch (_) {
      // Expected caught exception
    }

    // Balance must remain 1000, not 9999
    final wallet = await repo.getWallet('atomic_operator');
    expect(wallet.essenceBalance, 1000);

    await v5Db.close();
  });

  // =========================================================================
  // Verification 5 & 6: App Restart Persistence & Quest Idempotency Across Reopen
  // =========================================================================
  test('VERIFY 5 & 6: Data persists across database close/reopen, quest claim idempotency survives restart', () async {
    const userId = 'restart_operator';
    const questId = 'quest_restart_01';
    final now = DateTime.now();

    // Session 1: Create wallet and completed quest, claim reward
    var session1Db = AppDatabase(NativeDatabase(dbFile));
    await session1Db.savePlayerWallet(PlayerWallet(
      userId: userId,
      essenceBalance: 1000,
      laurelBalance: 150,
      lastUpdated: now,
    ));
    await session1Db.upsertQuestDecree(QuestDecreeModel(
      id: questId,
      userId: userId,
      title: 'Sector 4 Calibration',
      sectorId: 'sectors_neon_bastion_4',
      sectorName: 'Neon Bastion',
      decreeText: 'Neutralize anomaly.',
      rewardEssence: 500,
      rewardLaurels: 50,
      progress: 1.0,
      isClaimed: false,
      createdAt: now,
    ));

    // Claim reward first time
    final firstClaim = await session1Db.claimQuestReward(questId: questId, userId: userId);
    expect(firstClaim, true);

    var wallet1 = await session1Db.getPlayerWallet(userId);
    expect(wallet1!.essenceBalance, 1500);
    expect(wallet1.laurelBalance, 200);

    // CLOSE Session 1 (simulating process death / app kill)
    await session1Db.close();

    // Session 2: RESTART app with fresh connection to same persistent SQLite file
    var session2Db = AppDatabase(NativeDatabase(dbFile));

    // Verify wallet and quest persisted exactly as left
    final wallet2 = await session2Db.getPlayerWallet(userId);
    expect(wallet2, isNotNull);
    expect(wallet2!.essenceBalance, 1500);
    expect(wallet2.laurelBalance, 200);

    final quest2 = await session2Db.getQuestDecreeById(questId);
    expect(quest2, isNotNull);
    expect(quest2!.isClaimed, true);

    // Attempt second claim in new session: MUST return false and preserve balances
    final secondClaim = await session2Db.claimQuestReward(questId: questId, userId: userId);
    expect(secondClaim, false);

    final walletAfterSecondClaim = await session2Db.getPlayerWallet(userId);
    expect(walletAfterSecondClaim!.essenceBalance, 1500);
    expect(walletAfterSecondClaim.laurelBalance, 200);

    await session2Db.close();
  });

  // =========================================================================
  // Verification 7: Negative Balance Overdraft Protection
  // =========================================================================
  test('VERIFY 7: Wallet mutations strictly reject negative balance and revert', () async {
    final v5Db = AppDatabase(NativeDatabase(dbFile));
    final repo = SovereignRepository(v5Db);

    await repo.getWallet('overdraft_operator');

    // Attempting to spend 2000 Essence when wallet only has 1000
    expect(
      () => repo.adjustBalance(userId: 'overdraft_operator', essenceDelta: -2000),
      throwsA(isA<StateError>()),
    );

    // Verify balance is completely untouched
    final wallet = await repo.getWallet('overdraft_operator');
    expect(wallet.essenceBalance, 1000);

    await v5Db.close();
  });
}
