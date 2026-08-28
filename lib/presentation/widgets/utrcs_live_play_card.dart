import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/utrcs_provider.dart';
import '../../data/models/utrcs_character.dart';
import '../../data/services/utrcs_export_service.dart';
import '../screens/character_dossier_screen.dart';

class UtrcsLivePlayCard extends ConsumerWidget {
  final UtrcsCharacterModel character;

  const UtrcsLivePlayCard({
    super.key,
    required this.character,
  });

  static void show(BuildContext context, UtrcsCharacterModel character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => UtrcsLivePlayCard(character: character),
    );
  }

  void _copyExport(BuildContext context, String text, String formatName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF6E473B),
        content: Text(
          '$formatName copied to clipboard!',
          style: const TextStyle(color: Color(0xFFE1D4C2), fontFamily: 'monospace'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = character.identity;
    final mechanical = character.mechanical;
    final presentation = character.presentation;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEB5A9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Identity & Depth Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          identity.name.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E473B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${character.role.tacticalArchetype} | ${character.setting.sectorOrigin}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF291C0E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E473B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF6E473B)),
                    ),
                    child: Text(
                      'UTRCS ${character.completionDepth.name.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E473B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // High Concept Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA78D78), width: 1.2),
                ),
                child: Text(
                  '"${identity.concept}"',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF291C0E),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Psychological Anchor (Want & Fear)
              Row(
                children: [
                  Expanded(
                    child: _buildSmallBox('EXTERNAL WANT', identity.externalWant, const Color(0xFF6E473B)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSmallBox('CORE FEAR', identity.coreFear, const Color(0xFF291C0E)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capabilities Overview
              const Text(
                'ACTIVE CAPABILITIES',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E473B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              ...mechanical.capabilities.map(
                (cap) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Color(0xFF6E473B), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cap.name,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF291C0E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1D4C2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${cap.d20Modifier} D20',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E473B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Voice Sample
              if (presentation.voiceSamples.isNotEmpty) ...[
                const Text(
                  'VOICE REGISTER SAMPLE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E473B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${presentation.voiceSamples.values.first}"',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF291C0E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // OOC Boundaries
              if (presentation.oocConsentLimits.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF6E473B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF6E473B), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'OOC BOUNDARY: ${presentation.oocConsentLimits.first}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E473B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E473B),
                        foregroundColor: const Color(0xFFE1D4C2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.auto_stories, size: 16),
                      label: const Text(
                        'OPEN DOSSIER',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CharacterDossierScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6E473B),
                      side: const BorderSide(color: Color(0xFFA78D78)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('DISCORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () => _copyExport(
                      context,
                      UtrcsExportService.exportToDiscordCard(character),
                      'Discord Card',
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6E473B),
                      side: const BorderSide(color: Color(0xFFA78D78)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.data_object, size: 14),
                    label: const Text('JSON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () => _copyExport(
                      context,
                      UtrcsExportService.exportToJson(character),
                      'UTRCS JSON',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF291C0E), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
