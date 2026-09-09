import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'equipment_detail_sheet.dart';
import 'celestial_panel.dart';
import 'astrolabe_section_header.dart';

/// Celestial Astrolabe Equipment Slots Pedestal Widget with Responsive Layout.
class EquipmentSlotsWidget extends ConsumerWidget {
  const EquipmentSlotsWidget({super.key});

  Color _getRarityColor(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.sovereign:
        return const Color(0xFF6E473B);
      case EquipmentRarity.celestial:
        return const Color(0xFFA78D78);
      case EquipmentRarity.rare:
        return const Color(0xFF007791);
      case EquipmentRarity.common:
      default:
        return const Color(0xFFBEB5A9);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gearList = ref.watch(equippedGearProvider);
    final List<String> standardSlots = ['WEAPON', 'ARMOR', 'RELIC', 'CHARM'];

    return CelestialPanel(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AstrolabeSectionHeader(
            title: 'EQUIPMENT & GEAR SLOTS',
            glyph: '⟐',
            fontSize: 11,
            letterSpacing: 1.2,
            trailing: Text(
              '${gearList.length}/4 EQUIPPED',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA78D78),
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;

              if (isCompact) {
                // 2x2 Grid for compact viewports (Honor X8 mobile)
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSlotItem(context, gearList, standardSlots[0])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSlotItem(context, gearList, standardSlots[1])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildSlotItem(context, gearList, standardSlots[2])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSlotItem(context, gearList, standardSlots[3])),
                      ],
                    ),
                  ],
                );
              } else {
                // 4-in-a-row for standard & wide viewports
                return Row(
                  children: standardSlots.map((slot) {
                    return Expanded(
                      child: _buildSlotItem(context, gearList, slot),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlotItem(BuildContext context, List<EquippedGearItem> gearList, String slot) {
    final item = gearList.cast<EquippedGearItem?>().firstWhere(
          (g) => g?.slot == slot,
          orElse: () => null,
        );
    return _buildSlot(context, slot: slot, item: item);
  }

  Widget _buildSlot(BuildContext context, {required String slot, required EquippedGearItem? item}) {
    final hasItem = item != null;
    final rarityColor = hasItem ? _getRarityColor(item.rarity) : const Color(0xFFBEB5A9);

    return Semantics(
      label: hasItem ? '$slot slot: ${item.name}' : 'Empty $slot slot',
      button: true,
      child: InkWell(
        onTap: hasItem ? () => EquipmentDetailSheet.show(context, item) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasItem
                      ? const Color(0xFFE1D4C2).withValues(alpha: 0.45)
                      : const Color(0xFFE1D4C2).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: rarityColor,
                    width: hasItem ? 1.8 : 1.0,
                  ),
                  boxShadow: hasItem
                      ? [
                          BoxShadow(
                            color: rarityColor.withValues(alpha: 0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item?.icon ?? Icons.add_outlined,
                  color: hasItem ? const Color(0xFF6E473B) : const Color(0xFFBEB5A9),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8,
                  color: Color(0xFF6E473B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item?.name ?? 'Empty',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 9,
                  color: hasItem ? const Color(0xFF291C0E) : const Color(0xFFBEB5A9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
