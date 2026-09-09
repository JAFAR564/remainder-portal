import 'package:flutter/material.dart';
import 'celestial_panel.dart';

/// Imperial Parchment Social Post Card with Responsive Reaction Bar.
class SocialPostCard extends StatefulWidget {
  final String authorName;
  final String authorTitle;
  final String avatarPath;
  final String timeAgo;
  final String content;
  final bool isIC;
  final int initialLaurels;
  final int initialComments;

  const SocialPostCard({
    super.key,
    required this.authorName,
    required this.authorTitle,
    required this.avatarPath,
    required this.timeAgo,
    required this.content,
    this.isIC = true,
    this.initialLaurels = 12,
    this.initialComments = 3,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  late int _laurels;
  late int _comments;
  bool _hasLaureled = false;

  @override
  void initState() {
    super.initState();
    _laurels = widget.initialLaurels;
    _comments = widget.initialComments;
  }

  void _toggleLaurel() {
    setState(() {
      if (_hasLaureled) {
        _laurels--;
        _hasLaureled = false;
      } else {
        _laurels++;
        _hasLaureled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CelestialPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author Metadata Header Row
          Row(
            children: [
              // Avatar Crest Frame
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                  border: Border.all(
                    color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.authorName.isNotEmpty ? widget.authorName[0] : '?',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291C0E),
                      ),
                    ),
                    Text(
                      '${widget.authorTitle} • ${widget.timeAgo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8.5,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                  ],
                ),
              ),

              // IC / OOC Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isIC
                      ? const Color(0xFF6E473B).withValues(alpha: 0.12)
                      : const Color(0xFFA78D78).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                  ),
                ),
                child: Text(
                  widget.isIC ? 'IN-CHARACTER (IC)' : 'OUT-OF-CHARACTER (OOC)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Post Body Text
          Text(
            widget.content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF291C0E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          const Divider(color: Color(0xFFBEB5A9), height: 1),
          const SizedBox(height: 6),

          // 3. Responsive Social Reaction Bar (Fixes Defects 6 & 7)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Laurel Like Button
              Expanded(
                child: InkWell(
                  onTap: _toggleLaurel,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hasLaureled ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                          color: const Color(0xFF6E473B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$_laurels LAURELS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E473B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Comment Button
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mode_comment_outlined, color: Color(0xFFA78D78), size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$_comments COMMENTS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              color: Color(0xFF291C0E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Share Button
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_outlined, color: Color(0xFFA78D78), size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'SHARE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              color: Color(0xFF291C0E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
