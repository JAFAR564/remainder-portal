import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/screens/character_dossier_screen.dart';
import 'package:remainder_portal/presentation/screens/utrcs_creation_screen.dart';
import 'package:remainder_portal/presentation/widgets/utrcs_live_play_card.dart';
import 'package:remainder_portal/presentation/providers/utrcs_provider.dart';

void main() {
  group('CharacterDossierScreen & UTRCS Widget Tests', () {
    testWidgets('renders all 4 tabs and switches views correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CharacterDossierScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Overview Tab content
      expect(find.text('OPERATOR SUNG (DOSSIER)'), findsOneWidget);
      expect(find.text('OVERVIEW'), findsOneWidget);
      expect(find.text('CAPABILITIES'), findsOneWidget);
      expect(find.text('PSYCHOLOGY'), findsOneWidget);
      expect(find.text('LORE & BONDS'), findsOneWidget);

      expect(find.text('SOVEREIGN VESSEL ATTRIBUTES'), findsOneWidget);
      expect(find.text('EXTERNAL WANT'), findsOneWidget);

      // Switch to Capabilities Tab
      await tester.tap(find.text('CAPABILITIES'));
      await tester.pumpAndSettle();

      expect(find.text('ADD SKILL'), findsOneWidget);
      expect(find.text('Shadow Extraction & Cleave'), findsOneWidget);

      // Switch to Psychology Tab
      await tester.tap(find.text('PSYCHOLOGY'));
      await tester.pumpAndSettle();

      expect(find.text('INTERNAL CONFLICT & PSYCHOLOGY'), findsOneWidget);
      expect(find.text('VOICE SYNTAX & CADENCE'), findsOneWidget);
      expect(find.text('DIALOGUE REGISTER SAMPLES'), findsOneWidget);

      // Switch to Lore & Bonds Tab
      await tester.tap(find.text('LORE & BONDS'));
      await tester.pumpAndSettle();

      expect(find.text('TRIPARTITE RELATIONSHIP WEB'), findsOneWidget);
      expect(find.text('OOC CONSENT & CONTENT BOUNDARIES'), findsOneWidget);
    });

    testWidgets('UtrcsLivePlayCard renders at-a-glance summary properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final char = ref.watch(utrcsCharacterProvider);
                  return ElevatedButton(
                    onPressed: () => UtrcsLivePlayCard.show(context, char!),
                    child: const Text('OPEN LIVE CARD'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open live card
      await tester.tap(find.text('OPEN LIVE CARD'));
      await tester.pumpAndSettle();

      expect(find.text('OPERATOR SUNG'), findsOneWidget);
      expect(find.text('ACTIVE CAPABILITIES'), findsOneWidget);
      expect(find.text('OPEN DOSSIER'), findsOneWidget);
      expect(find.text('DISCORD'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });

    testWidgets('UtrcsCreationScreen validates and transitions to dossier', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UtrcsCreationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FORGE UTRCS CHARACTER'), findsOneWidget);
      expect(find.text('AWAKEN SOUL VESSEL & VIEW DOSSIER'), findsOneWidget);

      // Tap submit button
      await tester.tap(find.text('AWAKEN SOUL VESSEL & VIEW DOSSIER'));
      await tester.pumpAndSettle();

      // Verifies navigation to CharacterDossierScreen
      expect(find.byType(CharacterDossierScreen), findsOneWidget);
    });
  });
}
