import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/creator_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/crt_overlay.dart';

class CreatorDashboardScreen extends ConsumerStatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  ConsumerState<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends ConsumerState<CreatorDashboardScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedType = 'sector';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onCreateContent() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;

    ref.read(creatorProvider.notifier).createContent(
          authorId: profile.id,
          contentType: _selectedType,
          title: title,
          okfBody: body,
        );

    _titleController.clear();
    _bodyController.clear();
    Navigator.pop(context);
  }

  void _showNewContentDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161520),
        title: const Text(
          'AUTHOR OKF CONTENT',
          style: TextStyle(
            color: Color(0xFF00F0FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: _selectedType,
              dropdownColor: const Color(0xFF161520),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'sector', child: Text('SECTOR NODE')),
                DropdownMenuItem(value: 'settlement', child: Text('SETTLEMENT')),
                DropdownMenuItem(value: 'npc', child: Text('NPC ENTITY')),
                DropdownMenuItem(value: 'quest', child: Text('COGNITIVE QUEST')),
                DropdownMenuItem(value: 'lore_entry', child: Text('WORLD LORE ENTRY')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'CONTENT TITLE',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 10),
                filled: true,
                fillColor: Color(0xFF0A0910),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'OKF MARKDOWN BODY',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 10),
                filled: true,
                fillColor: Color(0xFF0A0910),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F0FF)),
            onPressed: _onCreateContent,
            child: const Text('CREATE DRAFT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creatorState = ref.watch(creatorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'CREATOR AUTHORING SUITE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161520),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Color(0xFF00F0FF)),
            onPressed: _showNewContentDialog,
          ),
        ],
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: creatorState.length,
            itemBuilder: (context, index) {
              final item = creatorState[index];
              final stageName = item.stage.name.toUpperCase();
              final progress = (item.stage.index + 1) / ContentLifecycleStage.values.length;

              return Card(
                color: const Color(0xFF161520),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stageName,
                              style: const TextStyle(
                                color: Color(0xFF00F0FF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('TYPE: ${item.contentType.toUpperCase()} | VERSION: v${item.version}', style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace')),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.okfMarkdownBody,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.stage != ContentLifecycleStage.published)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F0FF)),
                              onPressed: () {
                                ref.read(creatorProvider.notifier).advanceStage(item.id);
                              },
                              child: const Text('ADVANCE PIPELINE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
