import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

class SyncStatusWidget extends ConsumerWidget {
  final int pendingCount;
  final VoidCallback? onManualSync;

  const SyncStatusWidget({
    super.key,
    this.pendingCount = 0,
    this.onManualSync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);
    final isOnline = status == ConnectionStatus.online;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFA78D78),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF291C0E).withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: isOnline ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'DELTA SYNC: ACTIVE' : 'OFFLINE MODE',
            style: TextStyle(
              color: isOnline ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (pendingCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'QUEUE: $pendingCount',
                style: const TextStyle(
                  color: Color(0xFF291C0E),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (onManualSync != null && isOnline) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onManualSync,
              child: const Icon(Icons.sync, color: Color(0xFF6E473B), size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
