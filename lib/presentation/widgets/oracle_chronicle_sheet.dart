import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/oracle_record.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

/// Modal bottom sheet displaying the operator's persisted Divination Chronicle and active buffs.
class OracleChronicleSheet extends ConsumerWidget {
  const OracleChronicleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OracleChronicleSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(utrcsCharacterProvider);
    final userId = character?.id ?? 'utrcs_default_player';
    final oracleStateAsync = ref.watch(oracleBuffProvider(userId));

    return oracleStateAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6E473B)),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Center(
          child: Text(
            'Failed to read Divination Chronicle: $e',
            style: const TextStyle(color: Color(0xFF6E473B), fontSize: 12),
          ),
        ),
      ),
      data: (oracleState) {
        final history = oracleState.history;
        final activeBuffs = oracleState.activeBuffs;

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

                // Sheet Header Row
                Row(
                  children: [
                    const Text('✦ ', style: TextStyle(color: Color(0xFF6E473B), fontSize: 16)),
                    const Expanded(
                      child: Text(
                        'CHRONICLE OF DIVINATION',
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
                      '${history.length} ROLLS',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      key: const Key('close_oracle_chronicle_sheet'),
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
                  'Canonical log of D20 Aether resonance rolls and active temporal blessings.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6E473B)),
                ),
                const SizedBox(height: 12),

                // Active Buffs Banner
                if (activeBuffs.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEB5A9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF6E473B), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF6E473B), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACTIVE BLESSING: ${activeBuffs.first.title.toUpperCase()}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291C0E),
                                ),
                              ),
                              Text(
                                'Multiplier: ${(activeBuffs.first.multiplier * 100).toStringAsFixed(0)}% • Remaining: ${activeBuffs.first.remainingSeconds}s',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8.5,
                                  color: Color(0xFF6E473B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Roll History List
                Expanded(
                  child: history.isEmpty
                      ? const Center(
                          child: Text(
                            'No divination rolls recorded yet.\nCommune with the World Arbiter to begin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              color: Color(0xFFA78D78),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final roll = history[index];
                            final buff = roll.activeBuff;
                            final isBuffActive = buff != null && !buff.isExpired;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: roll.d20Roll >= 20
                                      ? const Color(0xFF6E473B)
                                      : const Color(0xFFA78D78).withValues(alpha: 0.5),
                                  width: roll.d20Roll >= 20 ? 1.4 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // D20 Roll Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: roll.d20Roll >= 20
                                              ? const Color(0xFF6E473B)
                                              : const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'D20: ${roll.d20Roll}',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: roll.d20Roll >= 20
                                                ? const Color(0xFFFAF7F0)
                                                : const Color(0xFF291C0E),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Outcome Tier Badge
                                      Expanded(
                                        child: Text(
                                          roll.outcomeTier,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6E473B),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),

                                      // Buff Status Badge
                                      if (roll.buffGranted != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isBuffActive
                                                ? const Color(0xFF6E473B).withValues(alpha: 0.15)
                                                : const Color(0xFFBEB5A9).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isBuffActive
                                                  ? const Color(0xFF6E473B)
                                                  : const Color(0xFFA78D78),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            isBuffActive ? 'ACTIVE' : 'EXPIRED',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: isBuffActive
                                                  ? const Color(0xFF6E473B)
                                                  : const Color(0xFFA78D78),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Prophecy Text
                                  Text(
                                    '“${roll.blessingText}”',
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 10.5,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF291C0E),
                                      height: 1.3,
                                    ),
                                  ),

                                  if (roll.buffGranted != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Buff: ${roll.buffGranted}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6E473B),
                                      ),
                                    ),
                                  ],
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
}
