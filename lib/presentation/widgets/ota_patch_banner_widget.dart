import 'package:flutter/material.dart';

class OtaPatchBannerWidget extends StatelessWidget {
  final String patchVersion;
  final VoidCallback? onApplyRestart;
  final VoidCallback? onDismiss;

  const OtaPatchBannerWidget({
    super.key,
    required this.patchVersion,
    this.onApplyRestart,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007791).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF007791)),
            ),
            child: const Icon(
              Icons.cloud_sync_outlined,
              color: Color(0xFF007791),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'REALM CLOUD PATCH READY',
                  style: TextStyle(
                    color: Color(0xFFB8860B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aether patch v$patchVersion downloaded silently. Restart to apply.',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 1,
            ),
            onPressed: onApplyRestart,
            child: const Text(
              'RESTART',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          if (onDismiss != null) ...[
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Color(0xFF888888)),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
