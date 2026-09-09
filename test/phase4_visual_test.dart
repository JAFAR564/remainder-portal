import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/data/models/utrcs_character.dart';
import 'package:remainder_portal/data/models/character_sheet.dart';
import 'package:remainder_portal/presentation/widgets/want_vs_need_scale_widget.dart';
import 'package:remainder_portal/presentation/widgets/cognitive_loop_timeline_widget.dart';
import 'package:remainder_portal/presentation/widgets/voice_register_player_widget.dart';
import 'package:remainder_portal/presentation/widgets/capability_anatomy_card.dart';

void main() {
  group('Phase 4: Visual Luxury Widgets Unit & Widget Tests', () {
    testWidgets('WantVsNeedScaleWidget renders scale pans and updates tension correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WantVsNeedScaleWidget(
                externalWant: 'Reclaim the Lost Sanctuary',
                internalNeed: 'Overcome loneliness and trust allies',
                initialTension: 0.5,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('WANT VS. NEED BALANCE SCALE'), findsOneWidget);
      expect(find.text('CONSCIOUS WANT'), findsOneWidget);
      expect(find.text('INTERNAL NEED'), findsOneWidget);
      expect(find.text('Reclaim the Lost Sanctuary'), findsOneWidget);
      expect(find.text('Overcome loneliness and trust allies'), findsOneWidget);
      expect(find.text('HARMONIC EQUILIBRIUM'), findsOneWidget);

      // Verify reset button works
      expect(find.text('RESET'), findsOneWidget);
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();
      expect(find.text('HARMONIC EQUILIBRIUM'), findsOneWidget);
    });

    testWidgets('WantVsNeedScaleWidget reflects ambition dominant when tension is high', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WantVsNeedScaleWidget(
                externalWant: 'Conquer the Aether Citadel',
                internalNeed: null,
                initialTension: 0.85,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AMBITION DOMINANT'), findsOneWidget);
      expect(find.text('85% TENSION'), findsOneWidget);
      expect(find.text('Spiritual Awakening (Unawakened)'), findsOneWidget);
    });

    testWidgets('CognitiveLoopTimelineWidget cycles through 8 stages and binds character data', (WidgetTester tester) async {
      final sampleChar = UtrcsCharacterModel(
        id: 'test_char',
        completionDepth: CompletionDepth.deep,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        identity: const IdentityLayer(
          name: 'Kaelen',
          concept: 'Vanguard Knight',
          coreFear: 'Total dissolution',
          externalWant: 'Save Sector 4',
          internalNeed: 'Forgive self',
          defaultBaseline: 'Meditating in the Sanctuary courtyard',
          values: ['Honor', 'Protection'],
        ),
        setting: const SettingLayer(sectorOrigin: 'Sanctuary 4'),
        role: const RoleLayer(tacticalArchetype: 'Vanguard'),
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 12, shieldIntegrity: 16, energyReserve: 18),
          capabilities: const [
            UtrcsCapability(
              id: 'c1',
              name: 'Aether Shield',
              type: 'Active',
              scope: 'Frontline',
              cost: '2 Energy',
              condition: 'Shield drawn',
              failureState: 'Overheat',
              d20Modifier: 3,
            ),
          ],
        ),
        presentation: const PresentationLayer(
          voiceSyntax: 'Commanding and solemn',
          nonverbalTells: ['Touches sword hilt before speaking'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CognitiveLoopTimelineWidget(character: sampleChar),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('8-STAGE COGNITIVE PROCESSING LOOP'), findsOneWidget);
      expect(find.text('STAGE 1 OF 8'), findsOneWidget);
      expect(find.text('STAGE 1: SENSORY INTAKE & PERCEPTION'), findsOneWidget);

      // Verify character data hook in Stage 1
      expect(find.textContaining('Meditating in the Sanctuary courtyard'), findsOneWidget);

      // Tap Stage 2 chip (S2)
      await tester.tap(find.text('S2'));
      await tester.pumpAndSettle();

      expect(find.text('STAGE 2 OF 8'), findsOneWidget);
      expect(find.text('STAGE 2: APPRAISAL & CORE FEAR'), findsOneWidget);
      expect(find.textContaining('Total dissolution'), findsOneWidget);

      // Step forward via next stage button
      await tester.tap(find.text('NEXT STAGE (3/8)'));
      await tester.pumpAndSettle();

      expect(find.text('STAGE 3 OF 8'), findsOneWidget);
      expect(find.text('STAGE 3: WANT VS. NEED ARBITRATION'), findsOneWidget);
      expect(find.textContaining('Save Sector 4'), findsOneWidget);
    });

    testWidgets('VoiceRegisterPlayerWidget switches registers and toggles playback animation', (WidgetTester tester) async {
      const presentation = PresentationLayer(
        voiceSyntax: 'Sharp, dry, formal delivery',
        voiceSamples: {
          'formal': 'The Council shall judge your actions, traveler.',
          'battle': 'Breach the gate! Hold nothing back!',
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VoiceRegisterPlayerWidget(
                presentation: presentation,
                characterName: 'Operator Sung',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('8-REGISTER VOICE PLAYER'), findsOneWidget);
      expect(find.text('1 OF 8 REGISTERS'), findsOneWidget);
      expect(find.text('"The Council shall judge your actions, traveler."'), findsOneWidget);

      // Toggle audio playback simulation
      expect(find.text('PLAY VOICE CADENCE'), findsOneWidget);
      await tester.tap(find.text('PLAY VOICE CADENCE'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('PAUSE CADENCE'), findsOneWidget);

      // Pause playback so animation settles cleanly
      await tester.tap(find.text('PAUSE CADENCE'));
      await tester.pumpAndSettle();
      expect(find.text('PLAY VOICE CADENCE'), findsOneWidget);

      // Switch to Battle register chip
      await tester.tap(find.text('BATTLE'));
      await tester.pumpAndSettle();

      expect(find.text('2 OF 8 REGISTERS'), findsOneWidget);
      expect(find.text('"Breach the gate! Hold nothing back!"'), findsOneWidget);

      // Copy Quote button
      expect(find.text('COPY QUOTE'), findsOneWidget);
      await tester.tap(find.text('COPY QUOTE'));
      await tester.pumpAndSettle();
      expect(find.textContaining('copied to clipboard!'), findsOneWidget);
    });

    testWidgets('CapabilityAnatomyCard renders 4-part anatomy and executes D20 simulation', (WidgetTester tester) async {
      const capability = UtrcsCapability(
        id: 'cap_test',
        name: 'Void Severance Cleave',
        type: 'Active',
        scope: 'Single Target / Close Range',
        cost: '3 MP & 1 Standard Action',
        condition: 'Blade infused with Aether',
        failureState: 'Vessel suffers 2 shock recoil and weapon unreadies',
        d20Modifier: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CapabilityAnatomyCard(
                capability: capability,
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Void Severance Cleave'), findsOneWidget);
      expect(find.text('+3 D20 CHECK'), findsOneWidget);
      expect(find.text('ACTIVATION COST'), findsOneWidget);
      expect(find.text('3 MP & 1 Standard Action'), findsOneWidget);
      expect(find.text('SCOPE & BOUNDARY'), findsOneWidget);
      expect(find.text('Single Target / Close Range'), findsOneWidget);
      expect(find.text('FAILURE BACKLASH'), findsOneWidget);
      expect(find.text('Vessel suffers 2 shock recoil and weapon unreadies'), findsOneWidget);
      expect(find.text('SYSTEMIC COUNTER'), findsOneWidget);

      // Test D20 Simulation Button
      expect(find.text('SIMULATE D20 CHECK'), findsOneWidget);
      await tester.tap(find.text('SIMULATE D20 CHECK'));
      await tester.pumpAndSettle();

      // Verify D20 modal dialog opened
      expect(find.text('NATURAL D20'), findsOneWidget);
      expect(find.text('MODIFIER'), findsOneWidget);
      expect(find.text('TOTAL vs DC 12'), findsOneWidget);
      expect(find.text('DISMISS'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('DISMISS'));
      await tester.pumpAndSettle();
      expect(find.text('NATURAL D20'), findsNothing);
    });
  });
}
