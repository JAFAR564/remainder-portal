import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/social_bulletin_model.dart';
import '../providers/sovereign_provider.dart';
import '../providers/utrcs_provider.dart';

/// Modal bottom sheet displaying persisted comments for a specific post
/// and allowing operators to append new responses.
class SocialCommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postAuthor;

  const SocialCommentsSheet({
    super.key,
    required this.postId,
    required this.postAuthor,
  });

  static Future<void> show(BuildContext context, {required String postId, required String postAuthor}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SocialCommentsSheet(postId: postId, postAuthor: postAuthor),
    );
  }

  @override
  ConsumerState<SocialCommentsSheet> createState() => _SocialCommentsSheetState();
}

class _SocialCommentsSheetState extends ConsumerState<SocialCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<SocialCommentEntry> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await ref.read(socialBulletinProvider.notifier).getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final character = ref.read(utrcsCharacterProvider);
      final authorName = character?.identity.name ?? 'Operator Vanguard';

      await ref.read(socialBulletinProvider.notifier).addComment(
        postId: widget.postId,
        authorName: authorName,
        content: text,
      );

      _commentController.clear();
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Comment inscribed to bulletin dispatch.',
              style: TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
            backgroundColor: Color(0xFF6E473B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add comment: $e',
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
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
                child: const Icon(Icons.mode_comment_outlined, color: Color(0xFF6E473B), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMMENTS — ${widget.postAuthor.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291C0E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '${_comments.length} PERSISTED RESPONSES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8.5,
                        color: Color(0xFFA78D78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('close_social_comments_sheet'),
                icon: const Icon(Icons.close, color: Color(0xFF6E473B), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFBEB5A9), height: 1),
          const SizedBox(height: 8),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6E473B)))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.speaker_notes_off_outlined, color: const Color(0xFFA78D78).withValues(alpha: 0.6), size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'NO COMMENTS IN CHRONICLE',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA78D78),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Transmit the first observation to this dispatch below.',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFA78D78),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFFBEB5A9), height: 12),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.authorName,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6E473B),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${comment.createdAt.hour.toString().padLeft(2, '0')}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 8,
                                        color: Color(0xFFA78D78),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF291C0E),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 8),

          // Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comment_input_field'),
                  controller: _commentController,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF291C0E)),
                  decoration: InputDecoration(
                    hintText: 'Transmit a comment...',
                    hintStyle: const TextStyle(fontFamily: 'serif', fontSize: 11, color: Color(0xFFA78D78)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const Key('submit_comment_button'),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1D4C2)),
                      )
                    : const Icon(Icons.send, size: 16),
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
