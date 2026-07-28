import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../../data/models/okf_concept.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final OkfConcept? sectorNode;
  const TerminalScreen({super.key, this.sectorNode});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isICInput = true;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    
    final profile = ref.read(playerProfileProvider);
    final origin = profile?.origin ?? 'Vanguard';

    // Send action to Chat notifier (which queries local RAG Genkit API)
    await ref.read(chatHistoryProvider.notifier).sendPlayerAction(
      text,
      origin,
      isIC: _isICInput,
    );

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildFilterChip(WidgetRef ref, ChatFilter filter, String label) {
    final currentFilter = ref.watch(chatFilterProvider);
    final isSelected = currentFilter == filter;

    return InkWell(
      onTap: () {
        ref.read(chatFilterProvider.notifier).state = filter;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white24,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatHistoryProvider);
    final chatFilter = ref.watch(chatFilterProvider);

    final filteredMessages = messages.where((msg) {
      if (chatFilter == ChatFilter.icOnly) return msg.isIC;
      if (chatFilter == ChatFilter.oocOnly) return !msg.isIC;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2541),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEXUS ROLEPLAY & SYSTEM ADMIN CHAT',
              style: TextStyle(fontFamily: 'serif', fontSize: 13, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
            ),
            Text(
              'SYSTEM ADMINISTRATOR AI (CARDINAL / SOVEREIGN) ONLINE',
              style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF00B4D8)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
            child: Row(
              children: [
                _buildFilterChip(ref, ChatFilter.all, 'ALL CHANNELS'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, ChatFilter.icOnly, 'IC ROLEPLAY'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, ChatFilter.oocOnly, 'OOC CHAT'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // System Admin AI Announcement Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
            child: const Row(
              children: [
                Icon(Icons.campaign_outlined, color: Color(0xFF00B4D8), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SYSTEM ANNOUNCEMENT: Monster Wave in Sector 4. Roleplay consensus rules active.',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF00B4D8)),
                  ),
                ),
              ],
            ),
          ),

          // Chat Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredMessages.length,
              itemBuilder: (context, idx) {
                final msg = filteredMessages[idx];
                final isGM = msg.sender == 'Game Master' || msg.sender.contains('System');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGM ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isGM ? const Color(0xFFD4AF37).withValues(alpha: 0.6) : Colors.white12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isGM ? Icons.auto_awesome : Icons.person_outline,
                                color: isGM ? const Color(0xFFD4AF37) : const Color(0xFF00B4D8),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                msg.sender.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isGM ? const Color(0xFFD4AF37) : const Color(0xFF00B4D8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: msg.isIC ? Colors.purple.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              msg.isIC ? 'IC' : 'OOC',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                color: msg.isIC ? Colors.purpleAccent : Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.content,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1C2541),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isICInput ? Icons.record_voice_over : Icons.chat_bubble_outline,
                    color: _isICInput ? const Color(0xFFD4AF37) : Colors.white54,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isICInput = !_isICInput;
                    });
                  },
                  tooltip: _isICInput ? 'In-Character Mode' : 'Out-of-Character Mode',
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _onSubmit(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _isICInput ? 'Speak in-character...' : 'Speak out-of-character...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFD4AF37), size: 20),
                  onPressed: _onSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
