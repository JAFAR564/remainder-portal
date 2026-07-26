import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ContentLifecycleStage {
  draft,            // 0
  validation,       // 1
  preview,          // 2
  localTesting,     // 3
  communityReview,  // 4
  moderation,       // 5
  canonApproval,    // 6
  published         // 7
}

class CreatorContentModel {
  final String id;
  final String authorId;
  final String contentType; // 'sector', 'settlement', 'npc', 'quest', 'lore_entry'
  final String title;
  final String okfMarkdownBody;
  final ContentLifecycleStage stage;
  final int version;
  final DateTime createdAt;
  final DateTime lastModified;

  CreatorContentModel({
    required this.id,
    required this.authorId,
    required this.contentType,
    required this.title,
    required this.okfMarkdownBody,
    this.stage = ContentLifecycleStage.draft,
    this.version = 1,
    required this.createdAt,
    required this.lastModified,
  });

  CreatorContentModel copyWith({
    String? title,
    String? okfMarkdownBody,
    ContentLifecycleStage? stage,
    int? version,
    DateTime? lastModified,
  }) {
    return CreatorContentModel(
      id: id,
      authorId: authorId,
      contentType: contentType,
      title: title ?? this.title,
      okfMarkdownBody: okfMarkdownBody ?? this.okfMarkdownBody,
      stage: stage ?? this.stage,
      version: version ?? this.version,
      createdAt: createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}

class CreatorStateNotifier extends StateNotifier<List<CreatorContentModel>> {
  CreatorStateNotifier()
      : super([
          CreatorContentModel(
            id: 'okf_content_001',
            authorId: 'author_master',
            contentType: 'sector',
            title: 'Sub-Sector Obsidian Breach',
            okfMarkdownBody: '''
---
concept_uid: sector_obsidian_breach
title: Obsidian Breach
genre: Cyberpunk / Cosmic Horror
environmental_stability: 0.72
---

# Sector Profile: Obsidian Breach
The Breach represents an unaligned dark-fiber sector node rich in raw energy credits.
''',
            stage: ContentLifecycleStage.preview,
            version: 1,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            lastModified: DateTime.now(),
          )
        ]);

  void createContent({
    required String authorId,
    required String contentType,
    required String title,
    required String okfBody,
  }) {
    final newContent = CreatorContentModel(
      id: 'okf_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      contentType: contentType,
      title: title,
      okfMarkdownBody: okfBody,
      stage: ContentLifecycleStage.draft,
      version: 1,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    state = [newContent, ...state];
  }

  void advanceStage(String contentId) {
    final index = state.indexWhere((c) => c.id == contentId);
    if (index == -1) return;

    final target = state[index];
    final currentIdx = target.stage.index;
    if (currentIdx >= ContentLifecycleStage.published.index) return;

    final nextStage = ContentLifecycleStage.values[currentIdx + 1];
    final updated = target.copyWith(stage: nextStage);

    final updatedList = [...state];
    updatedList[index] = updated;
    state = updatedList;
  }

  void updateBody(String contentId, String okfBody) {
    final index = state.indexWhere((c) => c.id == contentId);
    if (index == -1) return;

    final target = state[index];
    final updated = target.copyWith(okfMarkdownBody: okfBody);

    final updatedList = [...state];
    updatedList[index] = updated;
    state = updatedList;
  }
}

final creatorProvider = StateNotifierProvider<CreatorStateNotifier, List<CreatorContentModel>>((ref) {
  return CreatorStateNotifier();
});
