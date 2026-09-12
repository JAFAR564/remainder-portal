import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:path/path.dart' as p;

import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/data/services/database_service.dart' hide PlayerWallet;
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_widget.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_sheet.dart';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drift_quest_decree_test_');
    dbFile = File(p.join(tempDir.path, 'quest_decree_test.db'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Thread B-3 — World Arbiter Quest & Decree Lifecycle Integration', () {
    const defaultUser = 'utrcs_default_player';

    // =========================================================================
    // 1. Initial Decree Hydration: SQLite Seed-Once, Authoritative Read
    // =========================================================================
    test('1. Initial Decree Hydration: seeds SQLite on first query and queries exclusively from SQLite', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      // First query seeds initial decrees into SQLite
      final decrees = await repo.getQuests(defaultUser);
      expect(decrees.length, 2);

      // Verify the decrees exist in SQLite table
      final dbRows = await db.getQuestDecreesForUser(defaultUser);
      expect(dbRows.length, 2);
      expect(dbRows.any((q) => q.id == 'quest_sanctuary_outpost'), true);
      expect(dbRows.any((q) => q.id == 'quest_aether_conduit'), true);

      // Second query returns directly from SQLite
      final cachedDecrees = await repo.getQuests(defaultUser);
      expect(cachedDecrees.length, 2);

      await db.close();
    });

    // =========================================================================
    // 2. Deterministic Progress Update in SQLite
    // =========================================================================
    test('2. Progress Update: persists progress change to SQLite', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await repo.getQuests(defaultUser);

      // Update progress from 0.65 to 0.90
      await repo.updateQuestProgress(questId: 'quest_sanctuary_outpost', progress: 0.90);

      final updatedRow = await db.getQuestDecreeById('quest_sanctuary_outpost');
      expect(updatedRow, isNotNull);
      expect(updatedRow!.progress, 0.90);

      await db.close();
    });

    // =========================================================================
    // 3. Completed Quest Reward Claim & Atomic Multi-Table Settlement
    // =========================================================================
    test('3. Reward Claim: atomically marks decree claimed and credits player wallet', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      // Initialize wallet with baseline 1000 Essence & 150 Laurels
      await db.savePlayerWallet(PlayerWallet(
        userId: defaultUser,
        essenceBalance: 1000,
        laurelBalance: 150,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));

      await repo.getQuests(defaultUser);

      // quest_aether_conduit is completed (progress: 1.0, reward: 500 Essence, 35 Laurels)
      final success = await repo.claimReward(questId: 'quest_aether_conduit', userId: defaultUser);
      expect(success.success, true);
      expect(success.creditedEssence, 500);
      expect(success.creditedLaurels, 35);
      expect(success.hadBuffBoost, false);

      // Verify decree is marked claimed in SQLite
      final decree = await db.getQuestDecreeById('quest_aether_conduit');
      expect(decree!.isClaimed, true);

      // Verify wallet was atomically credited: 1000 + 500 = 1500 Essence, 150 + 35 = 185 Laurels
      final wallet = await db.getPlayerWallet(defaultUser);
      expect(wallet!.essenceBalance, 1500);
      expect(wallet.laurelBalance, 185);

      await db.close();
    });

    // =========================================================================
    // 4. Double-Claim Exploit Protection
    // =========================================================================
    test('4. Double-Claim Guard: repeated claim attempts return false with zero currency mutation', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await db.savePlayerWallet(PlayerWallet(
        userId: defaultUser,
        essenceBalance: 1000,
        laurelBalance: 150,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));

      await repo.getQuests(defaultUser);

      // First claim succeeds
      final firstAttempt = await repo.claimReward(questId: 'quest_aether_conduit', userId: defaultUser);
      expect(firstAttempt.success, true);

      // Second claim attempt MUST return false (double-claim prevented)
      final secondAttempt = await repo.claimReward(questId: 'quest_aether_conduit', userId: defaultUser);
      expect(secondAttempt.success, false);

      // Verify wallet was credited EXACTLY ONCE
      final wallet = await db.getPlayerWallet(defaultUser);
      expect(wallet!.essenceBalance, 1500);
      expect(wallet.laurelBalance, 185);

      await db.close();
    });

    // =========================================================================
    // 5. Premature Claim Protection (Incomplete Quest Rejection)
    // =========================================================================
    test('5. Premature Claim Guard: attempting to claim incomplete quest throws StateError without wallet mutation', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await db.savePlayerWallet(PlayerWallet(
        userId: defaultUser,
        essenceBalance: 1000,
        laurelBalance: 150,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));

      await repo.getQuests(defaultUser);

      // quest_sanctuary_outpost is only at 65% progress (not completed)
      expect(
        () async => await repo.claimReward(questId: 'quest_sanctuary_outpost', userId: defaultUser),
        throwsA(isA<StateError>()),
      );

      // Verify wallet remains completely untouched
      final wallet = await db.getPlayerWallet(defaultUser);
      expect(wallet!.essenceBalance, 1000);
      expect(wallet.laurelBalance, 150);

      // Decree remains unclaimed
      final decree = await db.getQuestDecreeById('quest_sanctuary_outpost');
      expect(decree!.isClaimed, false);

      await db.close();
    });

    // =========================================================================
    // 6. Restart Persistence: Close & Reopen Database
    // =========================================================================
    test('6. Restart Persistence: DB restart retains claimed status, progress, and wallet balances', () async {
      // Session 1: Perform progress update and claim
      {
        final db1 = AppDatabase(NativeDatabase(dbFile));
        final repo1 = SovereignRepository(db1);

        await db1.savePlayerWallet(PlayerWallet(
          userId: defaultUser,
          essenceBalance: 1000,
          laurelBalance: 150,
          experiencePoints: 765000,
          currentLevel: 88,
          lastUpdated: DateTime.now(),
        ));

        await repo1.getQuests(defaultUser);
        await repo1.updateQuestProgress(questId: 'quest_sanctuary_outpost', progress: 0.85);
        await repo1.claimReward(questId: 'quest_aether_conduit', userId: defaultUser);

        await db1.close();
      }

      // Session 2: Reopen from same file on disk
      {
        final db2 = AppDatabase(NativeDatabase(dbFile));
        final repo2 = SovereignRepository(db2);

        final quests = await repo2.getQuests(defaultUser);
        final sanctuaryQuest = quests.firstWhere((q) => q.id == 'quest_sanctuary_outpost');
        final conduitQuest = quests.firstWhere((q) => q.id == 'quest_aether_conduit');

        expect(sanctuaryQuest.progress, 0.85);
        expect(sanctuaryQuest.isClaimed, false);

        expect(conduitQuest.progress, 1.0);
        expect(conduitQuest.isClaimed, true);

        final wallet = await db2.getPlayerWallet(defaultUser);
        expect(wallet!.essenceBalance, 1500);
        expect(wallet.laurelBalance, 185);

        await db2.close();
      }
    });

    // =========================================================================
    // 7. Widget Reactivity: In-Progress vs Claim Flow & Decree Sheet
    // =========================================================================
    testWidgets('7. Widget Reactivity: displays in-progress action, claim button on completed quest, and opens decree sheet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      // Initialize wallet & quests
      await db.savePlayerWallet(PlayerWallet(
        userId: defaultUser,
        essenceBalance: 1000,
        laurelBalance: 150,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));
      await repo.getQuests(defaultUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: QuestDecreeWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. By default, urgent active quest (quest_sanctuary_outpost) is tracked on dashboard!
      expect(find.text('DEPART ON QUEST'), findsOneWidget);
      expect(find.text('65% ANOMALY PURGED'), findsOneWidget);
      expect(find.byKey(const Key('quest_depart_button')), findsOneWidget);

      // 2. Tap DECREES ↗ to open QuestDecreeSheet modal
      final openSheetBtn = find.byKey(const Key('open_decrees_sheet'));
      expect(openSheetBtn, findsOneWidget);
      await tester.tap(openSheetBtn);
      await tester.pumpAndSettle();

      // Verify sheet opens and lists both proclamations
      expect(find.byType(QuestDecreeSheet), findsOneWidget);
      expect(find.text('WORLD ARBITER DECREES'), findsOneWidget);
      expect(find.text('2 PROCLAMATIONS'), findsOneWidget);

      // 3. Claim completed quest (quest_aether_conduit) directly from the sheet
      final sheetClaimBtn = find.byKey(const Key('sheet_claim_quest_aether_conduit'));
      expect(sheetClaimBtn, findsOneWidget);
      await tester.tap(sheetClaimBtn);
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation
      expect(find.textContaining('Decree Fulfilled!'), findsOneWidget);

      // Dismiss modal via close button
      final closeSheetBtn = find.byKey(const Key('close_decrees_sheet'));
      expect(closeSheetBtn, findsOneWidget);
      await tester.tap(closeSheetBtn);
      await tester.pumpAndSettle();
      expect(find.byType(QuestDecreeSheet), findsNothing);

      // 4. Update quest_sanctuary_outpost to 1.0 progress via repository
      await repo.updateQuestProgress(questId: 'quest_sanctuary_outpost', progress: 1.0);
      // Re-trigger reload on the provider
      final element = tester.element(find.byType(QuestDecreeWidget));
      final container = ProviderScope.containerOf(element);
      await container.read(questDecreeProvider(defaultUser).notifier).loadDecrees();
      await tester.pumpAndSettle();

      // 5. Dashboard dynamically updates to CLAIM REWARDS button
      final dashClaimBtn = find.byKey(const Key('quest_claim_button'));
      expect(dashClaimBtn, findsOneWidget);
      expect(find.text('100% ANOMALY PURGED'), findsOneWidget);

      // 6. Tap CLAIM REWARDS on dashboard
      await tester.tap(dashClaimBtn);
      await tester.pumpAndSettle();

      // Dashboard now transitions to FULFILLED state
      expect(find.byKey(const Key('quest_fulfilled_button')), findsOneWidget);
      expect(find.text('FULFILLED'), findsWidgets);

      // 7. Verify SQLite wallet balance updated atomically for both claims: 1000 + 500 + 750 = 2250
      final wallet = await db.getPlayerWallet(defaultUser);
      expect(wallet!.essenceBalance, 2250);
      expect(wallet.laurelBalance, 235);

      await db.close();
    });
  });
}
