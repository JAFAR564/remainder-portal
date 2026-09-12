import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sovereign_repository.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';
import '../screens/descent_screen.dart';
import 'celestial_panel.dart';
import 'quest_decree_sheet.dart';

/// Imperial Parchment World Arbiter Quest Decree Widget with Flex-Safe Responsive Layout.
class QuestDecreeWidget extends ConsumerWidget {
  const QuestDecreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(utrcsCharacterProvider);
    final userId = character?.id ?? 'utrcs_default_player';
    final questStateAsync = ref.watch(activeQuestDecreeProvider);

    final quest = questStateAsync.valueOrNull?.primaryQuest ??
        SovereignRepository.defaultStarterQuests(userId).first;

    return CelestialPanel(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest Header Row with DECREES ↗ button
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Color(0xFF6E473B), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  key: const Key('quest_decree_header'),
                  onTap: () => QuestDecreeSheet.show(context),
                  child: const Text(
                    'WORLD ARBITER QUEST DECREE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                key: const Key('open_decrees_sheet'),
                onTap: () => QuestDecreeSheet.show(context),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'DECREES ↗',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weaving status banner
          if (questStateAsync.valueOrNull?.isWeaving == true) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6E473B)),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'World Arbiter is weaving celestial decree (Llama 3.2)...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        color: Color(0xFF6E473B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Status & Difficulty Badges Wrap (Responsive and Flex-Safe)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (quest.isClaimed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF6E473B)),
                  ),
                  child: const Text(
                    'FULFILLED',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: Color(0xFF6E473B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (quest.isCompleted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF291C0E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF291C0E)),
                  ),
                  child: const Text(
                    'READY',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: Color(0xFF291C0E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (quest.isUrgent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF6E473B)),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: Color(0xFF6E473B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA78D78).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFA78D78)),
                ),
                child: Text(
                  quest.difficulty,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    color: Color(0xFF291C0E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quest Title
          Text(
            'QUEST: ${quest.title}',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF291C0E),
            ),
          ),
          const SizedBox(height: 4),

          // Decree Text
          Text(
            quest.decreeText,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6E473B), height: 1.3),
          ),
          const SizedBox(height: 10),

          // Target Sector & Anomaly Purge Track (Fixes Defect 3: 49px overflow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TARGET SECTOR: ${quest.sectorName.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF291C0E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                quest.isClaimed
                    ? 'REWARDS CLAIMED'
                    : quest.isCompleted
                        ? '100% ANOMALY PURGED'
                        : '${(quest.progress * 100).toStringAsFixed(0)}% ANOMALY PURGED',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E473B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quest.progress,
              backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                quest.isClaimed ? const Color(0xFFA78D78) : const Color(0xFF6E473B),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Rewards & Departure Button Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Rewards Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D4C2).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Color(0xFF6E473B), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.rewardEssence} ESSENCE',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E473B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D4C2).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, color: Color(0xFFA78D78), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${quest.rewardLaurels} LAURELS',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF291C0E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Action CTA Button
              if (quest.isCompleted && !quest.isClaimed) ...[
                ElevatedButton.icon(
                  key: const Key('quest_claim_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E473B),
                    foregroundColor: const Color(0xFFE1D4C2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.card_giftcard, size: 14),
                  label: const Text(
                    'CLAIM REWARDS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final success = await ref
                        .read(questDecreeProvider(userId).notifier)
                        .claimReward(questId: quest.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Decree Fulfilled! Credited +${quest.rewardEssence} Essence & +${quest.rewardLaurels} Laurels.'
                                : 'Decree rewards already claimed.',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                          backgroundColor: const Color(0xFF6E473B),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ] else if (quest.isClaimed) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('quest_fulfilled_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6E473B),
                        side: const BorderSide(color: Color(0xFF6E473B)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 14),
                      label: const Text(
                        'FULFILLED',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => QuestDecreeSheet.show(context),
                    ),
                    ElevatedButton.icon(
                      key: const Key('generate_new_decree_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E473B),
                        foregroundColor: const Color(0xFFE1D4C2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: const Text(
                        'WEAVE DECREE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final operatorClass = character?.role.tacticalArchetype ?? 'Vanguard';
                        await ref.read(questDecreeProvider(userId).notifier).generateNewDecree(
                          sectorId: 'sector_celestial_abyss_12',
                          sectorName: 'Celestial Abyss (Sector 12)',
                          difficulty: 'A-RANK',
                          operatorClass: operatorClass,
                        );
                      },
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton.icon(
                  key: const Key('quest_depart_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E473B),
                    foregroundColor: const Color(0xFFE1D4C2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 1,
                  ),
                  icon: const Icon(Icons.explore, size: 14),
                  label: const Text(
                    'DEPART ON QUEST',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DescentScreen()),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
