import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

class EquipmentDetailSheet extends ConsumerWidget {
  final EquippedGearItem item;

  const EquipmentDetailSheet({
    super.key,
    required this.item,
  });

  static void show(BuildContext context, EquippedGearItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EquipmentDetailSheet(item: item),
    );
  }

  Color _getRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.sovereign:
        return const Color(0xFF6E473B);
      case EquipmentRarity.celestial:
        return const Color(0xFFA78D78);
      case EquipmentRarity.rare:
        return const Color(0xFF291C0E);
      case EquipmentRarity.common:
      default:
        return const Color(0xFFBEB5A9);
    }
  }

  String _getRarityLabel(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.sovereign:
        return 'SOVEREIGN TIER';
      case EquipmentRarity.celestial:
        return 'CELESTIAL TIER';
      case EquipmentRarity.rare:
        return 'RARE TIER';
      case EquipmentRarity.common:
      default:
        return 'COMMON TIER';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = _getRarityColor(item.rarity);
    final rarityLabel = _getRarityLabel(item.rarity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFBEB5A9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header with Icon and Title
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: rarityColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: rarityColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: rarityColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF291C0E),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: rarityColor),
                            ),
                            child: Text(
                              rarityLabel,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: rarityColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SLOT: ${item.slot}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E473B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stat Attributes Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESONANCE STAT BONUSES',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.statBonus,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF291C0E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lore Flavor Text
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF291C0E),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E473B),
                      foregroundColor: const Color(0xFFE1D4C2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'EQUIPPED (ACTIVE)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E473B),
                    side: const BorderSide(color: Color(0xFFA78D78)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ref.read(equippedGearProvider.notifier).unequipItem(item.id);
                    Navigator.pop(context);
                  },
                  child: const Text('UNEQUIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
