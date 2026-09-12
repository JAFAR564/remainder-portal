enum BuffType {
  questRewardBoost,
  computeFocus,
  aetherMultiplier,
  vitalityShield,
  anomalyTurbulence,
}

/// Represents an active temporal buff granted by the Oracle.
class ActiveBuff {
  final String id;
  final BuffType type;
  final String title;
  final double multiplier;
  final DateTime startedAt;
  final DateTime expiresAt;

  const ActiveBuff({
    required this.id,
    required this.type,
    required this.title,
    required this.multiplier,
    required this.startedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}

/// Persistent record of a D20 divination roll from the Aether Resonance Oracle.
class OracleRecord {
  final String id;
  final String userId;
  final int d20Roll;
  final String outcomeTier; // 'CRITICAL CONSENSUS', 'HARMONIC AETHER', 'EQUILIBRIUM', 'TURBULENCE'
  final String blessingText;
  final String? buffGranted;
  final DateTime timestamp;

  const OracleRecord({
    required this.id,
    required this.userId,
    required this.d20Roll,
    required this.outcomeTier,
    required this.blessingText,
    this.buffGranted,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'd20_roll': d20Roll,
      'outcome_tier': outcomeTier,
      'blessing_text': blessingText,
      'buff_granted': buffGranted,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory OracleRecord.fromJson(Map<String, dynamic> json) {
    return OracleRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      d20Roll: (json['d20_roll'] as num?)?.toInt() ?? 20,
      outcomeTier: json['outcome_tier'] as String? ?? 'EQUILIBRIUM',
      blessingText: json['blessing_text'] as String,
      buffGranted: json['buff_granted'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
    );
  }

  /// Extracts the active temporal buff from this divination record, if one was granted.
  ActiveBuff? get activeBuff {
    if (buffGranted == null || buffGranted!.isEmpty) return null;

    BuffType type = BuffType.aetherMultiplier;
    double mult = 1.15;
    Duration duration = const Duration(minutes: 15);

    final bgLower = buffGranted!.toLowerCase();
    if (outcomeTier == 'CRITICAL CONSENSUS' || bgLower.contains('aether')) {
      type = BuffType.aetherMultiplier;
      mult = 1.15;
      duration = const Duration(minutes: 15);
    } else if (outcomeTier == 'HARMONIC AETHER' || bgLower.contains('essence') || bgLower.contains('reward')) {
      type = BuffType.questRewardBoost;
      mult = 1.10;
      duration = const Duration(minutes: 15);
    } else if (outcomeTier == 'EQUILIBRIUM' || bgLower.contains('shield') || bgLower.contains('vitality')) {
      type = BuffType.vitalityShield;
      mult = 1.10;
      duration = const Duration(minutes: 15);
    } else if (outcomeTier.contains('TURBULENCE') || bgLower.contains('turbulence')) {
      type = BuffType.anomalyTurbulence;
      mult = 0.95;
      duration = const Duration(minutes: 5);
    } else {
      type = BuffType.computeFocus;
      mult = 1.05;
      duration = const Duration(minutes: 15);
    }

    final expiresAt = timestamp.add(duration);
    return ActiveBuff(
      id: 'buff_$id',
      type: type,
      title: buffGranted!,
      multiplier: mult,
      startedAt: timestamp,
      expiresAt: expiresAt,
    );
  }

  /// Determines canonical outcome tier from D20 roll deterministically.
  static String determineOutcomeTier(int d20Roll) {
    if (d20Roll >= 20) return 'CRITICAL CONSENSUS';
    if (d20Roll >= 15) return 'HARMONIC AETHER';
    if (d20Roll >= 10) return 'EQUILIBRIUM';
    if (d20Roll >= 2) return 'CONVERGENCE';
    return 'ANOMALY TURBULENCE';
  }

  /// Maps a D20 roll deterministically to its canonical outcome tier, blessing text, and buff.
  /// An optional [blessingTextOverride] replaces the narrative flavor string while keeping
  /// all mechanical buffs, tiers, and rolls strictly deterministic.
  static OracleRecord createCalibratedRecord({
    required String userId,
    required int d20Roll,
    DateTime? timestamp,
    String? blessingTextOverride,
  }) {
    final time = timestamp ?? DateTime.now();
    final String outcomeTier = determineOutcomeTier(d20Roll);
    final String blessingText;
    final String? buffGranted;

    if (d20Roll >= 20) {
      blessingText = 'NATURAL 20: World Arbiter grants +15% Aether Multiplier to all Sanctuary travelers!';
      buffGranted = '+15% Aether Multiplier (15m)';
    } else if (d20Roll >= 15) {
      blessingText = 'GREAT FORTUNE: Celestial Leylines resonate. +10% Quest Essence Affinity.';
      buffGranted = '+10% Quest Essence Boost (15m)';
    } else if (d20Roll >= 10) {
      blessingText = 'SACRED SHIELD: Divine Pentelic Aura protects your squad against shadow corruption.';
      buffGranted = '+10% Vitality Shield (15m)';
    } else if (d20Roll >= 2) {
      blessingText = 'ARBITER HARMONY: The Cardinal Scribes canonize your soul vessel rank.';
      buffGranted = '+5% Compute Focus (15m)';
    } else {
      blessingText = 'CRITICAL ANOMALY: Dimensional residue causes minor turbulence in resonance matrix.';
      buffGranted = '-5% Aether Turbulence (5m)';
    }

    return OracleRecord(
      id: 'oracle_${time.millisecondsSinceEpoch}_$d20Roll',
      userId: userId,
      d20Roll: d20Roll,
      outcomeTier: outcomeTier,
      blessingText: blessingTextOverride ?? blessingText,
      buffGranted: buffGranted,
      timestamp: time,
    );
  }
}

