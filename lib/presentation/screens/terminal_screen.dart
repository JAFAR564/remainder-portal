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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatHistoryProvider);
    final profile = ref.watch(playerProfileProvider);

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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isGM = msg.sender == 'Game Master';
  
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: isGM ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg.sender.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: isGM ? const Color(0xFFE53170) : const Color(0xFFFF8E3C),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isGM ? const Color(0xFF161520) : const Color(0xFF0F0E17),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isGM ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFF8E3C).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                msg.content,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
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
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: '> enter action command...',
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
