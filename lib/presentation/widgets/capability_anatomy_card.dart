import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/utrcs_character.dart';

/// 4-Part Anti-Mary-Sue Capability Anatomy Card with Interactive D20 Check Roller.
class CapabilityAnatomyCard extends StatelessWidget {
  final UtrcsCapability capability;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CapabilityAnatomyCard({
    super.key,
    required this.capability,
    this.onEdit,
    this.onDelete,
  });

  void _simulateD20Check(BuildContext context) {
    final rand = math.Random();
    final d20 = rand.nextInt(20) + 1;
    final total = d20 + capability.d20Modifier;
    const dc = 12;
    final isSuccess = total >= dc;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSuccess ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
            width: 1.8,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.stars : Icons.warning_amber_rounded,
              color: isSuccess ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSuccess ? 'D20 SUCCESS: MANIFESTED' : 'D20 STRAIN: BACKLASH',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capability: ${capability.name.toUpperCase()}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA78D78)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRollCol('NATURAL D20', '$d20'),
                  const Text('+', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildRollCol('MODIFIER', '+${capability.d20Modifier}'),
                  const Text('=', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildRollCol('TOTAL vs DC $dc', '$total', isHighlighted: true, isSuccess: isSuccess),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSuccess
                  ? 'The capability channels cleanly through the celestial leylines without triggering backlash.'
                  : 'FAILURE STATE TRIGGERED:\n"${capability.failureState}"',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: isSuccess ? const Color(0xFF291C0E) : const Color(0xFF6E473B),
                fontWeight: isSuccess ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DISMISS', style: TextStyle(color: Color(0xFF6E473B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Widget _buildRollCol(String label, String value, {bool isHighlighted = false, bool isSuccess = true}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 7.5, color: Color(0xFFA78D78)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? (isSuccess ? const Color(0xFF6E473B) : const Color(0xFF291C0E))
                : const Color(0xFF291C0E),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.bolt, size: 16, color: Color(0xFF6E473B)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capability.name,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6E473B),
                              ),
                            ),
                            Text(
                              '${capability.type.toUpperCase()} • MODIFIER: +${capability.d20Modifier}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA78D78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${capability.d20Modifier} D20 CHECK',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE1D4C2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFA78D78), thickness: 0.8),

          // 4-Part Anti-Mary-Sue Quadrant Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildQuadrantPill(
                        tag: 'ACTIVATION COST',
                        value: capability.cost,
                        icon: Icons.local_fire_department_outlined,
                        badgeColor: const Color(0xFF6E473B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuadrantPill(
                        tag: 'SCOPE & BOUNDARY',
                        value: capability.scope,
                        icon: Icons.explore_outlined,
                        badgeColor: const Color(0xFFA78D78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildQuadrantPill(
                        tag: 'FAILURE BACKLASH',
                        value: capability.failureState,
                        icon: Icons.dangerous_outlined,
                        badgeColor: const Color(0xFF291C0E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuadrantPill(
                        tag: 'SYSTEMIC COUNTER',
                        value: capability.condition.isNotEmpty
                            ? 'Requires: ${capability.condition}'
                            : 'Vulnerable to Disruption & Void Shock',
                        icon: Icons.lock_open_outlined,
                        badgeColor: const Color(0xFF6E473B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Bar: D20 Test Roll & Option Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _simulateD20Check(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.casino, size: 13, color: Color(0xFFE1D4C2)),
                        SizedBox(width: 4),
                        Text(
                          'SIMULATE D20 CHECK',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE1D4C2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFA78D78)),
                    tooltip: 'Remove Capability',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantPill({
    required String tag,
    required String value,
    required IconData icon,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: badgeColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF291C0E),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
