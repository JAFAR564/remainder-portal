import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/utrcs_provider.dart';
import '../../data/models/utrcs_character.dart';
import '../../data/services/utrcs_export_service.dart';
import '../widgets/utrcs_live_play_card.dart';

class CharacterDossierScreen extends ConsumerStatefulWidget {
  const CharacterDossierScreen({super.key});

  @override
  ConsumerState<CharacterDossierScreen> createState() => _CharacterDossierScreenState();
}

class _CharacterDossierScreenState extends ConsumerState<CharacterDossierScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showExportDialog(BuildContext context, UtrcsCharacterModel character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFA78D78), width: 1.8),
        ),
        title: const Text(
          'PORTABLE UTRCS EXPORT',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6E473B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an export format to copy your character sheet for Discord, community forums, or external VTTs.',
              style: TextStyle(fontSize: 11, color: Color(0xFF291C0E)),
            ),
            const SizedBox(height: 14),
            _buildExportOption(
              context,
              title: 'Discord Markdown Card',
              subtitle: 'Formatted with blockquotes & spoiler tags for chat channels',
              onTap: () {
                Clipboard.setData(ClipboardData(text: UtrcsExportService.exportToDiscordCard(character)));
                Navigator.pop(context);
                _showCopiedSnackbar('Discord Card');
              },
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              context,
              title: 'Full Markdown Dossier',
              subtitle: 'Comprehensive 6-layer document for forums & lore vaults',
              onTap: () {
                Clipboard.setData(ClipboardData(text: UtrcsExportService.exportToMarkdown(character)));
                Navigator.pop(context);
                _showCopiedSnackbar('Markdown Dossier');
              },
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              context,
              title: 'Machine-Readable UTRCS JSON',
              subtitle: 'Schema v1.0.0 JSON document for automated import',
              onTap: () {
                Clipboard.setData(ClipboardData(text: UtrcsExportService.exportToJson(character)));
                Navigator.pop(context);
                _showCopiedSnackbar('UTRCS JSON');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF6E473B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCopiedSnackbar(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF6E473B),
        content: Text('$format copied to clipboard!', style: const TextStyle(color: Color(0xFFE1D4C2))),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, {required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.copy, size: 16, color: Color(0xFF6E473B)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontFamily: 'serif', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF6E473B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCapabilityDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final scopeCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final condCtrl = TextEditingController();
    final failCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFA78D78), width: 1.8),
        ),
        title: const Text(
          'FORGE NEW CAPABILITY',
          style: TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Capability Name (e.g. Arcane Ward)'),
              ),
              TextField(
                controller: scopeCtrl,
                decoration: const InputDecoration(labelText: 'Scope (e.g. 5m Radius / Allies)'),
              ),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Cost (e.g. 3 Energy Points)'),
              ),
              TextField(
                controller: condCtrl,
                decoration: const InputDecoration(labelText: 'Condition (e.g. Shield active)'),
              ),
              TextField(
                controller: failCtrl,
                decoration: const InputDecoration(labelText: 'Failure State (e.g. Stun 1 round)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E473B),
              foregroundColor: const Color(0xFFE1D4C2),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(utrcsCharacterProvider.notifier).addCapability(
                      UtrcsCapability(
                        id: 'cap_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        type: 'Active',
                        scope: scopeCtrl.text.trim().isEmpty ? 'Direct Target' : scopeCtrl.text.trim(),
                        cost: costCtrl.text.trim().isEmpty ? '2 Energy' : costCtrl.text.trim(),
                        condition: condCtrl.text.trim().isEmpty ? 'In Combat' : condCtrl.text.trim(),
                        failureState: failCtrl.text.trim().isEmpty ? 'None' : failCtrl.text.trim(),
                        d20Modifier: 2,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('FORGE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(utrcsCharacterProvider);

    if (character == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE1D4C2),
        appBar: AppBar(title: const Text('UTRCS DOSSIER')),
        body: const Center(child: Text('No active UTRCS character profile.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        title: Text(
          '${character.identity.name.toUpperCase()} (DOSSIER)',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6E473B),
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined, color: Color(0xFF6E473B)),
            tooltip: 'At-a-Glance Live Card',
            onPressed: () => UtrcsLivePlayCard.show(context, character),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF6E473B)),
            tooltip: 'Export UTRCS',
            onPressed: () => _showExportDialog(context, character),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6E473B),
          unselectedLabelColor: const Color(0xFFA78D78),
          indicatorColor: const Color(0xFF6E473B),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'CAPABILITIES'),
            Tab(text: 'PSYCHOLOGY'),
            Tab(text: 'LORE & BONDS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, character),
          _buildCapabilitiesTab(context, character),
          _buildPsychologyTab(context, character),
          _buildLoreTab(context, character),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, UtrcsCharacterModel character) {
    final identity = character.identity;
    final role = character.role;
    final setting = character.setting;
    final stats = character.mechanical.baseStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // High Concept Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6E473B).withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      identity.name.toUpperCase(),
                      style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF6E473B)),
                      ),
                      child: Text(
                        'DEPTH: ${character.completionDepth.name.toUpperCase()}',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${role.tacticalArchetype} • Origin: ${setting.sectorOrigin}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                ),
                const SizedBox(height: 12),
                Text(
                  identity.concept,
                  style: const TextStyle(fontFamily: 'serif', fontSize: 13, height: 1.4, color: Color(0xFF291C0E), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progressive Depth Enhancement Banner
          if (character.completionDepth != CompletionDepth.deep) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1D4C2).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA78D78)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upgrade, color: Color(0xFF6E473B)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Deepen character psychology and expand capabilities to Standard/Deep level.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF291C0E)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E473B),
                      foregroundColor: const Color(0xFFE1D4C2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () {
                      final newDepth = character.completionDepth == CompletionDepth.quick
                          ? CompletionDepth.standard
                          : CompletionDepth.deep;
                      ref.read(utrcsCharacterProvider.notifier).setCompletionDepth(newDepth);
                    },
                    child: const Text('DEEPEN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Base Attribute Readouts
          const Text('SOVEREIGN VESSEL ATTRIBUTES', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatBadge('SHIELD (HP)', '${stats.shieldIntegrity}', const Color(0xFF6E473B))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBadge('AETHER (MP)', '${stats.energyReserve}', const Color(0xFFA78D78))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatBadge('COMPUTE (SP)', '${stats.computePower}', const Color(0xFF291C0E))),
            ],
          ),
          const SizedBox(height: 16),

          // Want / Fear Section
          _buildInfoTile('EXTERNAL WANT', identity.externalWant, Icons.flag_outlined),
          const SizedBox(height: 8),
          _buildInfoTile('CORE FEAR', identity.coreFear, Icons.warning_amber_rounded),
          const SizedBox(height: 8),
          if (identity.defaultBaseline != null)
            _buildInfoTile('DOWNTIME BASELINE', identity.defaultBaseline!, Icons.bedtime_outlined),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesTab(BuildContext context, UtrcsCharacterModel character) {
    final capabilities = character.mechanical.capabilities;
    final weaknesses = character.mechanical.weaknesses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CAPABILITY MATRIX (${capabilities.length})',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('ADD SKILL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                onPressed: () => _showAddCapabilityDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...capabilities.map(
            (cap) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6E473B).withValues(alpha: 0.08), blurRadius: 8),
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
                          const Icon(Icons.bolt, color: Color(0xFF6E473B), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            cap.name,
                            style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF291C0E)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF6E473B)),
                        ),
                        child: Text(
                          '+${cap.d20Modifier} D20 CHECK',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCapRow('Scope', cap.scope),
                  _buildCapRow('Cost', cap.cost),
                  _buildCapRow('Condition', cap.condition),
                  _buildCapRow('Failure State', cap.failureState),
                ],
              ),
            ),
          ),

          if (weaknesses.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'INHERENT WEAKNESSES & EXPLOITS',
              style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
            ),
            const SizedBox(height: 8),
            ...weaknesses.map(
              (w) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.name,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                    ),
                    const SizedBox(height: 4),
                    Text(w.description, style: const TextStyle(fontSize: 11, color: Color(0xFF291C0E))),
                    const SizedBox(height: 2),
                    Text('Invocable by: ${w.invocableBy}', style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFFA78D78))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPsychologyTab(BuildContext context, UtrcsCharacterModel character) {
    final identity = character.identity;
    final presentation = character.presentation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('INTERNAL CONFLICT & PSYCHOLOGY', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 8),
          if (identity.coreWound != null) _buildInfoTile('CORE WOUND', identity.coreWound!, Icons.healing_outlined),
          const SizedBox(height: 8),
          if (identity.internalLie != null) _buildInfoTile('INTERNAL LIE', identity.internalLie!, Icons.visibility_off_outlined),
          const SizedBox(height: 8),
          if (identity.internalNeed != null) _buildInfoTile('INTERNAL NEED', identity.internalNeed!, Icons.favorite_outline),
          const SizedBox(height: 14),

          if (identity.contradictions.isNotEmpty) ...[
            const Text('PSYCHOLOGICAL CONTRADICTIONS', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
            const SizedBox(height: 6),
            ...identity.contradictions.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_alt, size: 14, color: Color(0xFF6E473B)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 11, color: Color(0xFF291C0E)))),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
          ],

          const Text('VOICE SYNTAX & CADENCE', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
            ),
            child: Text(presentation.voiceSyntax, style: const TextStyle(fontSize: 11, color: Color(0xFF291C0E))),
          ),
          const SizedBox(height: 14),

          const Text('DIALOGUE REGISTER SAMPLES', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 6),
          ...presentation.voiceSamples.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E473B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFE1D4C2)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('"${entry.value}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF291C0E))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLoreTab(BuildContext context, UtrcsCharacterModel character) {
    final relationships = character.relationships;
    final oocLimits = character.presentation.oocConsentLimits;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRIPARTITE RELATIONSHIP WEB', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 8),
          if (relationships.isEmpty)
            const Text('No relationships recorded yet. Form bonds in expeditions.', style: TextStyle(fontSize: 11, color: Color(0xFF6E473B))),
          ...relationships.map(
            (rel) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: Color(0xFF6E473B), size: 16),
                      const SizedBox(width: 6),
                      Text(rel.targetName, style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF291C0E))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildRelRow('IC Belief', rel.icBelief),
                  _buildRelRow('Canon Fact', rel.establishedFact),
                  _buildRelRow('OOC Consent', rel.oocAgreement),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text('OOC CONSENT & CONTENT BOUNDARIES', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
          const SizedBox(height: 8),
          ...oocLimits.map((limit) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, color: Color(0xFF6E473B), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(limit, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF291C0E)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF291C0E))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6E473B)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
                const SizedBox(height: 2),
                Text(content, style: const TextStyle(fontSize: 11, color: Color(0xFF291C0E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(fontSize: 10, color: Color(0xFF291C0E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              '$title:',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(fontSize: 10, color: Color(0xFF291C0E)),
            ),
          ),
        ],
      ),
    );
  }
}
