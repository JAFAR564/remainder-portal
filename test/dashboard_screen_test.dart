import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/screens/dashboard_screen.dart';
import 'package:remainder_portal/presentation/widgets/equipment_slots_widget.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_widget.dart';
import 'package:remainder_portal/presentation/widgets/aether_resonance_oracle_widget.dart';

void main() {
  group('DashboardScreen Production Upgrade Tests', () {
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
      await tester.tap(find.text('Shadow Dagger'));
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
      await tester.tap(find.text('INSPECT ℹ'));
      await tester.pumpAndSettle();

      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsOneWidget);
      expect(find.text('VITALITY (SHIELD INTEGRITY)'), findsOneWidget);
      expect(find.text('AETHER (ENERGY RESERVE)'), findsOneWidget);
      expect(find.text('SYSTEM (COMPUTE POWER)'), findsOneWidget);

      // Dismiss telemetry
      await tester.tap(find.text('DISMISS TELEMETRY'));
      await tester.pumpAndSettle();

      expect(find.text('SOUL VESSEL ATTRIBUTE TELEMETRY'), findsNothing);
    });
  });
}
