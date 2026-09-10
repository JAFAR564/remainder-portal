/// Represents the player's persistent wallet, currencies, and progression telemetry.
class PlayerWallet {
  final String userId;
  final int essenceBalance;
  final int laurelBalance;
  final int experiencePoints;
  final int currentLevel;
  final int unallocatedAttributePoints;
  final DateTime lastUpdated;

  const PlayerWallet({
    required this.userId,
    this.essenceBalance = 1000,
    this.laurelBalance = 150,
    this.experiencePoints = 8800,
    this.currentLevel = 88,
    this.unallocatedAttributePoints = 0,
    required this.lastUpdated,
  });

  /// Calculates the next level threshold: NextXP = Level^2 * 100
  int get nextLevelThreshold => currentLevel * currentLevel * 100;

  /// Calculates the previous level threshold: PrevXP = (Level - 1)^2 * 100
  int get currentLevelBaseXp => (currentLevel - 1) * (currentLevel - 1) * 100;

  /// Progress fraction towards next level (0.0 to 1.0)
  double get levelProgress {
    final range = nextLevelThreshold - currentLevelBaseXp;
    if (range <= 0) return 1.0;
    final progressInTier = experiencePoints - currentLevelBaseXp;
    return (progressInTier / range).clamp(0.0, 1.0);
  }

  PlayerWallet copyWith({
    String? userId,
    int? essenceBalance,
    int? laurelBalance,
    int? experiencePoints,
    int? currentLevel,
    int? unallocatedAttributePoints,
    DateTime? lastUpdated,
  }) {
    return PlayerWallet(
      userId: userId ?? this.userId,
      essenceBalance: essenceBalance ?? this.essenceBalance,
      laurelBalance: laurelBalance ?? this.laurelBalance,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      currentLevel: currentLevel ?? this.currentLevel,
      unallocatedAttributePoints: unallocatedAttributePoints ?? this.unallocatedAttributePoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'essence_balance': essenceBalance,
      'laurel_balance': laurelBalance,
      'experience_points': experiencePoints,
      'current_level': currentLevel,
      'unallocated_attribute_points': unallocatedAttributePoints,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory PlayerWallet.fromJson(Map<String, dynamic> json) {
    return PlayerWallet(
      userId: json['user_id'] as String,
      essenceBalance: (json['essence_balance'] as num?)?.toInt() ?? 1000,
      laurelBalance: (json['laurel_balance'] as num?)?.toInt() ?? 150,
      experiencePoints: (json['experience_points'] as num?)?.toInt() ?? 8800,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 88,
      unallocatedAttributePoints: (json['unallocated_attribute_points'] as num?)?.toInt() ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_updated'] as int)
          : DateTime.now(),
    );
  }
}
