import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/screens/dashboard_screen.dart';
import 'package:remainder_portal/presentation/widgets/equipment_slots_widget.dart';
import 'package:remainder_portal/presentation/widgets/quest_decree_widget.dart';
import 'package:remainder_portal/presentation/widgets/aether_resonance_oracle_widget.dart';
import 'package:remainder_portal/presentation/widgets/social_post_card.dart';

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
      await tester.tap(find.text('DISMISS TELEMETRY'));
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
  });
}
