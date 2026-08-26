import 'package:flutter/material.dart';

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
    this.initialComments = 4,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA78D78),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF291C0E).withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author Info Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    widget.avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFF6E473B)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291C0E),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.authorTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E473B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${widget.timeAgo}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFFBEB5A9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // IC / OOC Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isIC ? const Color(0xFF6E473B).withValues(alpha: 0.12) : const Color(0xFFA78D78).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFFA78D78)),
                ),
                child: Text(
                  widget.isIC ? 'IC POST' : 'OOC POST',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: widget.isIC ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Post Body Text
          Text(
            widget.content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF291C0E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          const Divider(color: Color(0xFFBEB5A9), height: 1),
          const SizedBox(height: 8),

          // 3. Social Reaction Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Laurel Like Button
              InkWell(
                onTap: _toggleLaurel,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        _hasLaureled ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                        color: const Color(0xFF6E473B),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_laurels LAURELS',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6E473B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Button
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, color: Color(0xFFA78D78), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$_comments COMMENTS',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF291C0E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Share Button
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, color: Color(0xFFA78D78), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'SHARE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF291C0E),
                        ),
                      ),
                    ],
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
