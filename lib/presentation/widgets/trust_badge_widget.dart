import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trust_provider.dart';
import '../providers/game_provider.dart';

class TrustBadgeWidget extends ConsumerWidget {
  final String targetUserId;
  final String targetUserName;

  const TrustBadgeWidget({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustState = ref.watch(trustProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE53170).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRUST VECTOR AURA: $targetUserName'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38B000).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SCORE: ${(trustState.overallTrustScore * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Color(0xFF38B000),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVectorChip(
                context,
                ref,
                'VANGUARD',
                trustState.vanguardScore,
                const Color(0xFFE53170),
                TrustVector.vanguard,
              ),
              _buildVectorChip(
                context,
                ref,
                'ARBITER',
                trustState.arbiterScore,
                const Color(0xFFFF8E3C),
                TrustVector.arbiter,
              ),
              _buildVectorChip(
                context,
                ref,
                'MERCHANT',
                trustState.merchantScore,
                const Color(0xFFFFD166),
                TrustVector.merchant,
              ),
              _buildVectorChip(
                context,
                ref,
                'HACKER',
                trustState.hackerScore,
                const Color(0xFF00F0FF),
                TrustVector.hacker,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVectorChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    double score,
    Color color,
    TrustVector vector,
  ) {
    final profile = ref.read(playerProfileProvider);

    return InkWell(
      onTap: () {
        if (profile == null) return;
        final success = ref.read(trustProvider.notifier).addEndorsement(
              giverId: profile.id,
              receiverId: targetUserId,
              vector: vector,
            );

        final snackBar = SnackBar(
          content: Text(
            success
                ? 'Granted $label Endorsement to $targetUserName!'
                : 'Daily endorsement cap reached (max 3/day).',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          backgroundColor: success ? color : Colors.redAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(score * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
