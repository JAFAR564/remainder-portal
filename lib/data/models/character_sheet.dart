class CharacterSheet {
  final int computePower; // Maps to Mana Focus in High Fantasy / Processor in Cyberpunk
  final int shieldIntegrity; // Maps to Firewall in Cyberpunk
  final int energyReserve; // Maps to Spiritual Essence / Battery capacity

  CharacterSheet({
    required this.computePower,
    required this.shieldIntegrity,
    required this.energyReserve,
  });

  factory CharacterSheet.fromJson(Map<String, dynamic> json) {
    return CharacterSheet(
      computePower: (json['Compute_Power'] ?? json['computePower']) as int? ?? 0,
      shieldIntegrity: (json['Shield_Integrity'] ?? json['shieldIntegrity']) as int? ?? 0,
      energyReserve: (json['Energy_Reserve'] ?? json['energyReserve']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Compute_Power': computePower,
      'Shield_Integrity': shieldIntegrity,
      'Energy_Reserve': energyReserve,
    };
  }

  CharacterSheet copyWith({
    int? computePower,
    int? shieldIntegrity,
    int? energyReserve,
  }) {
    return CharacterSheet(
      computePower: computePower ?? this.computePower,
      shieldIntegrity: shieldIntegrity ?? this.shieldIntegrity,
      energyReserve: energyReserve ?? this.energyReserve,
    );
  }

  @override
  String toString() {
    return 'CharacterSheet(Compute_Power: $computePower, Shield_Integrity: $shieldIntegrity, Energy_Reserve: $energyReserve)';
  }
}
