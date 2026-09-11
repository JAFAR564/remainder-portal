import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_item_model.dart';
import '../providers/sovereign_provider.dart';
import 'equipment_detail_sheet.dart';
import 'relic_vault_sheet.dart';
import 'celestial_panel.dart';
import 'astrolabe_section_header.dart';

/// Celestial Astrolabe Equipment Slots Pedestal Widget backed by persistent SQLite Relic Vault.
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
    final vaultAsync = ref.watch(activeRelicVaultProvider);
    final vaultState = vaultAsync.valueOrNull;
    final equippedItems = vaultState?.equippedItems ?? [];
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
            trailing: InkWell(
              onTap: () => RelicVaultSheet.show(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '${equippedItems.length}/4 EQUIPPED • VAULT ↗',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA78D78),
                  ),
                ),
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
                        Expanded(child: _buildSlotItem(context, vaultState, standardSlots[0])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSlotItem(context, vaultState, standardSlots[1])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildSlotItem(context, vaultState, standardSlots[2])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSlotItem(context, vaultState, standardSlots[3])),
                      ],
                    ),
                  ],
                );
              } else {
                // 4-in-a-row for standard & wide viewports
                return Row(
                  children: standardSlots.map((slot) {
                    return Expanded(
                      child: _buildSlotItem(context, vaultState, slot),
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

  Widget _buildSlotItem(BuildContext context, RelicVaultState? vaultState, String slot) {
    final item = vaultState?.equippedForSlot(slot);
    return _buildSlot(context, slot: slot, item: item);
  }

  Widget _buildSlot(BuildContext context, {required String slot, required EquipmentItemModel? item}) {
    final hasItem = item != null;
    final rarityColor = hasItem ? _getRarityColor(item.rarity) : const Color(0xFFBEB5A9);

    return Semantics(
      label: hasItem
          ? '$slot slot: ${item.name}${item.upgradeLevel > 0 ? " +${item.upgradeLevel}" : ""}'
          : 'Empty $slot slot. Tap to open Imperial Vault.',
      button: true,
      child: InkWell(
        onTap: () {
          if (hasItem) {
            EquipmentDetailSheet.show(context, item);
          } else {
            RelicVaultSheet.show(context, slotFilter: slot);
          }
        },
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
                  item != null ? item.iconData : Icons.add_outlined,
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
                item != null
                    ? (item.upgradeLevel > 0 ? '${item.name} +${item.upgradeLevel}' : item.name)
                    : 'Empty',
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
