import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:remainder_portal/data/models/utrcs_character.dart';
import 'package:remainder_portal/data/models/character_sheet.dart';
import 'package:remainder_portal/data/services/utrcs_export_service.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';

void main() {
  group('UTRCS Data Model & Serialization Tests', () {
    test('Quick UTRCS character round-trip serialization retains all fields', () {
      final quickChar = UtrcsCharacterModel(
        id: 'test_char_1',
        completionDepth: CompletionDepth.quick,
        createdAt: DateTime(2026, 8, 28, 12, 0),
        updatedAt: DateTime(2026, 8, 28, 12, 0),
        identity: const IdentityLayer(
          name: 'Vanguard Kael',
          concept: 'Exiled Aether Knight',
          externalWant: 'Reclaim the Lost Sanctuary',
          coreFear: 'Becoming corrupted by void anomalies',
          values: ['Duty', 'Honor'],
        ),
        setting: const SettingLayer(sectorOrigin: 'Sanctuary 1'),
        role: const RoleLayer(tacticalArchetype: 'Vanguard Class'),
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 12, shieldIntegrity: 18, energyReserve: 15),
          capabilities: const [
            UtrcsCapability(
              id: 'cap_1',
              name: 'Aether Shield Wall',
              type: 'Active',
              scope: 'Frontline',
              cost: '3 Energy',
              condition: 'Shield equipped',
              failureState: 'Overheat',
              d20Modifier: 3,
            ),
          ],
        ),
        presentation: const PresentationLayer(
          voiceSyntax: 'Formal military cadence.',
          voiceSamples: {'greeting': 'Stand ready, traveler.'},
          oocConsentLimits: ['No permanent dismemberment.'],
        ),
      );

      final jsonMap = quickChar.toJson();
      final decodedChar = UtrcsCharacterModel.fromJson(jsonMap);

      expect(decodedChar.id, equals('test_char_1'));
      expect(decodedChar.completionDepth, equals(CompletionDepth.quick));
      expect(decodedChar.identity.name, equals('Vanguard Kael'));
      expect(decodedChar.identity.concept, equals('Exiled Aether Knight'));
      expect(decodedChar.mechanical.capabilities.length, equals(1));
      expect(decodedChar.mechanical.capabilities.first.name, equals('Aether Shield Wall'));
      expect(decodedChar.mechanical.capabilities.first.d20Modifier, equals(3));
      expect(decodedChar.presentation.oocConsentLimits.first, contains('dismemberment'));
    });

    test('AI prompt projections remain token-efficient (<150 tokens)', () {
      final char = UtrcsCharacterModel(
        id: 'test_char_ai',
        completionDepth: CompletionDepth.standard,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        identity: const IdentityLayer(
          name: 'Archmage Nyx',
          concept: 'Chrono-Loom Weaver',
          externalWant: 'Stabilize dimensional tears',
          coreFear: 'Erasure from the timeline',
        ),
        setting: const SettingLayer(sectorOrigin: 'Sector 4: Aether Spire'),
        role: const RoleLayer(tacticalArchetype: 'Sorcerer Class'),
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 20, shieldIntegrity: 10, energyReserve: 18),
          capabilities: const [
            UtrcsCapability(
              id: 'c1',
              name: 'Temporal Stitch',
              type: 'Active',
              scope: 'Area',
              cost: '5 Energy',
              condition: 'Cast time 1 round',
              failureState: 'Paradox surge',
              d20Modifier: 4,
            ),
          ],
        ),
        presentation: const PresentationLayer(voiceSyntax: 'Calculated, cryptic, fast-paced.'),
      );

      final idContext = char.toAiIdentityContext();
      final voiceContext = char.toAiVoiceContext();
      final mechContext = char.toAiMechanicalContext();

      expect(idContext, contains('Archmage Nyx'));
      expect(idContext, contains('Chrono-Loom Weaver'));
      expect(voiceContext, contains('Calculated, cryptic'));
      expect(mechContext, contains('HP=10'));
      expect(mechContext, contains('Temporal Stitch'));

      // Total string length should be under 400 chars (~80-100 tokens)
      final totalLength = idContext.length + voiceContext.length + mechContext.length;
      expect(totalLength, lessThan(400));
    });

    test('UtrcsExportService formats valid JSON, Markdown, and Discord text cards', () {
      final char = UtrcsCharacterModel(
        id: 'export_test',
        completionDepth: CompletionDepth.quick,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        identity: const IdentityLayer(
          name: 'Operator Sung',
          concept: 'Shadow Monarch',
          externalWant: 'Protect Sanctuary',
          coreFear: 'Failure',
        ),
        setting: const SettingLayer(sectorOrigin: 'Sanctuary 4'),
        role: const RoleLayer(tacticalArchetype: 'Vanguard'),
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 14, shieldIntegrity: 16, energyReserve: 18),
        ),
        presentation: const PresentationLayer(),
      );

      final jsonStr = UtrcsExportService.exportToJson(char);
      expect(jsonStr, contains('"name": "Operator Sung"'));
      expect(json.decode(jsonStr), isA<Map<String, dynamic>>());

      final mdStr = UtrcsExportService.exportToMarkdown(char);
      expect(mdStr, contains('# 🏛️ UTRCS Character Dossier: Operator Sung'));
      expect(mdStr, contains('## 1. Identity & Psychology'));

      final discordStr = UtrcsExportService.exportToDiscordCard(char);
      expect(discordStr, contains('__UTRCS AT-A-GLANCE CHARACTER CARD__'));
      expect(discordStr, contains('`Operator Sung`'));
    });

    test('synthesizeFromLegacy converts PlayerProfile correctly into UTRCS model', () {
      final legacy = PlayerProfile(
        id: 'legacy_123',
        name: 'Aegis Commander',
        origin: 'Vanguard Class',
        activeSector: 'Sector 4',
        stats: CharacterSheet(computePower: 10, shieldIntegrity: 20, energyReserve: 15),
      );

      final utrcsChar = UtrcsCharacterModel.synthesizeFromLegacy(legacy);

      expect(utrcsChar.id, equals('legacy_123'));
      expect(utrcsChar.identity.name, equals('Aegis Commander'));
      expect(utrcsChar.setting.sectorOrigin, equals('Sector 4'));
      expect(utrcsChar.role.tacticalArchetype, equals('Vanguard Class'));
      expect(utrcsChar.mechanical.baseStats.shieldIntegrity, equals(20));
    });
  });
}
