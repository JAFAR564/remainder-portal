import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';

class ChronicleNode {
  final String dateStamp;
  final String title;
  final String description;
  final String faction;
  final List<String> characterRelations;
  final String expandedSummary;

  const ChronicleNode({
    required this.dateStamp,
    required this.title,
    required this.description,
    required this.faction,
    required this.characterRelations,
    required this.expandedSummary,
  });
}

class ChroniclesScreen extends StatefulWidget {
  const ChroniclesScreen({super.key});

  @override
  State<ChroniclesScreen> createState() => _ChroniclesScreenState();
}

class _ChroniclesScreenState extends State<ChroniclesScreen> {
  ChronicleNode? _expandedNode;

  final List<ChronicleNode> _nodes = const [
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 142',
      title: 'The Great Rift Pact',
      description: 'The Factions of the Obsidian Guild and the Golden Shield sign the covenant of parchment, ending the century-long siege.',
      faction: 'Obsidian Guild & Golden Shield',
      characterRelations: ['Alistair Vance ↔ Clara Oswald (Covenant Witnesses)'],
      expandedSummary: 'Following negotiations at the summit of Obsidian, the peace accord establishes mutual trading bounds. The pact enforces absolute non-aggression under fragment checks.',
    ),
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 145',
      title: 'Erecting the Celestial Spire',
      description: 'Architects align the iridescent spire to capture harmonic energies, creating the RAG feedback loops.',
      faction: 'Chronicles',
      characterRelations: ['Jacob Vance (Spire Overseer)'],
      expandedSummary: 'The Spire channels real-time lore caches directly to the admin councils. High-frequency compiler compilation check prevents any memory fragmentation.',
    ),
    ChronicleNode(
      dateStamp: 'ERA 3 • YEAR 149',
      title: 'The Obsidian Fractures',
      description: 'A structural contradiction is logged in the applications. Suspicious faceclaims trigger alert protocols.',
      faction: 'Obsidian Guild',
      characterRelations: ['Unknown Claimant ↔ Alistair Vance (Disputed Lineage)'],
      expandedSummary: 'A rogue application bypasses standard compliance checks, claiming alignment with House Vance. DeepSeek-V4 audits highlight chronological contradictions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  itemCount: _nodes.length,
                  itemBuilder: (context, index) {
                    final node = _nodes[index];
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
                              if (index != _nodes.length - 1)
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
}
