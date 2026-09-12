import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/widgets/portal_background.dart';
import 'package:remainder_portal/presentation/screens/main_navigation_shell.dart';

void main() {
  group('PortalBackground Astrolabe Aesthetic Tests', () {
    testWidgets('renders child content and astrolabe background asset correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PortalBackground(
            child: Center(
              child: Text('AETHER ARBITER PORTAL'),
            ),
          ),
        ),
      );

      // Verify child content is present
      expect(find.text('AETHER ARBITER PORTAL'), findsOneWidget);

      // Verify PortalBackground widget
      expect(find.byType(PortalBackground), findsOneWidget);

      // Verify Image widget is rendered with correct asset
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/images/portal_astrolabe_bg.png'));
      expect(imageWidget.fit, equals(BoxFit.cover));
    });

    testWidgets('supports custom opacity and overlay tint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PortalBackground(
            opacity: 0.75,
            overlayColor: const Color(0x33000000),
            child: const Text('OVERLAY TEST'),
          ),
        ),
      );

      expect(find.text('OVERLAY TEST'), findsOneWidget);

      final opacityFinder = find.byType(Opacity);
      expect(opacityFinder, findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(opacityFinder);
      expect(opacityWidget.opacity, equals(0.75));

      // Verify ColoredBox exists inside PortalBackground (one for base fallback, one for overlay)
      final coloredBoxes = find.descendant(
        of: find.byType(PortalBackground),
        matching: find.byType(ColoredBox),
      );
      expect(coloredBoxes, findsNWidgets(2));
    });

    testWidgets('MainNavigationShell is wrapped with PortalBackground', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );

      expect(find.byType(PortalBackground), findsOneWidget);
      expect(find.byType(MainNavigationShell), findsOneWidget);
    });
  });
}
