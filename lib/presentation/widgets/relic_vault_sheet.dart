import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/equipment_item_model.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

/// Extension to map string iconName to Material IconData cleanly
extension EquipmentIconDataX on EquipmentItemModel {
  IconData get iconData {
    switch (iconName.toLowerCase()) {
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
}

/// Celestial Astrolabe Imperial Relic Vault Modal Sheet
class RelicVaultSheet extends ConsumerStatefulWidget {
  final String? slotFilter;

  const RelicVaultSheet({super.key, this.slotFilter});

  static void show(BuildContext context, {String? slotFilter}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RelicVaultSheet(slotFilter: slotFilter),
    );
  }

  @override
  ConsumerState<RelicVaultSheet> createState() => _RelicVaultSheetState();
}

class _RelicVaultSheetState extends ConsumerState<RelicVaultSheet> {
  late String? _activeSlot;

  @override
  void initState() {
    super.initState();
    _activeSlot = widget.slotFilter;
  }

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

  String _getRarityLabel(EquipmentRarity rarity) {
    switch (rarity) {
      case EquipmentRarity.sovereign:
        return 'SOVEREIGN';
      case EquipmentRarity.celestial:
        return 'CELESTIAL';
      case EquipmentRarity.rare:
        return 'RARE';
      case EquipmentRarity.common:
      default:
        return 'COMMON';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaultAsync = ref.watch(activeRelicVaultProvider);
    final vaultState = vaultAsync.valueOrNull;
    final allVaultItems = vaultState?.vaultItems ?? [];

    final filteredItems = _activeSlot == null
        ? allVaultItems
        : allVaultItems.where((i) => i.slot.toUpperCase() == _activeSlot!.toUpperCase()).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
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
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFA78D78),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sheet Header
            Row(
              children: [
                const Text('✦ ', style: TextStyle(color: Color(0xFF6E473B), fontSize: 16)),
                Expanded(
                  child: Text(
                    _activeSlot != null
                        ? 'IMPERIAL RELIC VAULT • $_activeSlot'
                        : 'IMPERIAL RELIC VAULT',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  '${filteredItems.length} STORED',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA78D78),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _activeSlot != null
                  ? 'Select an unequipped relic to place onto the active $_activeSlot pedestal.'
                  : 'Manage persistent equipment stored in the Sovereign Vault.',
              style: const TextStyle(fontSize: 10, color: Color(0xFF6E473B)),
            ),
            const SizedBox(height: 12),

            // Slot Filter Chips if no fixed slot filter
            if (widget.slotFilter == null) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'WEAPON', 'ARMOR', 'RELIC', 'CHARM'].map((slot) {
                    final isSelected = (_activeSlot == null && slot == 'ALL') || _activeSlot == slot;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(slot, style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFFAF7F0) : const Color(0xFF6E473B))),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6E473B),
                        backgroundColor: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                        onSelected: (_) {
                          setState(() {
                            _activeSlot = slot == 'ALL' ? null : slot;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const Divider(color: Color(0xFFBEB5A9), height: 1),
            const SizedBox(height: 10),

            // Relic Items List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFFA78D78)),
                          const SizedBox(height: 10),
                          Text(
                            _activeSlot != null
                                ? 'No unequipped $_activeSlot relics in vault.'
                                : 'Imperial Vault is empty.',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF291C0E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Unequip active gear or clear Descent quests to store relics here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF6E473B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final rarityColor = _getRarityColor(item.rarity);
                        final rarityLabel = _getRarityLabel(item.rarity);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6E473B).withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: rarityColor, width: 1.6),
                                    ),
                                    child: Icon(item.iconData, color: rarityColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontFamily: 'serif',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF291C0E),
                                                ),
                                              ),
                                            ),
                                            if (item.upgradeLevel > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF6E473B),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '+${item.upgradeLevel}',
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE1D4C2),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              rarityLabel,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: rarityColor,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '• SLOT: ${item.slot}',
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 8,
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
                              const SizedBox(height: 8),
                              Text(
                                item.statBonus,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291C0E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF6E473B),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6E473B),
                                    foregroundColor: const Color(0xFFE1D4C2),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final character = ref.read(utrcsCharacterProvider);
                                    final userId = character?.id ?? 'utrcs_default_player';
                                    await ref.read(relicVaultProvider(userId).notifier).equipItem(
                                      itemId: item.id,
                                      slot: item.slot,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'EQUIP TO ${item.slot}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
