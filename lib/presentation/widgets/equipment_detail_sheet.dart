import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_item_model.dart';
import '../providers/game_provider.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

class EquipmentDetailSheet extends ConsumerWidget {
  final EquipmentItemModel item;

  const EquipmentDetailSheet({
    super.key,
    required this.item,
  });

  static void show(BuildContext context, dynamic item) {
    final model = item is EquipmentItemModel
        ? item
        : (item is EquippedGearItem
            ? EquipmentItemModel(
                id: item.id,
                userId: 'utrcs_default_player',
                slot: item.slot,
                name: item.name,
                rarity: item.rarity,
                statBonus: item.statBonus,
                description: item.description,
                iconName: _iconToName(item.icon),
                upgradeLevel: 0,
                isEquipped: true,
                acquiredAt: DateTime.now(),
              )
            : item as EquipmentItemModel);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EquipmentDetailSheet(item: model),
    );
  }

  static String _iconToName(IconData icon) {
    if (icon == Icons.colorize) return 'colorize';
    if (icon == Icons.shield) return 'shield';
    if (icon == Icons.auto_awesome) return 'auto_awesome';
    if (icon == Icons.diamond_outlined) return 'diamond_outlined';
    return 'shield';
  }

  IconData get _iconData {
    switch (item.iconName.toLowerCase()) {
      case 'colorize':
        return Icons.colorize;
      case 'shield':
        return Icons.shield;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'diamond_outlined':
      case 'diamond':
        return Icons.diamond_outlined;
      default:
        return Icons.shield;
    }
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
    final upgradeCost = 150 * (item.upgradeLevel + 1);

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
        child: SingleChildScrollView(
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
                    child: Icon(_iconData, color: rarityColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291C0E),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            if (item.upgradeLevel > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6E473B),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${item.upgradeLevel}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE1D4C2),
                                  ),
                                ),
                              ),
                          ],
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
                      item.upgradeLevel > 0
                          ? '${item.statBonus} (+${item.upgradeLevel * 4} Refined)'
                          : item.statBonus,
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

              // Enhancement Action Button (Thread B-2)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1D4C2),
                    foregroundColor: const Color(0xFF6E473B),
                    side: const BorderSide(color: Color(0xFFA78D78), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.bolt, size: 16, color: Color(0xFF6E473B)),
                  label: Text(
                    'ENHANCE RELIC (+1) • $upgradeCost ESSENCE',
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  onPressed: () async {
                    final character = ref.read(utrcsCharacterProvider);
                    final userId = character?.id ?? 'utrcs_default_player';
                    try {
                      final updated = await ref.read(relicVaultProvider(userId).notifier).upgradeItem(
                        itemId: item.id,
                        costEssence: upgradeCost,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF6E473B),
                            content: Text(
                              'Enhanced ${item.name} to +${updated.upgradeLevel}!',
                              style: const TextStyle(fontFamily: 'serif', color: Color(0xFFE1D4C2)),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF6E473B),
                            content: Text(
                              e.toString().replaceAll('StateError: ', '').replaceAll('Exception: ', ''),
                              style: const TextStyle(fontFamily: 'serif', color: Color(0xFFE1D4C2)),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Primary Slot Actions: EQUIPPED (ACTIVE) and UNEQUIP
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
                    onPressed: () async {
                      final character = ref.read(utrcsCharacterProvider);
                      final userId = character?.id ?? 'utrcs_default_player';
                      await ref.read(relicVaultProvider(userId).notifier).unequipItem(itemId: item.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF6E473B),
                            content: Text(
                              'Unequipped ${item.name} to the Imperial Vault.',
                              style: const TextStyle(fontFamily: 'serif', color: Color(0xFFE1D4C2)),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('UNEQUIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
