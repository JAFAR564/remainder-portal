import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:path/path.dart' as p;

import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/models/oracle_record.dart';
import 'package:remainder_portal/data/models/quest_decree_model.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/data/services/database_service.dart' hide PlayerWallet;

void main() {
  late Directory tempDir;
  late File dbFile;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drift_buff_consumption_test_');
    dbFile = File(p.join(tempDir.path, 'buff_consumption_test.db'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Thread C-1A — Oracle Buff Downstream Consumption in Quest Rewards', () {
    const testUser = 'operator_c1a_arbiter';

    QuestDecreeModel createQuest({
      required String id,
      required int rewardEssence,
      required int rewardLaurels,
      double progress = 1.0,
      bool isClaimed = false,
    }) {
      return QuestDecreeModel(
        id: id,
        userId: testUser,
        title: 'Calibrate Leyline Anchor $id',
        sectorId: 'sectors_citadel_core',
        sectorName: 'Citadel Core',
        decreeText: 'Cleanse residual corruption and stabilize flow.',
        rewardEssence: rewardEssence,
        rewardLaurels: rewardLaurels,
        progress: progress,
        isUrgent: true,
        isClaimed: isClaimed,
        difficulty: rewardEssence >= 750 ? 'S-RANK' : 'A-RANK',
        createdAt: DateTime.now(),
      );
    }

    Future<void> seedInitialWallet(AppDatabase db, {int essence = 1000, int laurels = 150}) async {
      await db.savePlayerWallet(PlayerWallet(
        userId: testUser,
        essenceBalance: essence,
        laurelBalance: laurels,
        experiencePoints: 500000,
        currentLevel: 70,
        lastUpdated: DateTime.now(),
      ));
    }

    // =========================================================================
    // 1. S-Rank + Critical Consensus (1150 bps / +15%)
    // =========================================================================
    test('1. S-Rank Decree + Critical Consensus: credits 862 Essence (+112 boost) and unmultiplied Laurels', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_s_critical', rewardEssence: 750, rewardLaurels: 50));

      // Record D20=20 Critical Consensus divination
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 20,
        timestamp: now,
      ));

      final result = await repo.claimReward(
        questId: 'quest_s_critical',
        userId: testUser,
        nowOverride: now.add(const Duration(minutes: 5)),
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1150);
      expect(result.hadBuffBoost, true);
      expect(result.bonusEssence, 112);
      expect(result.creditedEssence, 862); // 750 * 1150 ~/ 1000 = 862
      expect(result.creditedLaurels, 50);

      // Verify wallet updated: 1000 + 862 = 1862 Essence, 150 + 50 = 200 Laurels
      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1862);
      expect(wallet.laurelBalance, 200);

      await db.close();
    });

    // =========================================================================
    // 2. A-Rank + Harmonic Aether (1100 bps / +10%)
    // =========================================================================
    test('2. A-Rank Decree + Harmonic Aether: credits 550 Essence (+50 boost) and unmultiplied Laurels', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_a_harmonic', rewardEssence: 500, rewardLaurels: 35));

      // Record D20=16 Harmonic Aether divination
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 16,
        timestamp: now,
      ));

      final result = await repo.claimReward(
        questId: 'quest_a_harmonic',
        userId: testUser,
        nowOverride: now.add(const Duration(minutes: 3)),
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1100);
      expect(result.hadBuffBoost, true);
      expect(result.bonusEssence, 50);
      expect(result.creditedEssence, 550); // 500 * 1100 ~/ 1000 = 550
      expect(result.creditedLaurels, 35);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1550);
      expect(wallet.laurelBalance, 185);

      await db.close();
    });

    // =========================================================================
    // 3. S-Rank + Compute Focus (1050 bps / +5%)
    // =========================================================================
    test('3. S-Rank Decree + Compute Focus: credits 787 Essence (+37 boost) with exact integer truncation', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_s_focus', rewardEssence: 750, rewardLaurels: 50));

      // Record D20=5 Convergence (Compute Focus +5%)
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 5,
        timestamp: now,
      ));

      final result = await repo.claimReward(
        questId: 'quest_s_focus',
        userId: testUser,
        nowOverride: now.add(const Duration(minutes: 7)),
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1050);
      expect(result.hadBuffBoost, true);
      expect(result.creditedEssence, 787); // 750 * 1050 ~/ 1000 = 787500 ~/ 1000 = 787
      expect(result.bonusEssence, 37);
      expect(result.creditedLaurels, 50);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1787);
      expect(wallet.laurelBalance, 200);

      await db.close();
    });

    // =========================================================================
    // 4. Anomaly Turbulence (D20=1, 950 bps) Floor Clamped to 1000 bps
    // =========================================================================
    test('4. Anomaly Turbulence (D20=1): clamped to 1000 bps floor, never penalizes quest rewards below baseline', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_s_turbulence', rewardEssence: 750, rewardLaurels: 50));

      // Record D20=1 Anomaly Turbulence (raw basis points: 950)
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 1,
        timestamp: now,
      ));

      final result = await repo.claimReward(
        questId: 'quest_s_turbulence',
        userId: testUser,
        nowOverride: now.add(const Duration(minutes: 2)),
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1000); // Clamped to 1000 floor
      expect(result.hadBuffBoost, false);
      expect(result.bonusEssence, 0);
      expect(result.creditedEssence, 750); // Exact baseline preserved
      expect(result.creditedLaurels, 50);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1750);
      expect(wallet.laurelBalance, 200);

      await db.close();
    });

    // =========================================================================
    // 5. Expired Buff (>15m) Falls Back to Baseline (1000 bps)
    // =========================================================================
    test('5. Expired Buff (>15m): cleanly falls back to 1000 bps baseline with zero bonus', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final rollTime = DateTime(2026, 3, 10, 12, 0, 0);

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_s_expired', rewardEssence: 750, rewardLaurels: 50));

      // Record D20=20 at 12:00:00 (expires at 12:15:00)
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 20,
        timestamp: rollTime,
      ));

      // Claim at 12:15:01 (1 second past expiration)
      final result = await repo.claimReward(
        questId: 'quest_s_expired',
        userId: testUser,
        nowOverride: DateTime(2026, 3, 10, 12, 15, 1),
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1000);
      expect(result.hadBuffBoost, false);
      expect(result.bonusEssence, 0);
      expect(result.creditedEssence, 750);
      expect(result.creditedLaurels, 50);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1750);
      expect(wallet.laurelBalance, 200);

      await db.close();
    });

    // =========================================================================
    // 6. Zero Divination History Falls Back to Baseline (1000 bps)
    // =========================================================================
    test('6. Zero Divination History: cleanly defaults to 1000 bps baseline without crashing', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_fresh_player', rewardEssence: 500, rewardLaurels: 35));

      // No oracle divination records exist in DB
      final history = await db.getOracleHistoryForUser(testUser);
      expect(history.isEmpty, true);

      final result = await repo.claimReward(
        questId: 'quest_fresh_player',
        userId: testUser,
      );

      expect(result.success, true);
      expect(result.multiplierBasisPoints, 1000);
      expect(result.hadBuffBoost, false);
      expect(result.bonusEssence, 0);
      expect(result.creditedEssence, 500);
      expect(result.creditedLaurels, 35);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1500);
      expect(wallet.laurelBalance, 185);

      await db.close();
    });

    // =========================================================================
    // 7. Pure Integer Arithmetic Bit-Identical Precision
    // =========================================================================
    test('7. Deterministic Bit-Identical Integer Arithmetic: verifies exact truncation across all reward tiers', () {
      const multiplierBps = 1150; // Critical Consensus (+15%)

      // Test suite verifying `(base * bps) ~/ 1000` bit-identical math
      final testCases = <int, int>{
        100: 115,   // 100 * 1150 = 115000 ~/ 1000 = 115
        250: 287,   // 250 * 1150 = 287500 ~/ 1000 = 287 (eliminates 287.5 float drift)
        500: 575,   // 500 * 1150 = 575000 ~/ 1000 = 575
        750: 862,   // 750 * 1150 = 862500 ~/ 1000 = 862 (eliminates 862.5 float drift)
        1000: 1150, // 1000 * 1150 = 1150000 ~/ 1000 = 1150
      };

      for (final entry in testCases.entries) {
        final computed = (entry.key * multiplierBps) ~/ 1000;
        expect(computed, entry.value, reason: 'Failed for base ${entry.key}');
      }
    });

    // =========================================================================
    // 8. Laurels Balance Unmultiplied Invariant Across All Tiers
    // =========================================================================
    test('8. Laurels Balance Invariant: Laurels remain strictly unmultiplied regardless of active buff', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_laurel_check', rewardEssence: 750, rewardLaurels: 50));

      // Active Critical Consensus (1150 bps)
      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 20,
        timestamp: now,
      ));

      final result = await repo.claimReward(
        questId: 'quest_laurel_check',
        userId: testUser,
        nowOverride: now,
      );

      // Essence boosted by +15%
      expect(result.creditedEssence, 862);
      // Laurels strictly unaffected
      expect(result.creditedLaurels, 50);

      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.laurelBalance, 200); // 150 + 50 exactly

      await db.close();
    });

    // =========================================================================
    // 9. Double-Claim Idempotency Under Active Buff
    // =========================================================================
    test('9. Double-Claim Idempotency Under Active Buff: repeated claims return false with zero currency mutation', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      await db.upsertQuestDecree(createQuest(id: 'quest_double_claim', rewardEssence: 750, rewardLaurels: 50));

      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 20,
        timestamp: now,
      ));

      // First claim succeeds
      final firstClaim = await repo.claimReward(
        questId: 'quest_double_claim',
        userId: testUser,
        nowOverride: now,
      );
      expect(firstClaim.success, true);
      expect(firstClaim.creditedEssence, 862);

      // Verify wallet after first claim
      final wallet1 = await db.getPlayerWallet(testUser);
      expect(wallet1!.essenceBalance, 1862);
      expect(wallet1.laurelBalance, 200);

      // Second claim attempt MUST return success=false
      final secondClaim = await repo.claimReward(
        questId: 'quest_double_claim',
        userId: testUser,
        nowOverride: now,
      );
      expect(secondClaim.success, false);
      expect(secondClaim.creditedEssence, 0);
      expect(secondClaim.creditedLaurels, 0);

      // Wallet MUST remain strictly unchanged
      final wallet2 = await db.getPlayerWallet(testUser);
      expect(wallet2!.essenceBalance, 1862);
      expect(wallet2.laurelBalance, 200);

      await db.close();
    });

    // =========================================================================
    // 10. Incomplete Decree Rejection & Transaction Rollback
    // =========================================================================
    test('10. Premature Claim Rejection: incomplete quest throws StateError without wallet mutation under active buff', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);
      final now = DateTime.now();

      await seedInitialWallet(db, essence: 1000, laurels: 150);
      // Incomplete quest (progress: 0.75)
      await db.upsertQuestDecree(createQuest(
        id: 'quest_incomplete',
        rewardEssence: 750,
        rewardLaurels: 50,
        progress: 0.75,
      ));

      await repo.recordRoll(OracleRecord.createCalibratedRecord(
        userId: testUser,
        d20Roll: 20,
        timestamp: now,
      ));

      expect(
        () async => await repo.claimReward(
          questId: 'quest_incomplete',
          userId: testUser,
          nowOverride: now,
        ),
        throwsA(isA<StateError>()),
      );

      // Balances strictly unchanged
      final wallet = await db.getPlayerWallet(testUser);
      expect(wallet!.essenceBalance, 1000);
      expect(wallet.laurelBalance, 150);

      final quest = await db.getQuestDecreeById('quest_incomplete');
      expect(quest!.isClaimed, false);

      await db.close();
    });

    // =========================================================================
    // 11. Restart Persistence of Boosted Claim and Balances
    // =========================================================================
    test('11. Restart Persistence: boosted wallet balance and claimed status persist across DB close/reopen', () async {
      final now = DateTime.now();

      // Session 1: Claim boosted reward
      {
        final session1Db = AppDatabase(NativeDatabase(dbFile));
        final session1Repo = SovereignRepository(session1Db);

        await seedInitialWallet(session1Db, essence: 1000, laurels: 150);
        await session1Db.upsertQuestDecree(createQuest(
          id: 'quest_persist_boost',
          rewardEssence: 750,
          rewardLaurels: 50,
        ));

        await session1Repo.recordRoll(OracleRecord.createCalibratedRecord(
          userId: testUser,
          d20Roll: 20,
          timestamp: now,
        ));

        final claim = await session1Repo.claimReward(
          questId: 'quest_persist_boost',
          userId: testUser,
          nowOverride: now,
        );
        expect(claim.success, true);
        expect(claim.creditedEssence, 862);

        await session1Db.close();
      }

      // Session 2: Reopen from disk, verify state and test double-claim guard
      {
        final session2Db = AppDatabase(NativeDatabase(dbFile));
        final session2Repo = SovereignRepository(session2Db);

        final wallet = await session2Db.getPlayerWallet(testUser);
        expect(wallet, isNotNull);
        expect(wallet!.essenceBalance, 1862);
        expect(wallet.laurelBalance, 200);

        final quest = await session2Db.getQuestDecreeById('quest_persist_boost');
        expect(quest, isNotNull);
        expect(quest!.isClaimed, true);

        // Attempt second claim in new session
        final reClaim = await session2Repo.claimReward(
          questId: 'quest_persist_boost',
          userId: testUser,
          nowOverride: now,
        );
        expect(reClaim.success, false);

        final walletAfter = await session2Db.getPlayerWallet(testUser);
        expect(walletAfter!.essenceBalance, 1862);
        expect(walletAfter.laurelBalance, 200);

        await session2Db.close();
      }
    });
  });
}
