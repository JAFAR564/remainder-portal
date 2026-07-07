import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';
import '../../services/okf_service.dart';
import '../../services/roster_cache_service.dart';

class ChronicleNode {
  final String dateStamp;
  final String title;
  final String description;
  final String faction;
  final List<String> characterRelations;
  final String expandedSummary;
  final Map<String, double> factionShifts;
  final List<Map<String, String>> transcriptLogs;

  const ChronicleNode({
    required this.dateStamp,
    required this.title,
    required this.description,
    required this.faction,
    required this.characterRelations,
    required this.expandedSummary,
    required this.factionShifts,
    required this.transcriptLogs,
  });

  Map<String, dynamic> toJson() => {
        'dateStamp': dateStamp,
        'title': title,
        'description': description,
        'faction': faction,
        'characterRelations': characterRelations,
        'expandedSummary': expandedSummary,
        'factionShifts': factionShifts,
        'transcriptLogs': transcriptLogs,
      };

  factory ChronicleNode.fromJson(Map<String, dynamic> json) => ChronicleNode(
        dateStamp: json['dateStamp'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        faction: json['faction'] ?? '',
        characterRelations: List<String>.from(json['characterRelations'] ?? []),
        expandedSummary: json['expandedSummary'] ?? '',
        factionShifts: (json['factionShifts'] as Map<dynamic, dynamic>?)?.map(
              (k, v) => MapEntry<String, double>(k.toString(), (v as num).toDouble()),
            ) ??
            {},
        transcriptLogs: (json['transcriptLogs'] as List<dynamic>?)
                ?.map((item) => Map<String, String>.from(item as Map))
                .toList() ??
            [],
      );
}

class ChroniclesNotifier extends Notifier<List<ChronicleNode>> {
  @override
  List<ChronicleNode> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final cachedJson = prefs.getString('cached_chronicle_nodes');
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        return decoded.map((item) => ChronicleNode.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      } catch (_) {
        // Fallback to initial
      }
    }
    return List.from(_initialNodes);
  }

  void addNode(ChronicleNode node) {
    final updated = [...state, node];
    state = updated;
    final prefs = ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(updated.map((n) => n.toJson()).toList());
    prefs.setString('cached_chronicle_nodes', encoded);
  }

  static const List<ChronicleNode> _initialNodes = [
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 142',
      title: 'The Great Rift Pact',
      description: 'The Factions of the Obsidian Guild and the Golden Shield sign the covenant of parchment, ending the century-long siege.',
      faction: 'Obsidian Guild & Golden Shield',
      characterRelations: ['Alistair Vance ↔ Clara Oswald (Covenant Witnesses)'],
      expandedSummary: 'Following negotiations at the summit of Obsidian, the peace accord establishes mutual trading bounds. The pact enforces absolute non-aggression under fragment checks.',
      factionShifts: {
        'Aethelgard Alliance': 15.0,
        'Elysium Syndicate': 10.0,
        'Vanguard Order': -10.0,
      },
      transcriptLogs: [
        {'author': 'Alistair Vance', 'msg': 'Let the parchment seal the borders of the Rift. We write our future in ink, not blood.'},
        {'author': 'Clara Oswald', 'msg': 'Obsidian remembers, Alistair. But for the sake of the chronicle, Elysium signs.'},
      ],
    ),
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 145',
      title: 'Celestial Spire Alignment',
      description: 'Architects align the Celestial Spire to capture harmonic energies, creating the RAG feedback loops.',
      faction: 'Chronicles',
      characterRelations: ['Jacob Vance (Spire Overseer)'],
      expandedSummary: 'The Spire channels real-time lore caches directly to the admin councils. High-frequency compiler compilation check prevents any memory fragmentation.',
      factionShifts: {
        'Aethelgard Alliance': -5.0,
        'Elysium Syndicate': 20.0,
        'Vanguard Order': 5.0,
      },
      transcriptLogs: [
        {'author': 'Jacob Vance', 'msg': 'The alignment shifts. The RAG feedback loop is anchoring to the cache.'},
        {'author': 'Lorna Stern', 'msg': 'The compiler checks are holding. No thread fragmentation detected on Impeller.'},
      ],
    ),
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 149',
      title: 'The Obsidian Fractures',
      description: 'A structural contradiction is logged in the applications. Suspicious faceclaims trigger alert protocols.',
      faction: 'Obsidian Guild',
      characterRelations: ['Unknown Claimant ↔ Alistair Vance (Disputed Lineage)'],
      expandedSummary: 'A rogue application bypasses standard compliance checks, claiming alignment with House Vance. DeepSeek-V4 audits highlight chronological contradictions.',
      factionShifts: {
        'Aethelgard Alliance': -10.0,
        'Elysium Syndicate': -15.0,
        'Vanguard Order': 25.0,
      },
      transcriptLogs: [
        {'author': 'Unknown Claimant', 'msg': 'I bear the Vance signature fragment. The gate must admit my claim.'},
        {'author': 'Alistair Vance', 'msg': 'This is a contradiction. The lineage record has no space for your token.'},
      ],
    ),
  ];
}

final chroniclesProvider = NotifierProvider<ChroniclesNotifier, List<ChronicleNode>>(() {
  return ChroniclesNotifier();
});

class ChroniclesScreen extends ConsumerStatefulWidget {
  const ChroniclesScreen({super.key});

  @override
  ConsumerState<ChroniclesScreen> createState() => _ChroniclesScreenState();
}

class _ChroniclesScreenState extends ConsumerState<ChroniclesScreen> {
  ChronicleNode? _expandedNode;
  bool _isGeneratingDraft = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(chroniclesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'THE CHRONICLES TIMELINE',
          style: PortalTheme.statsText.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PortalTheme.charcoalNearBlackText),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                if (_isGeneratingDraft)
                  const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0, color: PortalTheme.tealNavyAccent),
                  )
                else
                  SpringTapWrapper(
                    onTap: _triggerAICronDraft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: PortalTheme.tealNavyAccent),
                        borderRadius: BorderRadius.circular(4.0),
                        color: PortalTheme.tealNavyAccent.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        'AI DRAFT',
                        style: PortalTheme.statsText.copyWith(
                          color: PortalTheme.tealNavyAccent,
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: IridescentOverlay(
        child: SafeArea(
          child: Row(
            children: [
              // Main Timeline Thread
              Expanded(
                flex: 6,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    final isExpanded = _expandedNode == node;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vertical Timeline Thread Line and Indicator Node
                          Column(
                            children: [
                              Container(
                                width: 12.0,
                                height: 12.0,
                                decoration: const BoxDecoration(
                                  color: PortalTheme.tealNavyAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: PortalTheme.tealNavyAccent,
                                      blurRadius: 8.0,
                                    )
                                  ]
                                ),
                              ),
                              if (index != nodes.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2.0,
                                    color: PortalTheme.silverGrayBorder,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 24.0),

                          // Node Content Card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: SpringTapWrapper(
                                onTap: () {
                                  setState(() {
                                    _expandedNode = isExpanded ? null : node;
                                  });
                                },
                                child: GlassCard(
                                  backgroundColor: isExpanded
                                      ? PortalTheme.lightGraySurface
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          node.dateStamp,
                                          style: PortalTheme.statsText.copyWith(
                                            fontSize: 10.0,
                                            color: PortalTheme.infoSlate,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        Row(
                                          children: [
                                            Container(
                                              width: 24.0,
                                              height: 2.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFD700),
                                                borderRadius: BorderRadius.circular(1.0),
                                              ),
                                            ),
                                            const SizedBox(width: 3.0),
                                            Container(
                                              width: 24.0,
                                              height: 2.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFB388FF),
                                                borderRadius: BorderRadius.circular(1.0),
                                              ),
                                            ),
                                            const SizedBox(width: 3.0),
                                            Container(
                                              width: 24.0,
                                              height: 2.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF66BB6A),
                                                borderRadius: BorderRadius.circular(1.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          node.title,
                                          style: PortalTheme.sectionHeader.copyWith(fontSize: 20.0),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          node.description,
                                          style: PortalTheme.bodyText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const VerticalDivider(width: 1),

              // Side Faction & Factions relationships overview
              Expanded(
                flex: 4,
                child: _expandedNode != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHRONICLE ANALYSIS',
                              style: PortalTheme.statsText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PortalTheme.warmGrayBodyText,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            Text(
                              _expandedNode!.title,
                              style: PortalTheme.displayHeadline.copyWith(fontSize: 24.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'FACTIONS INVOLVED: ${_expandedNode!.faction}',
                              style: PortalTheme.statsText.copyWith(color: PortalTheme.tealNavyAccent),
                            ),
                            const SizedBox(height: 24.0),
                            const Divider(),
                            const SizedBox(height: 24.0),
                            Text(
                              'DETAILED HISTORICAL SUMMARY',
                              style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              _expandedNode!.expandedSummary,
                              style: PortalTheme.bodyText.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 24.0),
                            Text(
                              'CHARACTER RELATIONSHIP SHIFTS',
                              style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText),
                            ),
                            const SizedBox(height: 8.0),
                            ..._expandedNode!.characterRelations.map((rel) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(rel, style: PortalTheme.bodyText),
                              );
                            }),
                            const SizedBox(height: 24.0),
                            const Divider(),
                            const SizedBox(height: 24.0),
                            Text(
                              'FACTION INFLUENCE SHIFTS',
                              style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.warmGrayBodyText),
                            ),
                            const SizedBox(height: 12.0),
                            ..._expandedNode!.factionShifts.entries.map((entry) {
                              final factionName = entry.key;
                              final shiftVal = entry.value;
                              final isPositive = shiftVal >= 0;
                              final color = isPositive ? const Color(0xFF66BB6A) : PortalTheme.alertTerracotta;
                              final shiftText = '${isPositive ? "+" : ""}${shiftVal.toInt()}%';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(factionName, style: PortalTheme.bodyText.copyWith(fontSize: 11.0)),
                                        Text(shiftText, style: PortalTheme.statsText.copyWith(fontSize: 11.0, color: color, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Container(
                                      height: 4.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: PortalTheme.silverGrayBorder.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(2.0),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: (shiftVal.abs() / 30.0).clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(2.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 24.0),
                            const Divider(),
                            const SizedBox(height: 24.0),
                            SpringTapWrapper(
                              onTap: () => _showOriginalTranscriptDialog(context, _expandedNode!),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: PortalTheme.tealNavyAccent.withValues(alpha: 0.15),
                                  border: Border.all(color: PortalTheme.tealNavyAccent.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.history_edu, size: 16.0, color: PortalTheme.tealNavyAccent),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      'VIEW ORIGINAL SCENE LOGS',
                                      style: PortalTheme.statsText.copyWith(
                                        color: PortalTheme.tealNavyAccent,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          'Tap a node to analyze historical context.',
                          style: PortalTheme.bodyText,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerAICronDraft() async {
    setState(() => _isGeneratingDraft = true);
    bool apiWorks = false;
    String errorLog = '';

    try {
      final okf = ref.read(okfServiceProvider);
      // Execute the query check to verify if the Cloud Run AI proxy responds
      await okf.queryLoreContext(
        answerText: 'Assemble chronological timeline updates from sector activity logs.',
        queryIntent: 'Synthesize recent chronicle nodes from active play rooms.',
      ).timeout(const Duration(seconds: 4));
      apiWorks = true;
    } catch (e) {
      errorLog = e.toString();
    }

    setState(() => _isGeneratingDraft = false);

    if (!mounted) return;

    // Show connection diagnostic and options to generate simulation draft
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      apiWorks ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: apiWorks ? const Color(0xFF66BB6A) : PortalTheme.alertTerracotta,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      apiWorks ? 'AI ROUTER: ONLINE' : 'AI ROUTER: OFFLINE',
                      style: PortalTheme.statsText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: apiWorks ? const Color(0xFF66BB6A) : PortalTheme.alertTerracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  apiWorks
                      ? 'Gemini 1.5 Pro narrative synthesis engine connected and operating successfully.'
                      : 'The remote AI Proxy service is currently unreachable (using fallback simulation).',
                  style: PortalTheme.bodyText.copyWith(fontSize: 12.0),
                ),
                if (!apiWorks) ...[
                  const SizedBox(height: 12.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'Diagnostic Log:\n$errorLog',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10.0,
                        color: PortalTheme.alertTerracotta,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: PortalTheme.silverGrayBorder),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: PortalTheme.charcoalNearBlackText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: SpringTapWrapper(
                        onTap: () {
                          Navigator.of(context).pop();
                          _addSimulationDraftNode();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: PortalTheme.tealNavyAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'DRAFT EVENT',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSimulationDraftNode() {
    final nodes = ref.read(chroniclesProvider);
    final year = 149 + nodes.length - 2;
    ref.read(chroniclesProvider.notifier).addNode(
      ChronicleNode(
        dateStamp: 'ERA 3 • YEAR $year',
        title: 'AI Synthesis: Sector Convergence',
        description: 'A structural alignment shift is detected across active sectors. Factions deploy scouts to coordinate boundary nodes.',
        faction: 'Vanguard Order & Elysium Syndicate',
        characterRelations: ['Jacob Vance ↔ Lorna Stern (Grid Coordinates Calibration)'],
        expandedSummary: 'Recent roleplay logs indicate collaborative mapping actions between Vanguard scouts and Elysium archivists. System checks confirm database sync with local cache.',
        factionShifts: {
          'Aethelgard Alliance': -5.0,
          'Elysium Syndicate': 15.0,
          'Vanguard Order': 10.0,
        },
        transcriptLogs: [
          {'author': 'Jacob Vance', 'msg': 'Scout coordinates received. Adjusting the Spire array feedback parameters.'},
          {'author': 'Lorna Stern', 'msg': 'Sync holding. RAG pipelines showing zero discrepancies with the cache.'},
        ],
      ),
    );
  }

  void _showOriginalTranscriptDialog(BuildContext context, ChronicleNode node) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500.0),
          child: GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORIGINAL CHRONICLE SCENE LOGS',
                  style: PortalTheme.statsText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PortalTheme.tealNavyAccent,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Immutable narrative records captured during play convergence.',
                  style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: node.transcriptLogs.length,
                    itemBuilder: (context, idx) {
                      final log = node.transcriptLogs[idx];
                      final author = log['author'] ?? 'Unknown';
                      final msg = log['msg'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.toUpperCase(),
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                color: PortalTheme.infoSlate,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              msg,
                              style: PortalTheme.bodyText.copyWith(fontSize: 12.0),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                SpringTapWrapper(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: PortalTheme.tealNavyAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'CLOSE LOGS ARCHIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
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
