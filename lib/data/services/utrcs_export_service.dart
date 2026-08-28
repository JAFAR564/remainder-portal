import 'dart:convert';
import '../models/utrcs_character.dart';

class UtrcsExportService {
  static String exportToJson(UtrcsCharacterModel character) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(character.toJson());
  }

  static String exportToMarkdown(UtrcsCharacterModel character) {
    final buffer = StringBuffer();
    buffer.writeln('# 🏛️ UTRCS Character Dossier: ${character.identity.name}');
    buffer.writeln('**High Concept:** ${character.identity.concept}');
    buffer.writeln('**Archetype / Class:** ${character.role.tacticalArchetype}');
    buffer.writeln('**Sector Origin:** ${character.setting.sectorOrigin}');
    buffer.writeln('**Completion Depth:** ${character.completionDepth.name.toUpperCase()}');
    buffer.writeln();

    buffer.writeln('## 1. Identity & Psychology');
    buffer.writeln('- **External Want:** ${character.identity.externalWant}');
    buffer.writeln('- **Core Fear:** ${character.identity.coreFear}');
    if (character.identity.coreWound != null) {
      buffer.writeln('- **Core Wound:** ${character.identity.coreWound}');
    }
    if (character.identity.internalNeed != null) {
      buffer.writeln('- **Internal Need:** ${character.identity.internalNeed}');
    }
    if (character.identity.internalLie != null) {
      buffer.writeln('- **Internal Lie:** ${character.identity.internalLie}');
    }
    buffer.writeln('- **Core Values:** ${character.identity.values.join(', ')}');
    if (character.identity.contradictions.isNotEmpty) {
      buffer.writeln('- **Contradictions:** ${character.identity.contradictions.join('; ')}');
    }
    buffer.writeln();

    buffer.writeln('## 2. Base Attributes & Capabilities');
    final stats = character.mechanical.baseStats;
    buffer.writeln('- **Stats:** HP: ${stats.shieldIntegrity} | MP: ${stats.energyReserve} | SP: ${stats.computePower}');
    buffer.writeln();
    buffer.writeln('### Capabilities');
    for (final cap in character.mechanical.capabilities) {
      buffer.writeln('#### ${cap.name} (${cap.type}) [D20 Mod: +${cap.d20Modifier}]');
      buffer.writeln('- **Scope:** ${cap.scope}');
      buffer.writeln('- **Cost:** ${cap.cost}');
      buffer.writeln('- **Condition:** ${cap.condition}');
      buffer.writeln('- **Failure State:** ${cap.failureState}');
      buffer.writeln();
    }

    if (character.mechanical.weaknesses.isNotEmpty) {
      buffer.writeln('### Inherent Weaknesses');
      for (final w in character.mechanical.weaknesses) {
        buffer.writeln('- **${w.name}:** ${w.description} *(Invocable by: ${w.invocableBy})*');
      }
      buffer.writeln();
    }

    buffer.writeln('## 3. Presentation & Dialogue Registers');
    buffer.writeln('**Voice Syntax:** ${character.presentation.voiceSyntax}');
    buffer.writeln();
    buffer.writeln('### Dialogue Samples');
    character.presentation.voiceSamples.forEach((key, val) {
      buffer.writeln('- **[$key]:** "$val"');
    });
    buffer.writeln();

    if (character.presentation.nonverbalTells.isNotEmpty) {
      buffer.writeln('### Nonverbal Tells');
      for (final tell in character.presentation.nonverbalTells) {
        buffer.writeln('- $tell');
      }
      buffer.writeln();
    }

    if (character.presentation.oocConsentLimits.isNotEmpty) {
      buffer.writeln('### OOC Consent & Content Boundaries');
      for (final limit in character.presentation.oocConsentLimits) {
        buffer.writeln('- ⚠️ $limit');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String exportToDiscordCard(UtrcsCharacterModel character) {
    final buffer = StringBuffer();
    buffer.writeln('>>> **__UTRCS AT-A-GLANCE CHARACTER CARD__**');
    buffer.writeln('**Name:** `${character.identity.name}` | **Concept:** `${character.identity.concept}`');
    buffer.writeln('**Class:** `${character.role.tacticalArchetype}` | **Sector:** `${character.setting.sectorOrigin}`');
    buffer.writeln('**Want:** ${character.identity.externalWant} | **Fear:** ${character.identity.coreFear}');
    final caps = character.mechanical.capabilities.map((c) => c.name).join(', ');
    buffer.writeln('**Active Capabilities:** $caps');
    if (character.presentation.voiceSamples.isNotEmpty) {
      final sample = character.presentation.voiceSamples.values.first;
      buffer.writeln('**Voice:** *"$sample"*');
    }
    if (character.presentation.oocConsentLimits.isNotEmpty) {
      buffer.writeln('**OOC Limits:** `${character.presentation.oocConsentLimits.first}`');
    }
    return buffer.toString();
  }
}
