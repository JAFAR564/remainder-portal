import 'package:flutter/material.dart';
import '../../data/models/utrcs_character.dart';

/// Interactive 8-Stage Cognitive Processing Loop Widget for UTRCS Characters and AI GM.
class CognitiveLoopTimelineWidget extends StatefulWidget {
  final UtrcsCharacterModel character;

  const CognitiveLoopTimelineWidget({
    super.key,
    required this.character,
  });

  @override
  State<CognitiveLoopTimelineWidget> createState() => _CognitiveLoopTimelineWidgetState();
}

class _CognitiveStageInfo {
  final int stageNumber;
  final String title;
  final String shortCode;
  final String subtitle;
  final String description;
  final IconData icon;

  const _CognitiveStageInfo({
    required this.stageNumber,
    required this.title,
    required this.shortCode,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

class _CognitiveLoopTimelineWidgetState extends State<CognitiveLoopTimelineWidget> {
  int _activeStage = 1;

  static const List<_CognitiveStageInfo> _stages = [
    _CognitiveStageInfo(
      stageNumber: 1,
      title: 'Sensory Intake & Perception',
      shortCode: 'S1',
      subtitle: 'Filtering raw environmental stimuli through baseline senses',
      description: 'Incoming narrative cues, environmental shifts, and threat proximity pass through the character\'s physical constitution and sensory thresholds.',
      icon: Icons.visibility_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 2,
      title: 'Appraisal & Core Fear',
      shortCode: 'S2',
      subtitle: 'Threat evaluation filtered through internal trauma & vulnerability',
      description: 'The mind tests current stimuli against the character\'s Core Fear and Internal Lie to determine emotional urgency.',
      icon: Icons.crisis_alert_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 3,
      title: 'Want vs. Need Arbitration',
      shortCode: 'S3',
      subtitle: 'Conscious ambition weighed against spiritual truth',
      description: 'The internal struggle between what the character wants in the moment versus what they systemically need to overcome their wound.',
      icon: Icons.balance_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 4,
      title: 'Ethical & Value Filter',
      shortCode: 'S4',
      subtitle: 'Screening potential responses against moral principles',
      description: 'Evaluating planned courses of action against the character\'s core values and observing any behavioral contradictions.',
      icon: Icons.shield_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 5,
      title: 'Capability & Cost Calculation',
      shortCode: 'S5',
      subtitle: 'Assessing power mechanics, energy costs, and failure stakes',
      description: 'Calculating the mechanical capability to activate, verifying available resource reserves, and acknowledging backlash if the action fails.',
      icon: Icons.bolt_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 6,
      title: 'Voice & Intent Formulation',
      shortCode: 'S6',
      subtitle: 'Selecting dialogue register, syntax cadence, and nonverbal tells',
      description: 'Shaping how the action is communicated in-character, applying vocal register syntax, and expressing subconscious body language.',
      icon: Icons.record_voice_over_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 7,
      title: 'D20 Action Execution',
      shortCode: 'S7',
      subtitle: 'Committing the deed to the world with deterministic resolution',
      description: 'The action is committed to the shared narrative chronicle and adjudicated by a D20 check with roleplay modifiers.',
      icon: Icons.casino_outlined,
    ),
    _CognitiveStageInfo(
      stageNumber: 8,
      title: 'Memory & Belief Integration',
      shortCode: 'S8',
      subtitle: 'Updating relationship web, emotional scars, and canon lore',
      description: 'The consequence of the action is permanently written into SQLite memory, altering relationship trust levels and psychological balance.',
      icon: Icons.auto_stories_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _stages[_activeStage - 1];
    final identity = widget.character.identity;
    final presentation = widget.character.presentation;
    final mechanical = widget.character.mechanical;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline, size: 18, color: Color(0xFF6E473B)),
                  SizedBox(width: 8),
                  Text(
                    '8-STAGE COGNITIVE PROCESSING LOOP',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF6E473B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6E473B)),
                ),
                child: Text(
                  'STAGE $_activeStage OF 8',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E473B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper Node Chips (1 - 8)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _stages.map((stage) {
                final isSelected = stage.stageNumber == _activeStage;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _activeStage = stage.stageNumber;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6E473B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6E473B) : const Color(0xFFA78D78),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6E473B).withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            stage.icon,
                            size: 13,
                            color: isSelected ? const Color(0xFFE1D4C2) : const Color(0xFF6E473B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stage.shortCode,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFE1D4C2) : const Color(0xFF291C0E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Active Stage Detail Card
          Container(
            width: double.infinity,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(current.icon, color: const Color(0xFF6E473B), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STAGE ${current.stageNumber}: ${current.title.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E473B),
                            ),
                          ),
                          Text(
                            current.subtitle,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFFA78D78),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  current.description,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF291C0E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Live Character Attribute Hook
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE PROFILE INTEGRATION',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6E473B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStageDataHook(current.stageNumber, identity, presentation, mechanical),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Step Forward Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _activeStage > 1
                    ? () {
                        setState(() {
                          _activeStage--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back, size: 14),
                label: const Text('PREVIOUS', style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6E473B),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _activeStage = (_activeStage % 8) + 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.sync, size: 14),
                label: Text(
                  _activeStage == 8 ? 'RESET TO STAGE 1' : 'NEXT STAGE (${_activeStage + 1}/8)',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageDataHook(
    int stage,
    IdentityLayer identity,
    PresentationLayer presentation,
    MechanicalLayer mechanical,
  ) {
    switch (stage) {
      case 1:
        return Text(
          'Sensory baseline: "${identity.defaultBaseline ?? 'Soul Vessel Standard Awakening'}" | Wound Anchor: "${identity.coreWound ?? 'None'}"',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E), fontStyle: FontStyle.italic),
        );
      case 2:
        return Text(
          'Core Fear: "${identity.coreFear}" | Internal Lie: "${identity.internalLie ?? 'None recorded'}"',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E), fontStyle: FontStyle.italic),
        );
      case 3:
        return Text(
          'Conscious Want: "${identity.externalWant}" vs. Internal Need: "${identity.internalNeed ?? 'Unawakened'}"',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E), fontStyle: FontStyle.italic),
        );
      case 4:
        final values = identity.values.isNotEmpty ? identity.values.join(', ') : 'Honor, Vigilance';
        return Text(
          'Values: $values | Contradictions: ${identity.contradictions.length} recorded',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E)),
        );
      case 5:
        final caps = mechanical.capabilities.isNotEmpty
            ? mechanical.capabilities.map((c) => c.name).join(', ')
            : 'No active capabilities forged';
        return Text(
          'Active Powers: $caps | Defense: ${mechanical.baseStats.shieldIntegrity} HP',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E)),
        );
      case 6:
        final tell = presentation.nonverbalTells.isNotEmpty ? presentation.nonverbalTells.first : 'Subtle aura pulse';
        return Text(
          'Syntax: "${presentation.voiceSyntax}" | Nonverbal Tell: "$tell"',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E), fontStyle: FontStyle.italic),
        );
      case 7:
        final mod = mechanical.capabilities.isNotEmpty ? mechanical.capabilities.first.d20Modifier : 2;
        return Text(
          'Rule Engine: D20 + $mod Check vs DC 12 Challenge Rating with fail-forward branch.',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E)),
        );
      case 8:
      default:
        final bonds = widget.character.relationships.length;
        return Text(
          'SQLite Chronicle: Updates $bonds relationship bonds and records memory into Drift DB.',
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF291C0E)),
        );
    }
  }
}
