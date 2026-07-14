import '../../data/models/character_sheet.dart';

class CalculateProgression {
  // Evaluates stat growth and attribute updates based on earned XP
  CharacterSheet processXpGain(CharacterSheet currentStats, int xpGained) {
    if (xpGained <= 0) return currentStats;

    // Progression logic: every 100 XP grants 1 attribute point to distribute
    // In our simplified automation, we distribute points across attributes sequentially
    int pointsToDistribute = xpGained ~/ 100;
    
    int newCompute = currentStats.computePower;
    int newShield = currentStats.shieldIntegrity;
    int newEnergy = currentStats.energyReserve;

    for (int i = 0; i < pointsToDistribute; i++) {
      int mod = i % 3;
      if (mod == 0) {
        newCompute += 1;
      } else if (mod == 1) {
        newShield += 1;
      } else {
        newEnergy += 1;
      }
    }

    return CharacterSheet(
      computePower: newCompute,
      shieldIntegrity: newShield,
      energyReserve: newEnergy,
    );
  }
}
