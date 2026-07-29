import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chrono_loom_provider.dart';
import '../providers/trust_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/crt_overlay.dart';

class ChronoLoomScreen extends ConsumerStatefulWidget {
  const ChronoLoomScreen({super.key});

  @override
  ConsumerState<ChronoLoomScreen> createState() => _ChronoLoomScreenState();
}

class _ChronoLoomScreenState extends ConsumerState<ChronoLoomScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSubmitProposal() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;

    ref.read(chronoLoomProvider.notifier).submitProposal(
          sectorId: profile.activeSector,
          authorId: profile.id,
          authorName: profile.name,
          title: title,
          proposedContent: content,
        );

    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);
  }

  void _showNewProposalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Text(
          'SUBMIT CHRONO-LOOM PROPOSAL',
          style: TextStyle(
            color: Color(0xFFB8860B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 12, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'PROPOSAL TITLE',
                labelStyle: TextStyle(color: Color(0xFFB8860B), fontSize: 10, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Color(0xFFFAF8F5),
                border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0DDD5))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'PROPOSED LORE AMENDMENT',
                labelStyle: TextStyle(color: Color(0xFFB8860B), fontSize: 10, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Color(0xFFFAF8F5),
                border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0DDD5))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF666666))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF1A1A1A),
            ),
            onPressed: _onSubmitProposal,
            child: const Text('SUBMIT FOR VOTE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chronoLoomProvider);
    final trust = ref.watch(trustProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text(
          'DEMOCRATIC CHRONO-LOOM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFFB8860B),
          ),
        ),
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 1,
        shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: Color(0xFFB8860B)),
            onPressed: _showNewProposalDialog,
          ),
        ],
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: Color(0xFFB8860B),
                  labelColor: Color(0xFFB8860B),
                  unselectedLabelColor: Color(0xFF666666),
                  labelStyle: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'ACTIVE VOTES'),
                    Tab(text: 'CANONIZED HISTORY'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Active proposals tab
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.proposals.length,
                        itemBuilder: (context, index) {
                          final p = state.proposals[index];
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.title.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF1A1A1A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: p.status == 2
                                              ? Colors.green.withValues(alpha: 0.1)
                                              : const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: p.status == 2 ? Colors.green : const Color(0xFFD4AF37)),
                                        ),
                                        child: Text(
                                          p.status == 2 ? 'CANONIZED' : (p.status == 3 ? 'REJECTED' : 'VOTING ACTIVE'),
                                          style: TextStyle(
                                            color: p.status == 2 ? Colors.green.shade700 : const Color(0xFFB8860B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'AUTHOR: ${p.authorName} | SECTOR: ${p.sectorId}',
                                    style: const TextStyle(color: Color(0xFF777777), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.proposedContent,
                                    style: const TextStyle(color: Color(0xFF2C2C2C), fontSize: 12, height: 1.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'YES: ${p.yesVotes} | NO: ${p.noVotes}',
                                        style: const TextStyle(color: Color(0xFFB8860B), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                      if (p.status == 1) ...[
                                        Row(
                                          children: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFB8860B))),
                                              onPressed: () {
                                                ref.read(chronoLoomProvider.notifier).castVote(
                                                      proposalId: p.id,
                                                      isYes: true,
                                                      trustScore: trust.overallTrustScore,
                                                      reputationRank: 1,
                                                    );
                                              },
                                              child: const Text('VOTE YES', style: TextStyle(color: Color(0xFFB8860B), fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                                              onPressed: () {
                                                ref.read(chronoLoomProvider.notifier).castVote(
                                                      proposalId: p.id,
                                                      isYes: false,
                                                      trustScore: trust.overallTrustScore,
                                                      reputationRank: 1,
                                                    );
                                              },
                                              child: const Text('VOTE NO', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Canonized history tab
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.canonizedHistory.length,
                        itemBuilder: (context, index) {
                          final h = state.canonizedHistory[index];
                          return Card(
                            color: const Color(0xFFFAF8F5),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                            ),
                            child: ListTile(
                              title: Text('v${h.version}. ${h.title}', style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(h.markdownContent, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Text('Canonized: ${h.canonizedAt.toIso8601String().substring(0, 10)}', style: const TextStyle(color: Color(0xFFB8860B), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
