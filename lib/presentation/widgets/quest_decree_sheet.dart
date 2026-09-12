import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quest_decree_model.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

/// Imperial Parchment Modal Sheet for viewing and selecting World Arbiter Quest Decrees.
class QuestDecreeSheet extends ConsumerStatefulWidget {
  const QuestDecreeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuestDecreeSheet(),
    );
  }

  @override
  ConsumerState<QuestDecreeSheet> createState() => _QuestDecreeSheetState();
}

class _QuestDecreeSheetState extends ConsumerState<QuestDecreeSheet> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(utrcsCharacterProvider);
    final userId = character?.id ?? 'utrcs_default_player';
    final decreesAsync = ref.watch(questDecreeProvider(userId));

    return decreesAsync.when(
      loading: () => Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6E473B)),
        ),
      ),
      error: (e, st) => Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Center(
          child: Text(
            'Failed to load Imperial Decrees: $e',
            style: const TextStyle(color: Color(0xFF6E473B), fontSize: 12),
          ),
        ),
      ),
      data: (decreeState) {
        final allDecrees = decreeState.decrees;
        final filteredDecrees = allDecrees.where((q) {
          if (_filter == 'ACTIVE') return !q.isClaimed && !q.isCompleted;
          if (_filter == 'COMPLETED') return q.isCompleted && !q.isClaimed;
          if (_filter == 'CLAIMED') return q.isClaimed;
          return true;
        }).toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                // Handle bar
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
                    const Expanded(
                      child: Text(
                        'WORLD ARBITER DECREES',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6E473B),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredDecrees.length} PROCLAMATIONS',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      key: const Key('close_decrees_sheet'),
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.close, size: 18, color: Color(0xFF6E473B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review active mission directives, track sectors, and claim imperial bounty settlements.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6E473B)),
                ),
                const SizedBox(height: 12),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'ACTIVE', 'COMPLETED', 'CLAIMED'].map((filter) {
                      final isSelected = _filter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFFAF7F0) : const Color(0xFF6E473B),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF6E473B),
                          backgroundColor: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                          ),
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Weave New Decree Button / Weaving Banner
                if (decreeState.isWeaving) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6E473B)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Arbiter is weaving celestial decree (Llama 3.2)...',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Color(0xFF6E473B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextButton.icon(
                        key: const Key('generate_new_decree_button'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6E473B),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 14),
                        label: const Text(
                          'WEAVE ARBITER DECREE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final operatorClass = character?.roleLayer.roleArchetype ?? 'Vanguard';
                          await ref.read(questDecreeProvider(userId).notifier).generateNewDecree(
                            sectorId: 'sector_celestial_abyss_12',
                            sectorName: 'Celestial Abyss (Sector 12)',
                            difficulty: 'A-RANK',
                            operatorClass: operatorClass,
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Decrees List
                Expanded(
                  child: filteredDecrees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assignment_outlined, size: 40, color: const Color(0xFFBEB5A9).withValues(alpha: 0.8)),
                              const SizedBox(height: 8),
                              Text(
                                'No decrees matching $_filter category.',
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFBEB5A9)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredDecrees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final decree = filteredDecrees[index];
                            final isTracked = decree.id == decreeState.primaryQuest?.id;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF7F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isTracked ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                                  width: isTracked ? 1.6 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Card Top Badges Row
                                  Row(
                                    children: [
                                      if (decree.isClaimed)
                                        _buildBadge('FULFILLED', const Color(0xFF6E473B))
                                      else if (decree.isCompleted)
                                        _buildBadge('COMPLETED', const Color(0xFF291C0E))
                                      else if (decree.isUrgent)
                                        _buildBadge('URGENT', const Color(0xFF6E473B)),
                                      const SizedBox(width: 4),
                                      _buildBadge(decree.difficulty, const Color(0xFFA78D78)),
                                      const Spacer(),
                                      if (isTracked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'TRACKED ✦',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6E473B),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Title
                                  Text(
                                    decree.title,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF291C0E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    decree.decreeText,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6E473B),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Progress Bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'SECTOR: ${decree.sectorName.toUpperCase()}',
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 8.5, color: Color(0xFF291C0E)),
                                      ),
                                      Text(
                                        decree.isClaimed
                                            ? 'REWARDS CLAIMED'
                                            : decree.isCompleted
                                                ? '100% PURGED'
                                                : '${(decree.progress * 100).toStringAsFixed(0)}% PURGED',
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: decree.progress,
                                      backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E473B)),
                                      minHeight: 5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Bottom Row: Rewards & Actions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Rewards
                                      Row(
                                        children: [
                                          const Icon(Icons.stars, color: Color(0xFF6E473B), size: 13),
                                          const SizedBox(width: 3),
                                          Text(
                                            '+${decree.rewardEssence}',
                                            style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.workspace_premium, color: Color(0xFFA78D78), size: 13),
                                          const SizedBox(width: 3),
                                          Text(
                                            '+${decree.rewardLaurels}',
                                            style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                                          ),
                                        ],
                                      ),

                                      // Button Actions
                                      if (decree.isCompleted && !decree.isClaimed) ...[
                                        ElevatedButton(
                                          key: Key('sheet_claim_${decree.id}'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6E473B),
                                            foregroundColor: const Color(0xFFE1D4C2),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          onPressed: () async {
                                            final success = await ref
                                                .read(questDecreeProvider(userId).notifier)
                                                .claimReward(questId: decree.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    success
                                                        ? 'Decree Fulfilled! Credited +${decree.rewardEssence} Essence & +${decree.rewardLaurels} Laurels.'
                                                        : 'Rewards already claimed.',
                                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                                  ),
                                                  backgroundColor: const Color(0xFF6E473B),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'CLAIM REWARDS',
                                            style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ] else if (!decree.isClaimed && !isTracked) ...[
                                        OutlinedButton(
                                          key: Key('sheet_track_${decree.id}'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF6E473B),
                                            side: const BorderSide(color: Color(0xFF6E473B)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          onPressed: () {
                                            ref.read(questDecreeProvider(userId).notifier).selectQuest(decree.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'TRACK DECREE',
                                            style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
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
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
