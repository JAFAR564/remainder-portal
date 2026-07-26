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
        backgroundColor: const Color(0xFF161520),
        title: const Text(
          'SUBMIT CHRONO-LOOM PROPOSAL',
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
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'PROPOSAL TITLE',
                labelStyle: TextStyle(color: Colors.white60, fontSize: 10),
                filled: true,
                fillColor: Color(0xFF0A0910),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'PROPOSED LORE AMENDMENT',
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
            onPressed: _onSubmitProposal,
            child: const Text('SUBMIT FOR VOTE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text(
          'DEMOCRATIC CHRONO-LOOM',
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
            icon: const Icon(Icons.add_comment, color: Color(0xFF00F0FF)),
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
                  indicatorColor: Color(0xFF00F0FF),
                  labelColor: Color(0xFF00F0FF),
                  unselectedLabelColor: Colors.white54,
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
                            color: const Color(0xFF161520),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: p.status == 2
                                    ? const Color(0xFF38B000)
                                    : (p.status == 3 ? Colors.redAccent : const Color(0xFF00F0FF).withValues(alpha: 0.4)),
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
                                            color: Colors.white,
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
                                              ? const Color(0xFF38B000).withValues(alpha: 0.2)
                                              : const Color(0xFF00F0FF).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          p.status == 2 ? 'CANONIZED' : (p.status == 3 ? 'REJECTED' : 'VOTING ACTIVE'),
                                          style: TextStyle(
                                            color: p.status == 2 ? const Color(0xFF38B000) : const Color(0xFF00F0FF),
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
                                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.proposedContent,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'YES: ${p.yesVotes} | NO: ${p.noVotes}',
                                        style: const TextStyle(color: Color(0xFFFFD166), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                      ),
                                      if (p.status == 1) ...[
                                        Row(
                                          children: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF38B000))),
                                              onPressed: () {
                                                ref.read(chronoLoomProvider.notifier).castVote(
                                                      proposalId: p.id,
                                                      isYes: true,
                                                      trustScore: trust.overallTrustScore,
                                                      reputationRank: 1,
                                                    );
                                              },
                                              child: const Text('VOTE YES', style: TextStyle(color: Color(0xFF38B000), fontSize: 10)),
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
                                              child: const Text('VOTE NO', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
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
                            color: const Color(0xFF0A0910),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF38B000), width: 1),
                            ),
                            child: ListTile(
                              title: Text('v${h.version}. ${h.title}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(h.markdownContent, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Text('Canonized: ${h.canonizedAt.toIso8601String().substring(0, 10)}', style: const TextStyle(color: Color(0xFF38B000), fontSize: 9, fontFamily: 'monospace')),
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
