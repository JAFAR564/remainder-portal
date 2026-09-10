enum EquipmentRarity { common, rare, celestial, sovereign }

/// Persistent domain model for gear items in active slots or in the Imperial Vault.
class EquipmentItemModel {
  final String id;
  final String userId;
  final String slot; // 'WEAPON', 'ARMOR', 'RELIC', 'CHARM'
  final String name;
  final EquipmentRarity rarity;
  final String statBonus;
  final String description;
  final String iconName; // e.g. 'colorize', 'shield', 'auto_awesome', 'diamond_outlined'
  final int upgradeLevel;
  final bool isEquipped;
  final DateTime acquiredAt;

  const EquipmentItemModel({
    required this.id,
    required this.userId,
    required this.slot,
    required this.name,
    required this.rarity,
    required this.statBonus,
    required this.description,
    required this.iconName,
    this.upgradeLevel = 0,
    this.isEquipped = false,
    required this.acquiredAt,
  });

  EquipmentItemModel copyWith({
    String? id,
    String? userId,
    String? slot,
    String? name,
    EquipmentRarity? rarity,
    String? statBonus,
    String? description,
    String? iconName,
    int? upgradeLevel,
    bool? isEquipped,
    DateTime? acquiredAt,
  }) {
    return EquipmentItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      slot: slot ?? this.slot,
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      statBonus: statBonus ?? this.statBonus,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      isEquipped: isEquipped ?? this.isEquipped,
      acquiredAt: acquiredAt ?? this.acquiredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'slot': slot,
      'name': name,
      'rarity': rarity.name,
      'stat_bonus': statBonus,
      'description': description,
      'icon_name': iconName,
      'upgrade_level': upgradeLevel,
      'is_equipped': isEquipped ? 1 : 0,
      'acquired_at': acquiredAt.millisecondsSinceEpoch,
    };
  }

  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) {
    return EquipmentItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      slot: json['slot'] as String,
      name: json['name'] as String,
      rarity: EquipmentRarity.values.firstWhere(
        (r) => r.name.toLowerCase() == (json['rarity'] as String).toLowerCase(),
        orElse: () => EquipmentRarity.common,
      ),
      statBonus: json['stat_bonus'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String? ?? 'shield',
      upgradeLevel: (json['upgrade_level'] as num?)?.toInt() ?? 0,
      isEquipped: json['is_equipped'] == 1 || json['is_equipped'] == true,
      acquiredAt: json['acquired_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['acquired_at'] as int)
          : DateTime.now(),
    );
  }
}
