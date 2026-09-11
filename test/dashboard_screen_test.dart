import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/screens/dashboard_screen.dart';
import 'package:remainder_portal/presentation/screens/character_dossier_screen.dart';
import 'package:remainder_portal/presentation/providers/utrcs_provider.dart';
import 'package:remainder_portal/presentation/providers/sovereign_provider.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/data/models/utrcs_character.dart';
import 'package:remainder_portal/data/models/character_sheet.dart';
import 'package:remainder_portal/data/models/player_wallet.dart';
import 'package:remainder_portal/data/services/database_service.dart';
import 'package:remainder_portal/presentation/widgets/equipment_slots_widget.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_widget.dart';
import 'package:remainder_portal/presentation/widgets/aether_resonance_oracle_widget.dart';
import 'package:remainder_portal/presentation/widgets/social_post_card.dart';
import 'package:remainder_portal/presentation/widgets/relic_vault_sheet.dart';

class _MockUtrcsNotifier extends UtrcsCharacterNotifier {
  _MockUtrcsNotifier(super.ref, super.db, UtrcsCharacterModel initial) {
    state = initial;
  }
}

UtrcsCharacterModel _buildTestCharacter() {
  return UtrcsCharacterModel(
    id: 'operator_zephyr',
    completionDepth: CompletionDepth.quick,
    createdAt: DateTime(2026, 9, 11),
    updatedAt: DateTime(2026, 9, 11),
    identity: const IdentityLayer(
      name: 'Operator Zephyr',
      concept: 'Aetherblade Vanguard',
      externalWant: 'Unify the shattered sectors',
      coreFear: 'Total Leyline Collapse',
    ),
    setting: const SettingLayer(
      sectorOrigin: 'Sector 7 (Resonance Gate)',
    ),
    role: const RoleLayer(
      tacticalArchetype: 'Aetherblade Specialist',
    ),
    mechanical: MechanicalLayer(
      baseStats: CharacterSheet(
        shieldIntegrity: 19,
        energyReserve: 15,
        computePower: 17,
      ),
    ),
    presentation: const PresentationLayer(),
  );
}

void main() {
  group('DashboardScreen Production Upgrade & Responsive Tests', () {
    testWidgets('renders all core dashboard components and interactive widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Settle initial animations
      await tester.pumpAndSettle();

      // 1. Verify Player Header
      expect(find.textContaining('OPERATOR'), findsOneWidget);
      expect(find.text('LEVEL'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);

      // 2. Verify Equipment Slots
      expect(find.byType(EquipmentSlotsWidget), findsOneWidget);
      expect(find.text('EQUIPMENT & GEAR SLOTS'), findsOneWidget);
      expect(find.text('Shadow Dagger'), findsOneWidget);
      expect(find.text('Aegis Cuirass'), findsOneWidget);

      // 3. Verify Aether Resonance Oracle
      expect(find.byType(AetherResonanceOracleWidget), findsOneWidget);
      expect(find.text('AETHER RESONANCE ORACLE'), findsOneWidget);

      // 4. Verify Quest Decree Widget
      expect(find.byType(QuestDecreeWidget), findsOneWidget);
      expect(find.text('WORLD ARBITER QUEST DECREE'), findsOneWidget);
      expect(find.text('DEPART ON QUEST'), findsOneWidget);

      // 5. Verify Stat Meters
      expect(find.text('SOVEREIGN VITALITY & ESSENCE GAUGES'), findsOneWidget);
      expect(find.text('INSPECT ℹ'), findsOneWidget);
      expect(find.text('VITALITY (HP)'), findsOneWidget);
      expect(find.text('AETHER (MP)'), findsOneWidget);
      expect(find.text('SYSTEM (SP)'), findsOneWidget);

      // 6. Verify Realm Hubs
      expect(find.text('SOVEREIGN REALMS & COMMUNION HUBS'), findsOneWidget);
      expect(find.text('Descent'), findsOneWidget);
      expect(find.text('Sanctuary Chat'), findsOneWidget);
      expect(find.text('Squads'), findsOneWidget);
      expect(find.text('Guilds'), findsOneWidget);
      expect(find.text('Canon'), findsOneWidget);
      expect(find.text('Market'), findsOneWidget);
    });

    testWidgets('tapping equipment slot opens EquipmentDetailSheet modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Shadow Dagger slot
      final daggerFinder = find.text('Shadow Dagger');
      await tester.ensureVisible(daggerFinder);
      await tester.pumpAndSettle();
      await tester.tap(daggerFinder);
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('SHADOW DAGGER'), findsOneWidget);
      expect(find.text('CELESTIAL TIER'), findsOneWidget);
      expect(find.text('RESONANCE STAT BONUSES'), findsOneWidget);
      expect(find.text('EQUIPPED (ACTIVE)'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.text('EQUIPPED (ACTIVE)'));
      await tester.pumpAndSettle();

      expect(find.text('CELESTIAL TIER'), findsNothing);
    });

    testWidgets('tapping INSPECT opens vessel telemetry attributes sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on INSPECT ℹ button
      final inspectFinder = find.text('INSPECT ℹ');
      await tester.ensureVisible(inspectFinder);
      await tester.pumpAndSettle();
      await tester.tap(inspectFinder);
      await tester.pumpAndSettle();

      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsOneWidget);
      expect(find.text('VITALITY (SHIELD INTEGRITY)'), findsOneWidget);
      expect(find.text('AETHER (ENERGY RESERVE)'), findsOneWidget);
      expect(find.text('SYSTEM (COMPUTE POWER)'), findsOneWidget);

      // Dismiss telemetry
      final dismissFinder = find.text('DISMISS TELEMETRY');
      await tester.ensureVisible(dismissFinder);
      await tester.tap(dismissFinder);
      await tester.pumpAndSettle();

      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsNothing);
    });

    testWidgets('Honor X8 target viewport (360dp width) renders with zero RenderFlex overflows', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360.0 * 2.0, 800.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify zero uncaught layout exceptions or RenderFlex overflows
      expect(tester.takeException(), isNull);

      // Verify all essential sections render
      expect(find.textContaining('OPERATOR'), findsOneWidget);
      expect(find.text('EQUIPMENT & GEAR SLOTS'), findsOneWidget);
      expect(find.text('AETHER RESONANCE ORACLE'), findsOneWidget);
      expect(find.text('WORLD ARBITER QUEST DECREE'), findsOneWidget);
      expect(find.text('SOVEREIGN VITALITY & ESSENCE GAUGES'), findsOneWidget);
      expect(find.text('SOVEREIGN REALMS & COMMUNION HUBS'), findsOneWidget);
      expect(find.text('SOVEREIGN COMMUNITY WALL & NEWS FEED'), findsOneWidget);
    });

    testWidgets('narrow viewport (320dp width) renders with zero RenderFlex overflows', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320.0 * 2.0, 640.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify zero uncaught layout exceptions on narrowest viewport
      expect(tester.takeException(), isNull);
    });

    testWidgets('SocialPostCard reaction bar with double-digit counts renders without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320.0 * 2.0, 500.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SocialPostCard(
                authorName: 'Archmage Zephyr',
                authorTitle: 'High Scribe of Sanctuary 4',
                avatarPath: 'assets/icon/nav/chronoloom.png',
                timeAgo: '2h ago',
                content: 'Resonance leylines stabilized across the northern quadrant.',
                isIC: true,
                initialLaurels: 99,
                initialComments: 88,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('99 LAURELS'), findsOneWidget);
      expect(find.text('88 COMMENTS'), findsOneWidget);
      expect(find.text('SHARE'), findsOneWidget);

      // Verify laurel button is tappable and increments count
      await tester.tap(find.text('99 LAURELS'));
      await tester.pumpAndSettle();
      expect(find.text('100 LAURELS'), findsOneWidget);
    });

    testWidgets('Operator Sovereign Crest reflects live UTRCS identity and active wallet progression (Thread B-1)', (WidgetTester tester) async {
      final testChar = _buildTestCharacter();
      final testWallet = PlayerWallet(
        userId: 'operator_zephyr',
        currentLevel: 92,
        experiencePoints: 841825, // 75% progression
        lastUpdated: DateTime(2026, 9, 11),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            utrcsCharacterProvider.overrideWith((ref) {
              final db = ref.watch(databaseProvider);
              return _MockUtrcsNotifier(ref, db, testChar);
            }),
            activeWalletProvider.overrideWithValue(AsyncValue.data(testWallet)),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify live name and archetype are displayed
      expect(find.textContaining('OPERATOR ZEPHYR'), findsOneWidget);
      expect(find.textContaining('Aetherblade Specialist • Sector 7 (Resonance Gate)'), findsOneWidget);

      // Verify live level badge
      expect(find.text('LEVEL'), findsOneWidget);
      expect(find.text('92'), findsOneWidget);

      // Verify live animated XP percentage
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('tapping Operator Sovereign Crest navigates to CharacterDossierScreen (Thread B-1)', (WidgetTester tester) async {
      final testChar = _buildTestCharacter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            utrcsCharacterProvider.overrideWith((ref) {
              final db = ref.watch(databaseProvider);
              return _MockUtrcsNotifier(ref, db, testChar);
            }),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Operator Sovereign Crest
      final crestFinder = find.textContaining('OPERATOR ZEPHYR');
      expect(crestFinder, findsOneWidget);
      await tester.tap(crestFinder);
      await tester.pumpAndSettle();

      // Verify navigation to CharacterDossierScreen
      expect(find.byType(CharacterDossierScreen), findsOneWidget);
      expect(find.text('OPERATOR ZEPHYR (DOSSIER)'), findsOneWidget);

      // Verify returning to DashboardScreen via back navigation
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('vessel telemetry gauges reflect canonical attributes and inspect sheet displays truthful status notice (Thread B-1)', (WidgetTester tester) async {
      final testChar = _buildTestCharacter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            utrcsCharacterProvider.overrideWith((ref) {
              final db = ref.watch(databaseProvider);
              return _MockUtrcsNotifier(ref, db, testChar);
            }),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on INSPECT ℹ button
      final inspectFinder = find.text('INSPECT ℹ');
      await tester.ensureVisible(inspectFinder);
      await tester.tap(inspectFinder);
      await tester.pumpAndSettle();

      // Verify canonical attribute values in telemetry sheet (HP 19, MP 15, SP 17)
      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsOneWidget);
      final sheetFinder = find.byType(BottomSheet);
      expect(find.descendant(of: sheetFinder, matching: find.text('19 / 20')), findsOneWidget);
      expect(find.descendant(of: sheetFinder, matching: find.text('15 / 20')), findsOneWidget);
      expect(find.descendant(of: sheetFinder, matching: find.text('17 / 20')), findsOneWidget);

      // Verify truthful contract note regarding un-fabricated combat status
      expect(
        find.textContaining('Canonical Soul Vessel base attributes loaded from active UTRCS manifest'),
        findsOneWidget,
      );

      // Dismiss telemetry
      final dismissFinder = find.text('DISMISS TELEMETRY');
      await tester.ensureVisible(dismissFinder);
      await tester.tap(dismissFinder);
      await tester.pumpAndSettle();
      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsNothing);
    });

    testWidgets('Operator Sovereign Crest gracefully handles wallet loading and error states (Thread B-1)', (WidgetTester tester) async {
      // Test loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWalletProvider.overrideWithValue(const AsyncValue.loading()),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('LEVEL'), findsOneWidget);

      // Test error state fallback
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWalletProvider.overrideWithValue(AsyncValue.error('Timeout', StackTrace.empty)),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('LEVEL'), findsOneWidget);
      expect(find.text('88'), findsOneWidget);
    });

    testWidgets('tablet viewport (768dp width) renders with zero RenderFlex overflows (Thread B-1)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768.0 * 2.0, 1024.0 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('OPERATOR'), findsOneWidget);
      expect(find.text('EQUIPMENT & GEAR SLOTS'), findsOneWidget);
      expect(find.text('AETHER RESONANCE ORACLE'), findsOneWidget);
      expect(find.text('WORLD ARBITER QUEST DECREE'), findsOneWidget);
      expect(find.text('SOVEREIGN VITALITY & ESSENCE GAUGES'), findsOneWidget);
      expect(find.text('SOVEREIGN REALMS & COMMUNION HUBS'), findsOneWidget);
      expect(find.text('SOVEREIGN COMMUNITY WALL & NEWS FEED'), findsOneWidget);
    });

    testWidgets('Dashboard equipment slots allow opening Imperial Relic Vault (Thread B-2)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on VAULT ↗ header action
      final vaultFinder = find.textContaining('VAULT ↗');
      expect(vaultFinder, findsOneWidget);
      await tester.ensureVisible(vaultFinder);
      await tester.tap(vaultFinder);
      await tester.pumpAndSettle();

      // Verify Relic Vault sheet opened
      expect(find.byType(RelicVaultSheet), findsOneWidget);
      expect(find.textContaining('IMPERIAL RELIC VAULT'), findsOneWidget);
    });
  });
}
