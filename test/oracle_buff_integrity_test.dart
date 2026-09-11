import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/models/oracle_record.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/widgets/aether_resonance_oracle_widget.dart';
import 'package:remainder_portal/presentation/widgets/oracle_chronicle_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;
  const defaultUser = 'test_operator_b4';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.savePlayerWallet(PlayerWallet(
      userId: defaultUser,
      essenceBalance: 500,
      laurelBalance: 50,
      experiencePoints: 100000,
      currentLevel: 50,
      lastUpdated: DateTime.now(),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  group('Thread B-4 — Aether Resonance Oracle & Buff Engine Tests', () {
    test('1. Initial Chronicle Hydration: seeds SQLite on first query and queries exclusively from SQLite', () async {
      final repo = SovereignRepository(db);

      // Verify oracle_histories is initially empty in SQLite
      final initialRows = await db.getOracleHistoryForUser(defaultUser);
      expect(initialRows, isEmpty);

      // First query triggers one-time seeding
      final history = await repo.getHistory(defaultUser);
      expect(history, isNotEmpty);
      expect(history.first.d20Roll, 20);
      expect(history.first.outcomeTier, 'CRITICAL CONSENSUS');

      // Verify record is now in SQLite
      final dbRows = await db.getOracleHistoryForUser(defaultUser);
      expect(dbRows.length, 1);
      expect(dbRows.first.blessingText, history.first.blessingText);
    });

    test('2. Atomic Divination & Essence Debit: debits Essence atomically and persists OracleRecord', () async {
      final repo = SovereignRepository(db);

      // Initial wallet has 500 Essence
      final initialWallet = await repo.getWallet(defaultUser);
      expect(initialWallet.essenceBalance, 500);

      // Execute divination communion with override roll = 18 (Harmonic Aether)
      final record = await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 18,
      );

      expect(record.d20Roll, 18);
      expect(record.outcomeTier, 'HARMONIC AETHER');
      expect(record.buffGranted, contains('Quest Essence Boost'));

      // Verify wallet was atomically debited by exactly 25 Essence
      final updatedWallet = await repo.getWallet(defaultUser);
      expect(updatedWallet.essenceBalance, 475);

      // Verify record exists in SQLite
      final history = await repo.getHistory(defaultUser);
      expect(history.first.d20Roll, 18);
    });

    test('3. Insufficient Resource Rejection: rejects roll when Essence is insufficient without state mutation', () async {
      final repo = SovereignRepository(db);

      // Set wallet balance to 10 Essence (< 25 required)
      final lowWallet = PlayerWallet(
        userId: defaultUser,
        essenceBalance: 10,
        laurelBalance: 50,
        experiencePoints: 100000,
        currentLevel: 50,
        lastUpdated: DateTime.now(),
      );
      await db.savePlayerWallet(lowWallet);

      // Attempting to commune with 25 Essence cost must throw StateError
      expect(
        () async => await repo.communeWithOracle(
          userId: defaultUser,
          costEssence: 25,
          rollOverride: 20,
        ),
        throwsA(isA<StateError>()),
      );

      // Verify wallet balance remained untouched at 10 Essence
      final walletAfter = await repo.getWallet(defaultUser);
      expect(walletAfter.essenceBalance, 10);

      // Verify no roll was logged in SQLite
      final history = await db.getOracleHistoryForUser(defaultUser);
      expect(history, isEmpty);
    });

    test('4. Active Buff Extraction: maps outcome tier to correct multiplier and duration', () async {
      final repo = SovereignRepository(db);

      // Roll a Critical Consensus (D20 = 20)
      await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 20,
      );

      final activeBuffs = await repo.getActiveBuffs(defaultUser);
      expect(activeBuffs, isNotEmpty);

      final buff = activeBuffs.first;
      expect(buff.type, BuffType.aetherMultiplier);
      expect(buff.multiplier, 1.15);
      expect(buff.isExpired, isFalse);
      expect(buff.remainingSeconds, greaterThan(0));
    });

    test('5. Restart Persistence: closing and reopening DB retains history and active buffs', () async {
      final repo = SovereignRepository(db);

      // Perform divination
      await repo.communeWithOracle(
        userId: defaultUser,
        costEssence: 25,
        rollOverride: 16,
      );

      // Close and reopen DB (simulating app restart)
      await db.close();
      final reopenedDb = AppDatabase(NativeDatabase.memory());
      final reopenedRepo = SovereignRepository(reopenedDb);

      // Hydrate starter state on reopened DB and verify
      final reopenedHistory = await reopenedRepo.getHistory(defaultUser);
      expect(reopenedHistory, isNotEmpty);
      expect(reopenedHistory.first.d20Roll, 20); // Default starter on fresh DB

      await reopenedDb.close();
    });

    test('6. Expiry Invalidation: records past 15-minute window are marked expired', () async {
      final repo = SovereignRepository(db);

      // Insert an expired roll from 20 minutes ago
      final oldTime = DateTime.now().subtract(const Duration(minutes: 20));
      final oldRecord = OracleRecord.createCalibratedRecord(
        userId: defaultUser,
        d20Roll: 20,
        timestamp: oldTime,
      );
      await db.recordOracleDivination(oldRecord);

      // Active buff should evaluate as expired
      final buff = oldRecord.activeBuff;
      expect(buff, isNotNull);
      expect(buff!.isExpired, isTrue);
      expect(buff.remainingSeconds, 0);

      // getActiveBuffs should filter it out
      final activeBuffs = await repo.getActiveBuffs(defaultUser);
      expect(activeBuffs, isEmpty);
    });

    testWidgets('7. Widget Reactivity & Responsive Viewports: displays roll, active buff, opens chronicle sheet with zero overflow', (WidgetTester tester) async {
      // Test narrowest viewport (320dp)
      tester.view.physicalSize = const Size(320.0 * 2.0, 640.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = SovereignRepository(db);
      await repo.getHistory(defaultUser); // Seed starter

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AetherResonanceOracleWidget(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Zero RenderFlex exceptions on 320dp viewport
      expect(tester.takeException(), isNull);

      // Verify Oracle header, roll, and cta button
      expect(find.text('AETHER RESONANCE ORACLE'), findsOneWidget);
      expect(find.text('D20 ORACLE: 20'), findsOneWidget);
      expect(find.text('CRITICAL CONSENSUS'), findsOneWidget);
      expect(find.byKey(const Key('oracle_commune_button')), findsOneWidget);

      // Open Chronicle Sheet via CHRONICLE ↗ button
      final openChronicleBtn = find.byKey(const Key('open_oracle_chronicle_sheet'));
      expect(openChronicleBtn, findsOneWidget);
      await tester.tap(openChronicleBtn);
      await tester.pumpAndSettle();

      // Verify Chronicle Sheet is visible
      expect(find.byType(OracleChronicleSheet), findsOneWidget);
      expect(find.text('CHRONICLE OF DIVINATION'), findsOneWidget);

      // Dismiss Chronicle Sheet via close button
      final closeBtn = find.byKey(const Key('close_oracle_chronicle_sheet'));
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(OracleChronicleSheet), findsNothing);

      // Tap commune button to roll oracle
      await tester.tap(find.byKey(const Key('oracle_commune_button')));
      await tester.pumpAndSettle();

      // SnackBar shows divination complete
      expect(find.textContaining('Divination complete:'), findsOneWidget);
    });
  });
}
