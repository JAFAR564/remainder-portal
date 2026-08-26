import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/economy_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/crt_overlay.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  final _targetUserContainer = TextEditingController();
  final _offeredEnergyController = TextEditingController();

  @override
  void dispose() {
    _targetUserContainer.dispose();
    _offeredEnergyController.dispose();
    super.dispose();
  }

  void _onInitiateTrade() {
    final target = _targetUserContainer.text.trim();
    if (target.isEmpty) return;

    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;

    final energy = int.tryParse(_offeredEnergyController.text) ?? 50;

    final sampleItem = TradeItemModel(
      itemId: 'item_${DateTime.now().millisecondsSinceEpoch}',
      itemName: 'Plasma Conduit Key',
      itemGenre: 'Technology',
      baseAttributeValue: 5,
      structuralDescription: 'Access key for sector gate matrix.',
    );

    ref.read(economyProvider.notifier).initiateTrade(
          initiatorId: profile.id,
          receiverId: target,
          offeredItems: [sampleItem],
          offeredEnergy: energy,
          requestedItems: [],
          requestedEnergy: 0,
        );

    _targetUserContainer.clear();
    _offeredEnergyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tradeState = ref.watch(economyProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        title: const Text(
          'ESCROW TRADE MATRIX',
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
      ),
      body: CrtOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initiate Trade Form Card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFA78D78), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INITIATE P2P ESCROW TRADE',
                          style: TextStyle(
                            color: Color(0xFF6E473B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _targetUserContainer,
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'RECIPIENT OPERATOR ID',
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
                          controller: _offeredEnergyController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'OFFERED ENERGY CREDITS',
                            labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10),
                            filled: true,
                            fillColor: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA78D78))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E473B),
                            foregroundColor: const Color(0xFFE1D4C2),
                            minimumSize: const Size.fromHeight(38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _onInitiateTrade,
                          child: const Text('PROPOSE TRADE', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Active Escrow Trades List
                const Text(
                  'ACTIVE ESCROW LOCKS',
                  style: TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                if (tradeState.activeTrades.isEmpty) ...[
                  const Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No active trades pending escrow lock.', style: TextStyle(color: Color(0xFF291C0E), fontSize: 11)),
                      ),
                    ),
                  )
                ] else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tradeState.activeTrades.length,
                    itemBuilder: (context, index) {
                      final t = tradeState.activeTrades[index];
                      final isLocked = t.status == TradeStatus.escrowLocked;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isLocked ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TRADE ID: ${t.id}',
                                    style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isLocked ? const Color(0xFF6E473B).withValues(alpha: 0.15) : const Color(0xFFA78D78).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isLocked ? 'ESCROW LOCKED' : 'PENDING LOCK',
                                      style: TextStyle(
                                        color: isLocked ? const Color(0xFF6E473B) : const Color(0xFF291C0E),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Offered: ${t.offeredEnergy} Credits + ${t.offeredItems.length} Items', style: const TextStyle(color: Color(0xFF291C0E), fontSize: 11)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isLocked) ...[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6E473B),
                                        foregroundColor: const Color(0xFFE1D4C2),
                                      ),
                                      onPressed: () {
                                        ref.read(economyProvider.notifier).lockEscrow(t.id);
                                      },
                                      child: const Text('LOCK ESCROW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ] else ...[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6E473B),
                                        foregroundColor: const Color(0xFFE1D4C2),
                                      ),
                                      onPressed: () {
                                        if (profile != null) {
                                          ref.read(economyProvider.notifier).confirmTrade(t.id, profile.id);
                                        }
                                      },
                                      child: const Text('CONFIRM COMMIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(economyProvider.notifier).cancelTrade(t.id);
                                    },
                                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF291C0E), fontSize: 10)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
