/// Persistent domain model for World Arbiter Quest Decrees.
class QuestDecreeModel {
  final String id;
  final String userId;
  final String title;
  final String sectorId;
  final String sectorName;
  final String decreeText;
  final int rewardEssence;
  final int rewardLaurels;
  final double progress;
  final bool isUrgent;
  final bool isClaimed;
  final String difficulty;
  final DateTime createdAt;

  const QuestDecreeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.sectorId,
    required this.sectorName,
    required this.decreeText,
    required this.rewardEssence,
    required this.rewardLaurels,
    this.progress = 0.65,
    this.isUrgent = true,
    this.isClaimed = false,
    this.difficulty = 'S-RANK',
    required this.createdAt,
  });

  bool get isCompleted => progress >= 1.0;

  QuestDecreeModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? sectorId,
    String? sectorName,
    String? decreeText,
    int? rewardEssence,
    int? rewardLaurels,
    double? progress,
    bool? isUrgent,
    bool? isClaimed,
    String? difficulty,
    DateTime? createdAt,
  }) {
    return QuestDecreeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      sectorId: sectorId ?? this.sectorId,
      sectorName: sectorName ?? this.sectorName,
      decreeText: decreeText ?? this.decreeText,
      rewardEssence: rewardEssence ?? this.rewardEssence,
      rewardLaurels: rewardLaurels ?? this.rewardLaurels,
      progress: (progress ?? this.progress).clamp(0.0, 1.0),
      isUrgent: isUrgent ?? this.isUrgent,
      isClaimed: isClaimed ?? this.isClaimed,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'sector_id': sectorId,
      'sector_name': sectorName,
      'decree_text': decreeText,
      'reward_essence': rewardEssence,
      'reward_laurels': rewardLaurels,
      'progress': progress,
      'is_urgent': isUrgent ? 1 : 0,
      'is_claimed': isClaimed ? 1 : 0,
      'difficulty': difficulty,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory QuestDecreeModel.fromJson(Map<String, dynamic> json) {
    return QuestDecreeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      sectorId: json['sector_id'] as String,
      sectorName: json['sector_name'] as String,
      decreeText: json['decree_text'] as String,
      rewardEssence: (json['reward_essence'] as num?)?.toInt() ?? 750,
      rewardLaurels: (json['reward_laurels'] as num?)?.toInt() ?? 50,
      progress: ((json['progress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0),
      isUrgent: json['is_urgent'] == 1 || json['is_urgent'] == true,
      isClaimed: json['is_claimed'] == 1 || json['is_claimed'] == true,
      difficulty: json['difficulty'] as String? ?? 'S-RANK',
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : DateTime.now(),
    );
  }
}

/// Represents the deterministic outcome of an authoritative quest decree claim transaction.
class QuestClaimResult {
  final bool success;
  final String questId;
  final int baseEssence;
  final int creditedEssence;
  final int creditedLaurels;
  final int multiplierBasisPoints;
  final String? activeBuffTitle;

  const QuestClaimResult({
    required this.success,
    required this.questId,
    required this.baseEssence,
    required this.creditedEssence,
    required this.creditedLaurels,
    required this.multiplierBasisPoints,
    this.activeBuffTitle,
  });

  bool get hadBuffBoost => multiplierBasisPoints > 1000;
  int get bonusEssence => creditedEssence > baseEssence ? creditedEssence - baseEssence : 0;
}

