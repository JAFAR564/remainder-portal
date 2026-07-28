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
        color: const Color(0xFF1C2541).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasLaureled ? const Color(0xFFD4AF37) : Colors.white12,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B132B).withValues(alpha: 0.6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author Info Header (Facebook style)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    widget.avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Color(0xFFD4AF37)),
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
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.authorTitle,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Color(0xFF00B4D8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${widget.timeAgo}',
                          style: const TextStyle(fontSize: 10, color: Colors.white38),
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
                  color: widget.isIC ? Colors.purple.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: widget.isIC ? Colors.purpleAccent : Colors.lightBlueAccent),
                ),
                child: Text(
                  widget.isIC ? 'IC POST' : 'OOC POST',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: widget.isIC ? Colors.purpleAccent : Colors.lightBlueAccent,
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
              color: Colors.white90,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),

          // 3. Facebook-style Social Reaction Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Golden Laurel Like Button
              InkWell(
                onTap: _toggleLaurel,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        _hasLaureled ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                        color: _hasLaureled ? const Color(0xFFD4AF37) : Colors.white54,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_laurels LAURELS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _hasLaureled ? const Color(0xFFD4AF37) : Colors.white54,
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
                      const Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$_comments COMMENTS',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.white54,
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
                      Icon(Icons.share_outlined, color: Colors.white54, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'SHARE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Colors.white54,
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
