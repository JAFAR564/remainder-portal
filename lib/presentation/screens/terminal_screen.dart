import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/data/models/okf_concept.dart';
import 'package:remainder_portal/presentation/widgets/crt_overlay.dart';
import 'package:remainder_portal/presentation/screens/descent_screen.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final OkfConcept sectorNode;
  const TerminalScreen({super.key, required this.sectorNode});

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
    if (profile == null) return;

    // Send action to Chat notifier (which queries local RAG Genkit API)
    await ref.read(chatHistoryProvider.notifier).sendPlayerAction(
      text,
      profile.origin,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53170).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53170) : Colors.white24,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE53170) : Colors.white60,
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
    final profile = ref.watch(playerProfileProvider);
    final chatFilter = ref.watch(chatFilterProvider);

    final filteredMessages = messages.where((msg) {
      if (chatFilter == ChatFilter.icOnly) return msg.isIC;
      if (chatFilter == ChatFilter.oocOnly) return !msg.isIC;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: Text(
          widget.sectorNode.title?.toUpperCase() ?? 'TERMINAL CODES',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF161520),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF8E3C)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DescentScreen()),
            );
          },
        ),
        actions: [
          _buildConnectionIndicator(ref),
        ],
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: Column(
            children: [
              // Status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: const Color(0xFF161520).withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NODE: ${widget.sectorNode.uid?.toUpperCase() ?? 'UNKNOWN'}',
                      style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                    ),
                    if (profile != null)
                      Text(
                        'OP: ${profile.name.toUpperCase()} [${profile.origin.toUpperCase()}]',
                        style: const TextStyle(color: Color(0xFFFF8E3C), fontSize: 10, fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),

              // Chat Segmented Filter Control Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip(ref, ChatFilter.all, 'ALL'),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, ChatFilter.icOnly, 'IC ONLY'),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, ChatFilter.oocOnly, 'OOC ONLY'),
                  ],
                ),
              ),

              // Message console output
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0910),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFFE53170).withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final msg = filteredMessages[index];
                      final isGM = msg.sender == 'Game Master';
                      final isIC = msg.isIC;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: isGM ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.sender.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: isIC
                                        ? (isGM ? const Color(0xFFE53170) : const Color(0xFFFF8E3C))
                                        : Colors.white54,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isIC
                                        ? (isGM ? const Color(0xFFE53170).withValues(alpha: 0.2) : const Color(0xFFFF8E3C).withValues(alpha: 0.2))
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isIC ? (isGM ? 'GM' : (profile?.origin.toUpperCase() ?? 'IC')) : 'OOC',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: isIC
                                          ? (isGM ? const Color(0xFFE53170) : const Color(0xFFFF8E3C))
                                          : Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isIC
                                    ? (isGM ? const Color(0xFF161520) : const Color(0xFF0F0E17))
                                    : const Color(0xFF232232),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isIC
                                      ? (isGM ? const Color(0xFF00F0FF).withValues(alpha: 0.4) : const Color(0xFFFF8E3C).withValues(alpha: 0.4))
                                      : Colors.white24,
                                  width: isIC ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: isIC ? Colors.white : Colors.white70,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontStyle: isIC ? FontStyle.normal : FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Input command prompt
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isICInput = !_isICInput;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: _isICInput ? const Color(0xFFE53170).withValues(alpha: 0.2) : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isICInput ? const Color(0xFFE53170) : Colors.white38,
                          ),
                        ),
                        child: Text(
                          _isICInput ? 'IC' : 'OOC',
                          style: TextStyle(
                            color: _isICInput ? const Color(0xFFE53170) : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: _isICInput ? '> enter IC action command...' : '> enter OOC chat message...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                          filled: true,
                          fillColor: const Color(0xFF0F0E17),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE53170)),
                          ),
                        ),
                        onSubmitted: (_) => _onSubmit(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFFE53170)),
                      onPressed: _onSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);
    final isOnline = status == ConnectionStatus.online;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? const Color(0xFF38B000) : const Color(0xFFFF8E3C),
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? const Color(0xFF38B000) : const Color(0xFFFF8E3C)).withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
              ]
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'ONLINE' : 'LOCAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isOnline ? const Color(0xFF38B000) : const Color(0xFFFF8E3C),
              fontFamily: 'monospace',
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
