import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/presentation/widgets/celestial_bottom_navbar.dart';

void main() {
  group('CelestialBottomNavbar Widget Tests', () {
    testWidgets('renders all 5 navigation items with custom asset paths', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CelestialBottomNavbar(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      // Verify all 5 Image widgets with asset paths
      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(imageWidgets.length, equals(5));

      final expectedAssets = [
        'assets/icon/nav/nav_dashboard.png',
        'assets/icon/nav/nav_terminal.png',
        'assets/icon/nav/nav_expeditions.png',
        'assets/icon/nav/nav_guilds.png',
        'assets/icon/nav/nav_profile.png',
      ];

      for (int i = 0; i < 5; i++) {
        final imageProvider = imageWidgets[i].image as AssetImage;
        expect(imageProvider.assetName, equals(expectedAssets[i]));
      }

      // In initial state (index 0), DASHBOARD label is rendered
      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.text('NEXUS CHAT'), findsNothing);
      expect(find.text('SQUADS'), findsNothing);
      expect(find.text('GUILDS'), findsNothing);
      expect(find.text('SETTINGS'), findsNothing);
    });

    testWidgets('triggers onTap callback when tab is pressed', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CelestialBottomNavbar(
              currentIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Find the second item (Terminal / NEXUS CHAT) and tap it
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsNWidgets(5));

      await tester.tap(gestureDetectors.at(1));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(1));
    });

    testWidgets('displays active label when currentIndex is updated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CelestialBottomNavbar(
              currentIndex: 2, // SQUADS
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('SQUADS'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });
  });
}
