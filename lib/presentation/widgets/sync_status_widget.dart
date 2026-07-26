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
        color: const Color(0xFF161520).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline ? const Color(0xFF38B000).withValues(alpha: 0.3) : const Color(0xFFFF8E3C).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: isOnline ? const Color(0xFF38B000) : const Color(0xFFFF8E3C),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'DELTA SYNC: ACTIVE' : 'OFFLINE MODE',
            style: TextStyle(
              color: isOnline ? const Color(0xFF38B000) : const Color(0xFFFF8E3C),
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
                color: const Color(0xFFE53170).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'QUEUE: $pendingCount',
                style: const TextStyle(
                  color: Color(0xFFE53170),
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
              child: const Icon(Icons.sync, color: Colors.white70, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
