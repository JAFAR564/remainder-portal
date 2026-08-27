import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expedition_provider.dart';
import '../providers/game_provider.dart';
import '../providers/trust_provider.dart';
import '../../data/services/p2p_squad_relay_service.dart';
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFA78D78), width: 1.8),
        ),
        title: Text(
          result.statusTitle,
          style: const TextStyle(
            color: Color(0xFF6E473B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        content: Text(
          'Score: ${result.finalScore} (Base D20: ${result.baseD20}, Stats: +${result.totalStatContribution.toStringAsFixed(1)}, Trust: +${result.totalTrustBonus})\n\n${result.narrativeDescription}',
          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E473B),
              foregroundColor: const Color(0xFFE1D4C2),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ref.watch(expeditionProvider);
    final profile = ref.watch(playerProfileProvider);
    final relayService = ref.watch(p2pSquadRelayProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'SANCTUARY SQUAD MATRIX',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF6E473B),
            fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: relayService.isOnline
                      ? const Color(0xFF6E473B).withValues(alpha: 0.1)
                      : const Color(0xFFA78D78).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: relayService.isOnline ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                  ),
                ),
                child: Text(
                  relayService.isOnline ? 'RELAY: ONLINE' : 'RELAY: OFFLINE (${relayService.queuedEventCount})',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: relayService.isOnline ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expedition == null) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_add, color: Color(0xFF6E473B), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'NO ACTIVE SANCTUARY SQUAD',
                          style: TextStyle(
                            color: Color(0xFF291C0E),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Initialize a tactical squad to combine traveler stats for cooperative skill checks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6E473B), fontSize: 11),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E473B),
                            foregroundColor: const Color(0xFFE1D4C2),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (profile != null) {
                              ref.read(expeditionProvider.notifier).createExpedition(
                                    title: 'Aether Spire Raid',
                                    leaderId: profile.id,
                                    leaderName: profile.name,
                                    sectorId: profile.activeSector,
                                  );
                            }
                          },
                          child: const Text('INITIALIZE SQUAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                )
              ] else ...[
                // Squad Header Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expedition.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6E473B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SANCTUARY: ${expedition.sectorId} | ROSTER: ${expedition.members.length}/5',
                              style: const TextStyle(color: Color(0xFF291C0E), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E473B),
                          foregroundColor: const Color(0xFFE1D4C2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                        onPressed: () {
                          final newMemberId = 'user_${DateTime.now().millisecondsSinceEpoch}';
                          ref.read(expeditionProvider.notifier).addMember(
                            ExpeditionMemberModel(
                              userId: newMemberId,
                              userName: 'Ally Specialist',
                              assignedRole: 'Aether Sorcerer',
                              primaryStat: 12,
                              isSpecialist: true,
                              trustScore: 0.9,
                            ),
                          );
                        },
                        child: const Text('+ INVITE ALLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Squad Roster List
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SQUAD ROSTER & ROLES',
                      style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    Text(
                      'LIVE P2P SYNCED',
                      style: TextStyle(color: Color(0xFF291C0E), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ],
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6E473B).withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          m.userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFF6E473B)),
                                        ),
                                        child: Text(
                                          m.assignedRole,
                                          style: const TextStyle(color: Color(0xFF6E473B), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stat: ${m.primaryStat} | Mutual Trust: ${(m.trustScore * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_up_outlined, color: Color(0xFF6E473B), size: 18),
                              tooltip: 'Endorse Squad Member',
                              onPressed: () {
                                ref.read(expeditionProvider.notifier).updateMemberTrust(m.userId, m.trustScore + 0.05);
                                ref.read(trustProvider.notifier).addEndorsement(
                                  giverId: profile?.id ?? 'local',
                                  receiverId: m.userId,
                                  vector: TrustVector.vanguard,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Activity & Timeline Stream Log
                const Text(
                  'SQUAD EVENT TIMELINE',
                  style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 6),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                    ),
                    child: ListView.builder(
                      itemCount: expedition.squadLogs.length,
                      itemBuilder: (context, index) {
                        final log = expedition.squadLogs[index];
                        Color logColor = const Color(0xFF291C0E);
                        if (log.startsWith('[JOIN]')) logColor = const Color(0xFF6E473B);
                        if (log.startsWith('[COOP CHECK]')) logColor = const Color(0xFFA78D78);
                        if (log.startsWith('[SYSTEM]')) logColor = const Color(0xFF291C0E);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            log,
                            style: TextStyle(color: logColor, fontSize: 10, fontFamily: 'monospace'),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

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
                        style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: '> enter squad action command...',
                          hintStyle: const TextStyle(color: Color(0xFFBEB5A9), fontSize: 12),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFA78D78)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E473B),
                        foregroundColor: const Color(0xFFE1D4C2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _onPerformCoopCheck,
                      child: const Text('COOP CHECK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
