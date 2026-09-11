import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:path/path.dart' as p;

import 'package:remainder_portal/data/models/equipment_item_model.dart';
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/repositories/sovereign_repository.dart';
import 'package:remainder_portal/data/services/database_service.dart' hide PlayerWallet;
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/widgets/equipment_slots_widget.dart';
import 'package:remainder_portal/presentation/widgets/equipment_detail_sheet.dart';
import 'package:remainder_portal/presentation/widgets/relic_vault_sheet.dart';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drift_relic_vault_test_');
    dbFile = File(p.join(tempDir.path, 'relic_vault_test.db'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Thread B-2 — Imperial Relic Vault & Persistent Equipment Integration', () {
    const defaultUser = 'utrcs_default_player';

    // =========================================================================
    // 1. Empty slot -> Vault (opens persistent inventory filtered by slot)
    // =========================================================================
    testWidgets('1. Empty slot -> Vault: tapping empty slot opens persistent vault filtered by compatible slot', (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      // Initialize default gear
      await repo.getEquipment(defaultUser);
      // Unequip weapon to make slot empty
      await repo.unequipItem(userId: defaultUser, itemId: 'relic_weapon_shadow_dagger');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EquipmentSlotsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // WEAPON slot should display as Empty
      expect(find.text('Empty'), findsWidgets);

      // Tap on the empty WEAPON slot
      final emptyWeaponSlot = find.byKey(const Key('slot_WEAPON'));
      expect(emptyWeaponSlot, findsOneWidget);
      await tester.tap(emptyWeaponSlot);
      await tester.pumpAndSettle();

      // Relic Vault Sheet opens, filtered to WEAPON
      expect(find.byType(RelicVaultSheet), findsOneWidget);
      expect(find.text('IMPERIAL RELIC VAULT • WEAPON'), findsOneWidget);

      // Vault shows available unequipped weapons
      expect(find.text('Shadow Dagger'), findsOneWidget);
      expect(find.text('Obsidian Edge'), findsOneWidget);

      // Clean up
      await db.close();
    });

    // =========================================================================
    // 2. Vault -> Equip (persistent transaction, slot updates reactively)
    // =========================================================================
    testWidgets('2. Vault -> Equip: equipping relic from vault updates slot reactively and persists', (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await repo.getEquipment(defaultUser);
      await repo.unequipItem(userId: defaultUser, itemId: 'relic_weapon_shadow_dagger');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EquipmentSlotsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open vault from empty weapon slot
      await tester.tap(find.byKey(const Key('slot_WEAPON')));
      await tester.pumpAndSettle();

      // Tap "EQUIP TO WEAPON" on Obsidian Edge
      final equipButton = find.widgetWithText(ElevatedButton, 'EQUIP TO WEAPON').first;
      await tester.tap(equipButton);
      await tester.pumpAndSettle();

      // Vault sheet is dismissed and slot now displays Obsidian Edge
      expect(find.byType(RelicVaultSheet), findsNothing);
      expect(find.text('Obsidian Edge'), findsOneWidget);

      // Verify persistence in SQLite
      final allItems = await db.getEquipmentForUser(defaultUser);
      final equippedWeapon = allItems.firstWhere((i) => i.slot == 'WEAPON' && i.isEquipped);
      expect(equippedWeapon.name, 'Obsidian Edge');

      await db.close();
    });

    // =========================================================================
    // 3. Equip -> Detail (existing detail surface with persisted item data)
    // =========================================================================
    testWidgets('3. Equip -> Detail: tapping equipped slot opens detail modal with persisted data', (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await repo.getEquipment(defaultUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EquipmentSlotsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Aegis Cuirass slot
      final armorFinder = find.text('Aegis Cuirass');
      await tester.tap(armorFinder);
      await tester.pumpAndSettle();

      // Detail sheet opens with persisted attributes
      expect(find.byType(EquipmentDetailSheet), findsOneWidget);
      expect(find.text('AEGIS CUIRASS'), findsOneWidget);
      expect(find.text('SOVEREIGN TIER'), findsOneWidget);
      expect(find.text('SLOT: ARMOR'), findsOneWidget);
      expect(find.text('+20 Shield Integrity, +10 Vitality'), findsOneWidget);
      expect(find.text('EQUIPPED (ACTIVE)'), findsOneWidget);
      expect(find.text('UNEQUIP'), findsOneWidget);

      // Dismiss
      await tester.tap(find.text('EQUIPPED (ACTIVE)'));
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentDetailSheet), findsNothing);

      await db.close();
    });

    // =========================================================================
    // 4. Unequip -> Vault (state transition to unequipped, zero deletion)
    // =========================================================================
    testWidgets('4. Unequip -> Vault: unequipping item transitions state to vault without deleting row', (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      await repo.getEquipment(defaultUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EquipmentSlotsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open Aegis Cuirass detail sheet
      await tester.tap(find.text('Aegis Cuirass'));
      await tester.pumpAndSettle();

      // Tap UNEQUIP
      await tester.tap(find.text('UNEQUIP'));
      await tester.pumpAndSettle();

      // Detail sheet dismissed
      expect(find.byType(EquipmentDetailSheet), findsNothing);

      // Slot is now empty
      expect(find.byKey(const Key('slot_ARMOR')), findsOneWidget);

      // Verify row is STILL IN DATABASE (not deleted)
      final allItems = await db.getEquipmentForUser(defaultUser);
      final unequippedArmor = allItems.firstWhere((i) => i.id == 'relic_armor_aegis_cuirass');
      expect(unequippedArmor, isNotNull);
      expect(unequippedArmor.isEquipped, false);
      expect(unequippedArmor.name, 'Aegis Cuirass');

      await db.close();
    });

    // =========================================================================
    // 5. Upgrade -> Essence (atomic debit + upgrade, rejects insufficient essence)
    // =========================================================================
    test('5. Upgrade -> Essence: atomic debit and level increment, overdraft rejected without partial update', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      final repo = SovereignRepository(db);

      // Initialize wallet with 300 Essence
      await db.savePlayerWallet(PlayerWallet(
        userId: 'operator_upgrade_test',
        essenceBalance: 300,
        laurelBalance: 50,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));

      // Insert test item at level 0
      final weapon = EquipmentItemModel(
        id: 'upgrade_test_sword',
        userId: 'operator_upgrade_test',
        slot: 'WEAPON',
        name: 'Astral Cleaver',
        rarity: EquipmentRarity.celestial,
        statBonus: '+50 ATK',
        description: 'Test blade.',
        iconName: 'colorize',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: DateTime.now(),
      );
      await db.upsertEquipment(weapon);

      // Step A: Upgrade with sufficient Essence (cost 150)
      final upgradedItem = await repo.upgradeItem(
        itemId: 'upgrade_test_sword',
        userId: 'operator_upgrade_test',
        costEssence: 150,
      );

      expect(upgradedItem.upgradeLevel, 1);

      // Verify wallet debited by exactly 150
      final walletAfterFirst = await repo.getWallet('operator_upgrade_test');
      expect(walletAfterFirst.essenceBalance, 150);

      // Step B: Attempt second upgrade with insufficient Essence (cost 200, balance 150)
      await expectLater(
        () => repo.upgradeItem(
          itemId: 'upgrade_test_sword',
          userId: 'operator_upgrade_test',
          costEssence: 200,
        ),
        throwsStateError,
      );

      // Verify atomic rollback: Essence balance remains 150, upgradeLevel remains 1
      final walletAfterRollback = await repo.getWallet('operator_upgrade_test');
      expect(walletAfterRollback.essenceBalance, 150);

      final itemAfterRollback = await db.getEquipmentById('upgrade_test_sword');
      expect(itemAfterRollback!.upgradeLevel, 1);

      await db.close();
    });

    // =========================================================================
    // 6. Restart persistence (close DB, reopen, verify state)
    // =========================================================================
    test('6. Restart persistence: DB close and reopen retains equipped, unequipped, and upgrade states', () async {
      // Session 1: write and mutate
      var db = AppDatabase(NativeDatabase(dbFile));
      var repo = SovereignRepository(db);

      await repo.getEquipment('operator_restart_test');
      await repo.unequipItem(userId: 'operator_restart_test', itemId: 'relic_armor_aegis_cuirass');
      await repo.upgradeItem(
        itemId: 'relic_weapon_shadow_dagger',
        userId: 'operator_restart_test',
        costEssence: 150,
      );

      // Close database handle
      await db.close();

      // Session 2: reopen fresh AppDatabase instance on same file
      db = AppDatabase(NativeDatabase(dbFile));
      repo = SovereignRepository(db);

      final itemsAfterRestart = await repo.getEquipment('operator_restart_test');
      final dagger = itemsAfterRestart.firstWhere((i) => i.id == 'relic_weapon_shadow_dagger');
      final cuirass = itemsAfterRestart.firstWhere((i) => i.id == 'relic_armor_aegis_cuirass');

      // Verify Shadow Dagger is equipped and level 1
      expect(dagger.isEquipped, true);
      expect(dagger.upgradeLevel, 1);

      // Verify Aegis Cuirass is unequipped in vault
      expect(cuirass.isEquipped, false);

      // Verify wallet Essence was persisted at 850 (1000 - 150)
      final wallet = await repo.getWallet('operator_restart_test');
      expect(wallet.essenceBalance, 850);

      await db.close();
    });

    // =========================================================================
    // 7. Exploit Test: Upgrade idempotency & atomicity across restart
    // =========================================================================
    test('7. Exploit Test: Upgrade succeeds, DB closes/reopens, verify Essence deducted once & level incremented once', () async {
      // Step A: Initial state
      var db = AppDatabase(NativeDatabase(dbFile));
      var repo = SovereignRepository(db);

      await db.savePlayerWallet(PlayerWallet(
        userId: 'exploit_operator',
        essenceBalance: 1000,
        laurelBalance: 200,
        experiencePoints: 765000,
        currentLevel: 88,
        lastUpdated: DateTime.now(),
      ));

      final testRelic = EquipmentItemModel(
        id: 'exploit_relic_01',
        userId: 'exploit_operator',
        slot: 'RELIC',
        name: 'Void Compass',
        rarity: EquipmentRarity.sovereign,
        statBonus: '+100 Void Resonance',
        description: 'Priceless celestial compass.',
        iconName: 'auto_awesome',
        upgradeLevel: 0,
        isEquipped: true,
        acquiredAt: DateTime.now(),
      );
      await db.upsertEquipment(testRelic);

      // Step B: Execute single upgrade
      final upgraded = await repo.upgradeItem(
        itemId: 'exploit_relic_01',
        userId: 'exploit_operator',
        costEssence: 250,
      );
      expect(upgraded.upgradeLevel, 1);

      // Step C: Simulate hard application termination & restart
      await db.close();

      db = AppDatabase(NativeDatabase(dbFile));
      repo = SovereignRepository(db);

      // Step D: Verify post-restart integrity
      final reloadedWallet = await repo.getWallet('exploit_operator');
      expect(reloadedWallet.essenceBalance, 750); // Exactly 1000 - 250

      final reloadedRelic = await db.getEquipmentById('exploit_relic_01');
      expect(reloadedRelic, isNotNull);
      expect(reloadedRelic!.upgradeLevel, 1); // Exactly 0 + 1

      // Step E: Attempt an overdraft exploit
      await expectLater(
        () => repo.upgradeItem(
          itemId: 'exploit_relic_01',
          userId: 'exploit_operator',
          costEssence: 99999, // Exceeds balance of 750
        ),
        throwsStateError,
      );

      // Close and reopen again to verify zero corruption occurred from failed transaction
      await db.close();

      db = AppDatabase(NativeDatabase(dbFile));
      repo = SovereignRepository(db);

      final finalWallet = await repo.getWallet('exploit_operator');
      expect(finalWallet.essenceBalance, 750); // Still 750

      final finalRelic = await db.getEquipmentById('exploit_relic_01');
      expect(finalRelic!.upgradeLevel, 1); // Still 1

      await db.close();
    });
  });
}
