import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../screens/descent_screen.dart';

class QuestDecreeWidget extends ConsumerWidget {
  const QuestDecreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = ref.watch(activeQuestProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest Header Row
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Color(0xFF6E473B), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'WORLD ARBITER QUEST DECREE',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E473B),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (quest.isUrgent) ...[
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
                const SizedBox(width: 4),
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
          const SizedBox(height: 10),

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

          // Quest Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TARGET SECTOR: ${quest.sectorName.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF291C0E),
                ),
              ),
              Text(
                '${(quest.progress * 100).toStringAsFixed(0)}% ANOMALY PURGED',
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E473B)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Rewards & Departure Button
          Row(
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
                  children: [
                    const Icon(Icons.stars_outlined, size: 12, color: Color(0xFF6E473B)),
                    const SizedBox(width: 4),
                    Text(
                      '+${quest.rewardEssence} ESSENCE',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D4C2).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_outlined, size: 12, color: Color(0xFF6E473B)),
                    const SizedBox(width: 4),
                    Text(
                      '+${quest.rewardLaurels} LAURELS',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Depart Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                icon: const Icon(Icons.explore, size: 14),
                label: const Text(
                  'DEPART ON QUEST',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DescentScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
