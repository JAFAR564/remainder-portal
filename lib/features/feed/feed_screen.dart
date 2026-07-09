import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/auth_service.dart';
import '../../services/roster_cache_service.dart';
import '../profile/providers/active_character_provider.dart';

// --- DATA MODELS ---

class FeedComment {
  final String id;
  final String authorName;
  final String authorFaction;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;

  FeedComment({
    required this.id,
    required this.authorName,
    required this.authorFaction,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorFaction': authorFaction,
        'authorAvatarUrl': authorAvatarUrl,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        authorFaction: json['authorFaction'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class FeedPost {
  final String id;
  final String authorName;
  final String authorFaction;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy; // List of user emails who liked this
  final List<FeedComment> comments;

  FeedPost({
    required this.id,
    required this.authorName,
    required this.authorFaction,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
    required this.comments,
  });

  FeedPost copyWith({
    int? likes,
    List<String>? likedBy,
    List<FeedComment>? comments,
  }) {
    return FeedPost(
      id: id,
      authorName: authorName,
      authorFaction: authorFaction,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorFaction': authorFaction,
        'authorAvatarUrl': authorAvatarUrl,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
        id: json['id'] as String,
        authorName: json['authorName'] as String,
        authorFaction: json['authorFaction'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        likes: json['likes'] as int,
        likedBy: List<String>.from(json['likedBy'] as List),
        comments: (json['comments'] as List)
            .map((c) => FeedComment.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

// --- STATE MANAGEMENT ---

class FeedNotifier extends Notifier<List<FeedPost>> {
  static const _storageKey = 'cached_codex_net_posts';

  @override
  List<FeedPost> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final cached = prefs.getString(_storageKey);
    if (cached != null) {
      try {
        final List decoded = jsonDecode(cached);
        return decoded.map((item) => FeedPost.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error decoding cached feed posts: $e');
      }
    }
    return _getSeedPosts();
  }

  void addPost(String content, String authorName, String authorFaction, String authorAvatarUrl) {
    final newPost = FeedPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorFaction: authorFaction,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      timestamp: DateTime.now(),
      likes: 0,
      likedBy: [],
      comments: [],
    );

    state = [newPost, ...state];
    _persist();
  }

  void toggleLike(String postId, String userEmail) {
    state = state.map((post) {
      if (post.id == postId) {
        final isLiked = post.likedBy.contains(userEmail);
        final List<String> newLikedBy = List.from(post.likedBy);
        if (isLiked) {
          newLikedBy.remove(userEmail);
          return post.copyWith(
            likes: post.likes - 1,
            likedBy: newLikedBy,
          );
        } else {
          newLikedBy.add(userEmail);
          return post.copyWith(
            likes: post.likes + 1,
            likedBy: newLikedBy,
          );
        }
      }
      return post;
    }).toList();
    _persist();
  }

  void addComment(String postId, String commentText, String authorName, String authorFaction, String authorAvatarUrl) {
    state = state.map((post) {
      if (post.id == postId) {
        final newComment = FeedComment(
          id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
          authorName: authorName,
          authorFaction: authorFaction,
          authorAvatarUrl: authorAvatarUrl,
          content: commentText,
          timestamp: DateTime.now(),
        );
        return post.copyWith(
          comments: [...post.comments, newComment],
        );
      }
      return post;
    }).toList();
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(state.map((p) => p.toJson()).toList());
    prefs.setString(_storageKey, encoded);
  }

  List<FeedPost> _getSeedPosts() {
    return [
      FeedPost(
        id: 'seed-01',
        authorName: 'Lorna Stern',
        authorFaction: 'Elysium Syndicate',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
        content: 'ALERT: Sector coordination traces register minor drift in the southern boundary. Advise all Vanguard units to align timekeepers to standard sanctuary offsets.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        likedBy: [],
        comments: [
          FeedComment(
            id: 'seed-comment-01',
            authorName: 'Alistair Vance',
            authorFaction: 'Aethelgard Alliance',
            authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
            content: 'Synchronizing. Aethelgard gears are steady at offset +3.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      FeedPost(
        id: 'seed-02',
        authorName: 'Alistair Vance',
        authorFaction: 'Aethelgard Alliance',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        content: 'I have compiled the transcript records for the grand Clocktower convergence. The Chronicles has updated successfully. Factions must review active logs.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
        likedBy: [],
        comments: [],
      ),
    ];
  }
}

final feedProvider = NotifierProvider<FeedNotifier, List<FeedPost>>(() {
  return FeedNotifier();
});

// --- UI SCREEN ---

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _postController = TextEditingController();
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _expandedComments = {};

  @override
  void dispose() {
    _postController.dispose();
    for (var ctrl in _commentControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(feedProvider);
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'unknown@user.com';
    final activeCharAsync = ref.watch(activeCharacterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CODEX NET FEED',
          style: PortalTheme.statsText.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: IridescentOverlay(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650.0),
              child: activeCharAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading profile: $err')),
                data: (activeChar) {
                  if (activeChar == null) {
                    return Center(
                      child: Text(
                        'Set active character in profile settings to view feed.',
                        style: PortalTheme.bodyText,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Post Composer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.0,
                                    backgroundImage: activeChar.faceclaimImgUrl.isNotEmpty && activeChar.faceclaimImgUrl.startsWith('http')
                                        ? NetworkImage(activeChar.faceclaimImgUrl)
                                        : null,
                                    child: activeChar.faceclaimImgUrl.isEmpty || !activeChar.faceclaimImgUrl.startsWith('http')
                                        ? const Icon(Icons.person, size: 18.0)
                                        : null,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeChar.characterName.toUpperCase(),
                                        style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, fontSize: 11.0),
                                      ),
                                      Text(
                                        activeChar.faction.toUpperCase(),
                                        style: PortalTheme.smallText.copyWith(color: PortalTheme.infoSlate, fontSize: 8.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _postController,
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                                style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                                decoration: InputDecoration(
                                  hintText: 'Transmit spatial update or log...',
                                  hintStyle: PortalTheme.bodyText.copyWith(color: PortalTheme.warmGrayBodyText),
                                  filled: true,
                                  fillColor: PortalTheme.creamBg.withValues(alpha: 0.6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(color: PortalTheme.silverGrayBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Align(
                                alignment: Alignment.centerRight,
                                child: SpringTapWrapper(
                                  onTap: () {
                                    final text = _postController.text.trim();
                                    if (text.isEmpty) return;
                                    ref.read(feedProvider.notifier).addPost(
                                          text,
                                          activeChar.characterName,
                                          activeChar.faction,
                                          activeChar.faceclaimImgUrl,
                                        );
                                    _postController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: PortalTheme.tealNavyAccent,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: const Text(
                                      'TRANSMIT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Jost',
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Feed Scroll Area
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            final hasLiked = post.likedBy.contains(email);
                            final isExpanded = _expandedComments[post.id] ?? false;

                            if (!_commentControllers.containsKey(post.id)) {
                              _commentControllers[post.id] = TextEditingController();
                            }
                            final commentCtrl = _commentControllers[post.id]!;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author Row
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16.0,
                                          backgroundImage: post.authorAvatarUrl.isNotEmpty && post.authorAvatarUrl.startsWith('http')
                                              ? NetworkImage(post.authorAvatarUrl)
                                              : null,
                                          child: post.authorAvatarUrl.isEmpty || !post.authorAvatarUrl.startsWith('http')
                                              ? const Icon(Icons.person, size: 16.0)
                                              : null,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.authorName.toUpperCase(),
                                              style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, fontSize: 11.0),
                                            ),
                                            Text(
                                              post.authorFaction.toUpperCase(),
                                              style: PortalTheme.smallText.copyWith(color: PortalTheme.infoSlate, fontSize: 8.0),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatTime(post.timestamp),
                                          style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText, fontSize: 9.0),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14.0),

                                    // Content Text
                                    Text(
                                      post.content,
                                      style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText, height: 1.4),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Divider(),
                                    const SizedBox(height: 8.0),

                                    // Action Row
                                    Row(
                                      children: [
                                        // Like Action
                                        SpringTapWrapper(
                                          onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id, email),
                                          child: Row(
                                            children: [
                                              Icon(
                                                hasLiked ? Icons.favorite : Icons.favorite_border,
                                                color: hasLiked ? PortalTheme.alertTerracotta : PortalTheme.warmGrayBodyText,
                                                size: 18.0,
                                              ),
                                              const SizedBox(width: 6.0),
                                              Text(
                                                '${post.likes}',
                                                style: PortalTheme.statsText.copyWith(fontSize: 11.0, color: PortalTheme.warmGrayBodyText),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24.0),

                                        // Comment Action Toggle
                                        SpringTapWrapper(
                                          onTap: () => setState(() => _expandedComments[post.id] = !isExpanded),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.comment_outlined, color: PortalTheme.warmGrayBodyText, size: 18.0),
                                              const SizedBox(width: 6.0),
                                              Text(
                                                '${post.comments.length}',
                                                style: PortalTheme.statsText.copyWith(fontSize: 11.0, color: PortalTheme.warmGrayBodyText),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Expanded Comments View
                                    if (isExpanded) ...[
                                      const SizedBox(height: 16.0),
                                      const Divider(),
                                      const SizedBox(height: 12.0),
                                      
                                      // Render list of comments
                                      if (post.comments.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            'No spatial feedback logged yet.',
                                            style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText, fontStyle: FontStyle.italic),
                                          ),
                                        )
                                      else
                                        ...post.comments.map((comment) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 12.0,
                                                  backgroundImage: comment.authorAvatarUrl.isNotEmpty && comment.authorAvatarUrl.startsWith('http')
                                                      ? NetworkImage(comment.authorAvatarUrl)
                                                      : null,
                                                  child: comment.authorAvatarUrl.isEmpty || !comment.authorAvatarUrl.startsWith('http')
                                                      ? const Icon(Icons.person, size: 12.0)
                                                      : null,
                                                ),
                                                const SizedBox(width: 8.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            comment.authorName,
                                                            style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold, fontSize: 10.0),
                                                          ),
                                                          const SizedBox(width: 6.0),
                                                          Text(
                                                            '• ${comment.authorFaction}',
                                                            style: PortalTheme.smallText.copyWith(color: PortalTheme.infoSlate, fontSize: 8.0),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 2.0),
                                                      Text(
                                                        comment.content,
                                                        style: PortalTheme.bodyText.copyWith(fontSize: 12.0, color: PortalTheme.charcoalNearBlackText),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),

                                      const SizedBox(height: 8.0),
                                      // Input field for writing comment
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: commentCtrl,
                                              style: PortalTheme.bodyText.copyWith(fontSize: 12.0),
                                              decoration: InputDecoration(
                                                hintText: 'Log your feedback...',
                                                hintStyle: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                                                filled: true,
                                                fillColor: PortalTheme.creamBg,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: const BorderSide(color: PortalTheme.silverGrayBorder)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          SpringTapWrapper(
                                            onTap: () {
                                              final text = commentCtrl.text.trim();
                                              if (text.isEmpty) return;
                                              ref.read(feedProvider.notifier).addComment(
                                                    post.id,
                                                    text,
                                                    activeChar.characterName,
                                                    activeChar.faction,
                                                    activeChar.faceclaimImgUrl,
                                                  );
                                              commentCtrl.clear();
                                              FocusScope.of(context).unfocus();
                                            },
                                            child: Container(
                                              height: 36.0,
                                              width: 36.0,
                                              decoration: const BoxDecoration(color: PortalTheme.tealNavyAccent, shape: BoxShape.circle),
                                              child: const Icon(Icons.send, color: Colors.white, size: 14.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
