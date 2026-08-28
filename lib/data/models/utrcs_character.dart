import 'character_sheet.dart';
import '../../presentation/providers/game_provider.dart';

enum CompletionDepth { quick, standard, deep }

class IdentityLayer {
  final String name;
  final String concept;
  final String? coreWound;
  final String? internalLie;
  final String externalWant;
  final String? internalNeed;
  final String coreFear;
  final List<String> values;
  final List<String> contradictions;
  final String? defaultBaseline;

  const IdentityLayer({
    required this.name,
    required this.concept,
    this.coreWound,
    this.internalLie,
    required this.externalWant,
    this.internalNeed,
    required this.coreFear,
    this.values = const [],
    this.contradictions = const [],
    this.defaultBaseline,
  });

  factory IdentityLayer.fromJson(Map<String, dynamic> json) {
    return IdentityLayer(
      name: json['name'] as String? ?? 'Traveler',
      concept: json['concept'] as String? ?? 'Soul Vessel Wanderer',
      coreWound: json['coreWound'] as String?,
      internalLie: json['internalLie'] as String?,
      externalWant: json['externalWant'] as String? ?? 'Restore Sector Balance',
      internalNeed: json['internalNeed'] as String?,
      coreFear: json['coreFear'] as String? ?? 'Total Aether Depletion',
      values: (json['values'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      contradictions: (json['contradictions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      defaultBaseline: json['defaultBaseline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'concept': concept,
    'coreWound': coreWound,
    'internalLie': internalLie,
    'externalWant': externalWant,
    'internalNeed': internalNeed,
    'coreFear': coreFear,
    'values': values,
    'contradictions': contradictions,
    'defaultBaseline': defaultBaseline,
  };
}

class SettingLayer {
  final String sectorOrigin;
  final String? factionAffiliation;
  final String? loreAnchor;

  const SettingLayer({
    required this.sectorOrigin,
    this.factionAffiliation,
    this.loreAnchor,
  });

  factory SettingLayer.fromJson(Map<String, dynamic> json) => SettingLayer(
    sectorOrigin: json['sectorOrigin'] as String? ?? 'Sanctuary 4 (Aether Spire)',
    factionAffiliation: json['factionAffiliation'] as String?,
    loreAnchor: json['loreAnchor'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'sectorOrigin': sectorOrigin,
    'factionAffiliation': factionAffiliation,
    'loreAnchor': loreAnchor,
  };
}

class RoleLayer {
  final String tacticalArchetype;
  final String? guildRole;
  final String? squadPosition;

  const RoleLayer({
    required this.tacticalArchetype,
    this.guildRole,
    this.squadPosition,
  });

  factory RoleLayer.fromJson(Map<String, dynamic> json) => RoleLayer(
    tacticalArchetype: json['tacticalArchetype'] as String? ?? 'Vanguard Class',
    guildRole: json['guildRole'] as String?,
    squadPosition: json['squadPosition'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'tacticalArchetype': tacticalArchetype,
    'guildRole': guildRole,
    'squadPosition': squadPosition,
  };
}

class UtrcsRelationshipEntry {
  final String targetId;
  final String targetName;
  final String icBelief;
  final String establishedFact;
  final String oocAgreement;

  const UtrcsRelationshipEntry({
    required this.targetId,
    required this.targetName,
    required this.icBelief,
    required this.establishedFact,
    required this.oocAgreement,
  });

  factory UtrcsRelationshipEntry.fromJson(Map<String, dynamic> json) => UtrcsRelationshipEntry(
    targetId: json['targetId'] as String? ?? '',
    targetName: json['targetName'] as String? ?? 'Ally',
    icBelief: json['icBelief'] as String? ?? 'Trustworthy squadmate',
    establishedFact: json['establishedFact'] as String? ?? 'Fought alongside in Aether Spire',
    oocAgreement: json['oocAgreement'] as String? ?? 'Consent for cooperative skill checks',
  );

  Map<String, dynamic> toJson() => {
    'targetId': targetId,
    'targetName': targetName,
    'icBelief': icBelief,
    'establishedFact': establishedFact,
    'oocAgreement': oocAgreement,
  };
}

class UtrcsCapability {
  final String id;
  final String name;
  final String type; // 'Active', 'Passive', 'Ultimate'
  final String scope;
  final String cost;
  final String condition;
  final String failureState;
  final int d20Modifier;

  const UtrcsCapability({
    required this.id,
    required this.name,
    required this.type,
    required this.scope,
    required this.cost,
    required this.condition,
    required this.failureState,
    this.d20Modifier = 2,
  });

  factory UtrcsCapability.fromJson(Map<String, dynamic> json) => UtrcsCapability(
    id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] as String? ?? 'Aether Cleave',
    type: json['type'] as String? ?? 'Active',
    scope: json['scope'] as String? ?? 'Single Target / Close Range',
    cost: json['cost'] as String? ?? '3 Energy Points',
    condition: json['condition'] as String? ?? 'Must have active weapon equipped',
    failureState: json['failureState'] as String? ?? 'Trigger temporary shield overload',
    d20Modifier: (json['d20Modifier'] as num?)?.toInt() ?? 2,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'scope': scope,
    'cost': cost,
    'condition': condition,
    'failureState': failureState,
    'd20Modifier': d20Modifier,
  };
}

class UtrcsWeakness {
  final String name;
  final String description;
  final String invocableBy;

  const UtrcsWeakness({
    required this.name,
    required this.description,
    this.invocableBy = 'World Arbiter & Squad Master',
  });

  factory UtrcsWeakness.fromJson(Map<String, dynamic> json) => UtrcsWeakness(
    name: json['name'] as String? ?? 'Dimensional Resonance Sensitivity',
    description: json['description'] as String? ?? 'Takes +2 shock damage in corrupted leylines.',
    invocableBy: json['invocableBy'] as String? ?? 'World Arbiter',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'invocableBy': invocableBy,
  };
}

class MechanicalLayer {
  final CharacterSheet baseStats;
  final List<UtrcsCapability> capabilities;
  final List<UtrcsWeakness> weaknesses;

  const MechanicalLayer({
    required this.baseStats,
    this.capabilities = const [],
    this.weaknesses = const [],
  });

  factory MechanicalLayer.fromJson(Map<String, dynamic> json) => MechanicalLayer(
    baseStats: json['baseStats'] != null
        ? CharacterSheet.fromJson(Map<String, dynamic>.from(json['baseStats'] as Map))
        : CharacterSheet(computePower: 14, shieldIntegrity: 16, energyReserve: 18),
    capabilities: (json['capabilities'] as List<dynamic>?)
            ?.map((e) => UtrcsCapability.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [],
    weaknesses: (json['weaknesses'] as List<dynamic>?)
            ?.map((e) => UtrcsWeakness.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'baseStats': baseStats.toJson(),
    'capabilities': capabilities.map((e) => e.toJson()).toList(),
    'weaknesses': weaknesses.map((e) => e.toJson()).toList(),
  };
}

class PresentationLayer {
  final String voiceSyntax;
  final Map<String, String> voiceSamples;
  final List<String> nonverbalTells;
  final List<String> oocConsentLimits;

  const PresentationLayer({
    this.voiceSyntax = 'Direct, resolute, archaic celestial touches.',
    this.voiceSamples = const {
      'greeting': 'Hail, fellow traveler of the Sovereign Remainder.',
      'combat': 'By the Cardinal decrees, this sector will hold!',
      'casual': 'The aether hums softly today.',
    },
    this.nonverbalTells = const ['Tightens hand around blade hilt when evaluating threats'],
    this.oocConsentLimits = const ['No permanent character death without prior OOC agreement'],
  });

  factory PresentationLayer.fromJson(Map<String, dynamic> json) => PresentationLayer(
    voiceSyntax: json['voiceSyntax'] as String? ?? 'Direct, resolute, archaic celestial touches.',
    voiceSamples: (json['voiceSamples'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        const {},
    nonverbalTells: (json['nonverbalTells'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    oocConsentLimits: (json['oocConsentLimits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
  );

  Map<String, dynamic> toJson() => {
    'voiceSyntax': voiceSyntax,
    'voiceSamples': voiceSamples,
    'nonverbalTells': nonverbalTells,
    'oocConsentLimits': oocConsentLimits,
  };
}

class UtrcsCharacterModel {
  final String id;
  final String schemaVersion;
  final CompletionDepth completionDepth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final IdentityLayer identity;
  final SettingLayer setting;
  final RoleLayer role;
  final List<UtrcsRelationshipEntry> relationships;
  final MechanicalLayer mechanical;
  final PresentationLayer presentation;

  const UtrcsCharacterModel({
    required this.id,
    this.schemaVersion = '1.0.0',
    required this.completionDepth,
    required this.createdAt,
    required this.updatedAt,
    required this.identity,
    required this.setting,
    required this.role,
    this.relationships = const [],
    required this.mechanical,
    required this.presentation,
  });

  factory UtrcsCharacterModel.fromJson(Map<String, dynamic> json) {
    CompletionDepth depth = CompletionDepth.quick;
    final depthStr = json['completionDepth'] as String?;
    if (depthStr == 'deep') {
      depth = CompletionDepth.deep;
    } else if (depthStr == 'standard') {
      depth = CompletionDepth.standard;
    }

    return UtrcsCharacterModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      schemaVersion: json['schemaVersion'] as String? ?? '1.0.0',
      completionDepth: depth,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      identity: IdentityLayer.fromJson(Map<String, dynamic>.from(json['identity'] as Map? ?? {})),
      setting: SettingLayer.fromJson(Map<String, dynamic>.from(json['setting'] as Map? ?? {})),
      role: RoleLayer.fromJson(Map<String, dynamic>.from(json['role'] as Map? ?? {})),
      relationships: (json['relationships'] as List<dynamic>?)
              ?.map((e) => UtrcsRelationshipEntry.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      mechanical: MechanicalLayer.fromJson(Map<String, dynamic>.from(json['mechanical'] as Map? ?? {})),
      presentation: PresentationLayer.fromJson(Map<String, dynamic>.from(json['presentation'] as Map? ?? {})),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schemaVersion': schemaVersion,
    'completionDepth': completionDepth.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'identity': identity.toJson(),
    'setting': setting.toJson(),
    'role': role.toJson(),
    'relationships': relationships.map((e) => e.toJson()).toList(),
    'mechanical': mechanical.toJson(),
    'presentation': presentation.toJson(),
  };

  UtrcsCharacterModel copyWith({
    String? id,
    CompletionDepth? completionDepth,
    DateTime? updatedAt,
    IdentityLayer? identity,
    SettingLayer? setting,
    RoleLayer? role,
    List<UtrcsRelationshipEntry>? relationships,
    MechanicalLayer? mechanical,
    PresentationLayer? presentation,
  }) {
    return UtrcsCharacterModel(
      id: id ?? this.id,
      schemaVersion: schemaVersion,
      completionDepth: completionDepth ?? this.completionDepth,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      identity: identity ?? this.identity,
      setting: setting ?? this.setting,
      role: role ?? this.role,
      relationships: relationships ?? this.relationships,
      mechanical: mechanical ?? this.mechanical,
      presentation: presentation ?? this.presentation,
    );
  }

  // Token-budgeted AI Prompt Projections (<150 tokens total)
  String toAiIdentityContext() {
    return '[UTRCS: ${identity.name} | Concept: ${identity.concept} | Want: ${identity.externalWant} | Fear: ${identity.coreFear}]';
  }

  String toAiVoiceContext() {
    return '[Voice: ${presentation.voiceSyntax}]';
  }

  String toAiMechanicalContext() {
    final capNames = mechanical.capabilities.map((c) => c.name).join(', ');
    return '[Stats: HP=${mechanical.baseStats.shieldIntegrity} MP=${mechanical.baseStats.energyReserve} SP=${mechanical.baseStats.computePower} | Caps: $capNames]';
  }

  // Legacy Migration Synthesis
  factory UtrcsCharacterModel.synthesizeFromLegacy(PlayerProfile profile) {
    return UtrcsCharacterModel(
      id: profile.id,
      completionDepth: CompletionDepth.quick,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      identity: IdentityLayer(
        name: profile.name,
        concept: '${profile.origin} Soul Vessel',
        externalWant: 'Defend Sanctuary Nodes',
        coreFear: 'Aether Resonance Collapse',
        values: const ['Honor', 'Consensus', 'Vigilance'],
      ),
      setting: SettingLayer(sectorOrigin: profile.activeSector),
      role: RoleLayer(tacticalArchetype: profile.origin),
      mechanical: MechanicalLayer(
        baseStats: profile.stats,
        capabilities: const [
          UtrcsCapability(
            id: 'cap_default_1',
            name: 'Aether Resonance Strike',
            type: 'Active',
            scope: 'Single Target',
            cost: '2 MP',
            condition: 'Standard weapon drawn',
            failureState: 'Recoil strain',
            d20Modifier: 2,
          ),
        ],
      ),
      presentation: const PresentationLayer(),
    );
  }
}
