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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
        ),
        title: const Text(
          'AUTHOR OKF CONTENT',
          style: TextStyle(
            color: Color(0xFF6E473B),
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
              dropdownColor: Colors.white,
              style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
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
              style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12),
              decoration: InputDecoration(
                labelText: 'CONTENT TITLE',
                labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontFamily: 'monospace'),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'OKF MARKDOWN BODY',
                labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF291C0E))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E473B),
              foregroundColor: const Color(0xFFE1D4C2),
            ),
            onPressed: _onCreateContent,
            child: const Text('CREATE DRAFT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creatorState = ref.watch(creatorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'CREATOR AUTHORING SUITE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF6E473B),
            fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Color(0xFF6E473B)),
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
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFA78D78), width: 1.2),
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
                              color: Color(0xFF291C0E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6E473B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF6E473B)),
                            ),
                            child: Text(
                              stageName,
                              style: const TextStyle(
                                color: Color(0xFF6E473B),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('TYPE: ${item.contentType.toUpperCase()} | VERSION: v${item.version}', style: const TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E473B)),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.okfMarkdownBody,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.stage != ContentLifecycleStage.published)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6E473B),
                                foregroundColor: const Color(0xFFE1D4C2),
                              ),
                              onPressed: () {
                                ref.read(creatorProvider.notifier).advanceStage(item.id);
                              },
                              child: const Text('ADVANCE PIPELINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
