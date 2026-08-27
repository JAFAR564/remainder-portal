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
          color: isSelected ? const Color(0xFF6E473B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFA78D78),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E473B).withValues(alpha: 0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE1D4C2) : const Color(0xFF6E473B),
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
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOVEREIGN REALM & WORLD ARBITER CHAT',
              style: TextStyle(fontFamily: 'serif', fontSize: 13, color: Color(0xFF6E473B), fontWeight: FontWeight.bold),
            ),
            Text(
              'WORLD ARBITER (CARDINAL) ONLINE',
              style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF291C0E), fontWeight: FontWeight.bold),
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
          // System Admin Announcement Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE1D4C2),
              border: Border(bottom: BorderSide(color: Color(0xFFA78D78), width: 1.0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.campaign_outlined, color: Color(0xFF6E473B), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SYSTEM ANNOUNCEMENT: Monster Wave in Sector 4. Roleplay consensus rules active.',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF291C0E), fontWeight: FontWeight.bold),
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
                    color: isGM ? const Color(0xFFE1D4C2).withValues(alpha: 0.35) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isGM ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                      width: isGM ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
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
                                color: isGM ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                msg.sender.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isGM ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: msg.isIC ? const Color(0xFF6E473B).withValues(alpha: 0.12) : const Color(0xFFA78D78).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: msg.isIC ? const Color(0xFF6E473B) : const Color(0xFFA78D78)),
                            ),
                            child: Text(
                              msg.isIC ? 'IC' : 'OOC',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: msg.isIC ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.content,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF291C0E), height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.viewInsetsOf(context).bottom > 0 ? 12 : 88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFA78D78), width: 1.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isICInput ? Icons.record_voice_over : Icons.chat_bubble_outline,
                    color: _isICInput ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
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
                    style: const TextStyle(color: Color(0xFF291C0E), fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: _isICInput ? 'Speak in-character...' : 'Speak out-of-character...',
                      hintStyle: const TextStyle(color: Color(0xFFBEB5A9), fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6E473B), size: 20),
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
