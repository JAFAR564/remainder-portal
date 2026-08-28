import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/utrcs_character.dart';
import '../../data/models/character_sheet.dart';
import 'game_provider.dart';

class UtrcsCharacterNotifier extends StateNotifier<UtrcsCharacterModel?> {
  final Ref _ref;

  UtrcsCharacterNotifier(this._ref) : super(null) {
    _initialize();
  }

  void _initialize() {
    final legacyProfile = _ref.read(playerProfileProvider);
    if (legacyProfile != null) {
      state = UtrcsCharacterModel.synthesizeFromLegacy(legacyProfile);
    } else {
      // Default baseline character
      state = UtrcsCharacterModel(
        id: 'utrcs_default_player',
        completionDepth: CompletionDepth.quick,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        identity: const IdentityLayer(
          name: 'Operator Sung',
          concept: 'Shadow Monarch & Sovereign Arbiter',
          coreWound: 'Betrayed during the First Aether Cleave in Sanctuary 1',
          internalLie: 'Only total dominion can protect those under my aegis',
          externalWant: 'Purge the Shadow Serpent anomaly wave',
          internalNeed: 'Learn to entrust the realm to allied squad consensus',
          coreFear: 'Becoming the very catastrophe I was awakened to prevent',
          values: ['Sovereignty', 'Discipline', 'Loyalty'],
          contradictions: ['Commands armies of shadows yet seeks absolute solitude'],
          defaultBaseline: 'Meditating in the Sanctuary Aether Gardens',
        ),
        setting: const SettingLayer(
          sectorOrigin: 'Sanctuary 4 (Aether Spire)',
          factionAffiliation: 'Covenant of Aegis',
          loreAnchor: 'The Ancient Astral Astrolabe',
        ),
        role: const RoleLayer(
          tacticalArchetype: 'Vanguard Class',
          guildRole: 'High Commander',
          squadPosition: 'Frontline Tactician',
        ),
        relationships: const [
          UtrcsRelationshipEntry(
            targetId: 'npc_kaelen',
            targetName: 'Aegis Commander Kaelen',
            icBelief: 'A steadfast shield-brother whose defenses never yield.',
            establishedFact: 'Held the Aether Breach for 3 days together.',
            oocAgreement: 'Consent to cooperative skill checks and tactical endorsements.',
          ),
          UtrcsRelationshipEntry(
            targetId: 'npc_nyx',
            targetName: 'Archmage Nyx',
            icBelief: 'Unpredictable sorceress, but her arcane calculations are flawless.',
            establishedFact: 'Co-authored the Chrono-Loom Sanctuary proposal.',
            oocAgreement: 'Consent to lore votes and cooperative leylines.',
          ),
        ],
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 14, shieldIntegrity: 16, energyReserve: 18),
          capabilities: const [
            UtrcsCapability(
              id: 'cap_1',
              name: 'Shadow Extraction & Cleave',
              type: 'Active',
              scope: 'Melee Arc / Multi-Target',
              cost: '4 Energy Points',
              condition: 'Equipped with Shadow Dagger or Astral Blade',
              failureState: 'Recoil inflicts -2 shield integrity',
              d20Modifier: 3,
            ),
            UtrcsCapability(
              id: 'cap_2',
              name: 'Sovereign Domain Aura',
              type: 'Ultimate',
              scope: 'Squad-Wide Aura',
              cost: '8 Energy Points (Once per Descent)',
              condition: 'Squad trust level >= 80%',
              failureState: 'Energy drain leaves caster exhausted for 1 round',
              d20Modifier: 5,
            ),
            UtrcsCapability(
              id: 'cap_3',
              name: 'Ethereal Perception',
              type: 'Passive',
              scope: 'Self / Sensory',
              cost: 'Passive (0 EP)',
              condition: 'Always active in Sanctuary nodes',
              failureState: 'None',
              d20Modifier: 2,
            ),
          ],
          weaknesses: const [
            UtrcsWeakness(
              name: 'Abyssal Resonance Strain',
              description: 'Takes +3 shock damage when operating in high-Aether corrupted sanctums.',
              invocableBy: 'World Arbiter (Cardinal)',
            ),
          ],
        ),
        presentation: const PresentationLayer(
          voiceSyntax: 'Terse, authoritative, calm monospace precision with archaic cadence.',
          voiceSamples: {
            'greeting': 'State your coordinates and allegiance, traveler.',
            'command': 'Shields up. We advance on my signal.',
            'resolve': 'The Sovereign Remainder does not fall today.',
          },
          nonverbalTells: [
            'Faint shadow particles drift from gauntlets when calculating combat vectors.',
            'Eyes gleam with frosted cream aether when channeling the World Arbiter.',
          ],
          oocConsentLimits: [
            'No character death without explicit out-of-character agreement.',
            'No permanent loss of core relic equipment without narrative consensus.',
          ],
        ),
      );
    }
  }

  void saveCharacter(UtrcsCharacterModel character) {
    state = character.copyWith(updatedAt: DateTime.now());
  }

  void setCompletionDepth(CompletionDepth depth) {
    if (state != null) {
      state = state!.copyWith(completionDepth: depth);
    }
  }

  void addCapability(UtrcsCapability cap) {
    if (state != null) {
      final updatedCaps = [...state!.mechanical.capabilities, cap];
      state = state!.copyWith(
        mechanical: MechanicalLayer(
          baseStats: state!.mechanical.baseStats,
          capabilities: updatedCaps,
          weaknesses: state!.mechanical.weaknesses,
        ),
      );
    }
  }

  void removeCapability(String capId) {
    if (state != null) {
      final updatedCaps = state!.mechanical.capabilities.where((c) => c.id != capId).toList();
      state = state!.copyWith(
        mechanical: MechanicalLayer(
          baseStats: state!.mechanical.baseStats,
          capabilities: updatedCaps,
          weaknesses: state!.mechanical.weaknesses,
        ),
      );
    }
  }

  void addRelationship(UtrcsRelationshipEntry rel) {
    if (state != null) {
      state = state!.copyWith(relationships: [...state!.relationships, rel]);
    }
  }
}

final utrcsCharacterProvider = StateNotifierProvider<UtrcsCharacterNotifier, UtrcsCharacterModel?>((ref) {
  return UtrcsCharacterNotifier(ref);
});
