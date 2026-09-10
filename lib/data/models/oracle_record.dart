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
}
