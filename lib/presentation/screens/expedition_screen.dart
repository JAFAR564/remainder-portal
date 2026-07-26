import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expedition_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/crt_overlay.dart';
import '../widgets/trust_badge_widget.dart';

class ExpeditionScreen extends ConsumerStatefulWidget {
  const ExpeditionScreen({super.key});

  @override
  ConsumerState<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends ConsumerState<ExpeditionScreen> {
  final _actionController = TextEditingController();

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  void _onPerformCoopCheck() {
    final text = _actionController.text.trim();
    if (text.isEmpty) return;

    final result = ref.read(expeditionProvider.notifier).performSquadSkillCheck(text);
    _actionController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161520),
        title: Text(
          result.statusTitle,
          style: const TextStyle(
            color: Color(0xFFE53170),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        content: Text(
          'Score: ${result.finalScore} (Base D20: ${result.baseD20}, Stats: +${result.totalStatContribution.toStringAsFixed(1)}, Trust: +${result.totalTrustBonus})\n\n${result.narrativeDescription}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGE', style: TextStyle(color: Color(0xFFFF8E3C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ref.watch(expeditionProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'EXPEDITION SQUAD MATRIX',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161520),
        elevation: 0,
        centerTitle: true,
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expedition == null) ...[
                  Center(
                    child: Card(
                      color: const Color(0xFF161520),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE53170)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_add, color: Color(0xFFE53170), size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'NO ACTIVE EXPEDITION SQUAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Initialize a tactical squad to combine player stats for cooperative skill checks.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53170),
                              ),
                              onPressed: () {
                                if (profile != null) {
                                  ref.read(expeditionProvider.notifier).createExpedition(
                                        title: 'Bastion Gate Raid',
                                        leaderId: profile.id,
                                        leaderName: profile.name,
                                        sectorId: profile.activeSector,
                                      );
                                }
                              },
                              child: const Text('INITIALIZE SQUAD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ] else ...[
                  // Squad Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161520),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE53170).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expedition.title.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SECTOR: ${expedition.sectorId} | ROSTER: ${expedition.members.length}/5',
                              style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
                          onPressed: () {
                            ref.read(expeditionProvider.notifier).addMember(
                              ExpeditionMemberModel(
                                userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                userName: 'Ally Specialist',
                                assignedRole: 'Cyber Hacker',
                                primaryStat: 12,
                                isSpecialist: true,
                                trustScore: 0.9,
                              ),
                            );
                          },
                          child: const Text('+ INVITE ALLY', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Squad Roster List
                  const Text(
                    'SQUAD ROSTER & ROLES',
                    style: TextStyle(color: Color(0xFFFF8E3C), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: expedition.members.length,
                      itemBuilder: (context, index) {
                        final m = expedition.members[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0910),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(m.userName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53170).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(m.assignedRole, style: const TextStyle(color: Color(0xFFE53170), fontSize: 9, fontFamily: 'monospace')),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stat: ${m.primaryStat} | Mutual Trust: ${(m.trustScore * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Trust Aura Widget
                  if (profile != null) ...[
                    TrustBadgeWidget(
                      targetUserId: profile.id,
                      targetUserName: profile.name,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cooperative Action Prompt Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _actionController,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '> enter squad action command...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF161520),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53170)),
                        onPressed: _onPerformCoopCheck,
                        child: const Text('COOP CHECK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
