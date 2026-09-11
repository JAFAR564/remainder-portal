import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

/// Modal bottom sheet for composing and transmitting a new sanctuary social post.
class SocialPostCreationSheet extends ConsumerStatefulWidget {
  const SocialPostCreationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SocialPostCreationSheet(),
    );
  }

  @override
  ConsumerState<SocialPostCreationSheet> createState() => _SocialPostCreationSheetState();
}

class _SocialPostCreationSheetState extends ConsumerState<SocialPostCreationSheet> {
  final TextEditingController _contentController = TextEditingController();
  bool _isIC = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final character = ref.read(utrcsCharacterProvider);
      final authorId = character?.id ?? 'utrcs_default_player';
      final authorName = character?.identity.name ?? 'Operator Vanguard';
      final authorTitle = character?.identity.concept ?? 'Sovereign Pioneer';

      await ref.read(socialBulletinProvider.notifier).createPost(
        authorId: authorId,
        authorName: authorName,
        authorTitle: authorTitle,
        content: text,
        isIC: _isIC,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dispatch transmitted to Sanctuary Leylines.',
              style: TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            backgroundColor: Color(0xFF6E473B),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to transmit post: $e',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40291C0E),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBEB5A9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.send_outlined, color: Color(0xFF6E473B), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRANSMIT SANCTUARY BULLETIN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291C0E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'INSCRIBE NEW DISPATCH TO SOVEREIGN LEYLINES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        color: Color(0xFFA78D78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('close_create_post_sheet'),
                icon: const Icon(Icons.close, color: Color(0xFF6E473B), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFBEB5A9), height: 1),
          const SizedBox(height: 12),

          // IC / OOC Toggle
          Row(
            children: [
              const Text(
                'TRANSMISSION MODE: ',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF291C0E),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                key: const Key('toggle_ic_ooc_button'),
                onTap: () => setState(() => _isIC = !_isIC),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isIC
                        ? const Color(0xFF6E473B).withValues(alpha: 0.15)
                        : const Color(0xFFA78D78).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isIC ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                    ),
                  ),
                  child: Text(
                    _isIC ? 'IN-CHARACTER (IC)' : 'OUT-OF-CHARACTER (OOC)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: _isIC ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content Field
          TextField(
            key: const Key('create_post_content_input'),
            controller: _contentController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12,
              color: Color(0xFF291C0E),
            ),
            decoration: InputDecoration(
              hintText: 'Inscribe your observations, reconnaissance, or requests to the Sanctuary leylines...',
              hintStyle: const TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFFA78D78),
              ),
              filled: true,
              fillColor: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFA78D78)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('submit_post_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E473B),
                foregroundColor: const Color(0xFFE1D4C2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1D4C2)),
                    )
                  : const Icon(Icons.satellite_alt_outlined, size: 16),
              label: Text(
                _isSubmitting ? 'TRANSMITTING...' : 'TRANSMIT DISPATCH TO LEYLINES',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
