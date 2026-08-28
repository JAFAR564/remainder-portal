import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/utrcs_provider.dart';
import '../../data/models/utrcs_character.dart';
import '../../data/models/character_sheet.dart';
import 'character_dossier_screen.dart';

class UtrcsCreationScreen extends ConsumerStatefulWidget {
  const UtrcsCreationScreen({super.key});

  @override
  ConsumerState<UtrcsCreationScreen> createState() => _UtrcsCreationScreenState();
}

class _UtrcsCreationScreenState extends ConsumerState<UtrcsCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Operator Sung');
  final _conceptCtrl = TextEditingController(text: 'Shadow Monarch & Sovereign Arbiter');
  final _archetypeCtrl = TextEditingController(text: 'Vanguard Class');
  final _wantCtrl = TextEditingController(text: 'Purge the dimensional anomaly wave');
  final _fearCtrl = TextEditingController(text: 'Total Aether resonance collapse');
  final _capNameCtrl = TextEditingController(text: 'Shadow Extraction Strike');

  CompletionDepth _selectedDepth = CompletionDepth.quick;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _conceptCtrl.dispose();
    _archetypeCtrl.dispose();
    _wantCtrl.dispose();
    _fearCtrl.dispose();
    _capNameCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final newChar = UtrcsCharacterModel(
        id: 'utrcs_${DateTime.now().millisecondsSinceEpoch}',
        completionDepth: _selectedDepth,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        identity: IdentityLayer(
          name: _nameCtrl.text.trim(),
          concept: _conceptCtrl.text.trim(),
          externalWant: _wantCtrl.text.trim(),
          coreFear: _fearCtrl.text.trim(),
          values: const ['Sovereignty', 'Discipline', 'Consensus'],
        ),
        setting: const SettingLayer(sectorOrigin: 'Sanctuary 4 (Aether Spire)'),
        role: RoleLayer(tacticalArchetype: _archetypeCtrl.text.trim()),
        mechanical: MechanicalLayer(
          baseStats: CharacterSheet(computePower: 14, shieldIntegrity: 16, energyReserve: 18),
          capabilities: [
            UtrcsCapability(
              id: 'cap_${DateTime.now().millisecondsSinceEpoch}',
              name: _capNameCtrl.text.trim().isEmpty ? 'Aether Strike' : _capNameCtrl.text.trim(),
              type: 'Active',
              scope: 'Single Target',
              cost: '2 Energy Points',
              condition: 'In Combat',
              failureState: 'Minor recoil',
              d20Modifier: 2,
            ),
          ],
        ),
        presentation: const PresentationLayer(),
      );

      ref.read(utrcsCharacterProvider.notifier).saveCharacter(newChar);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CharacterDossierScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
        title: const Text(
          'FORGE UTRCS CHARACTER',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF6E473B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6E473B).withValues(alpha: 0.12), blurRadius: 12),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIVERSAL CHARACTER ARCHITECTURE',
                      style: TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create a roleplay soul vessel with progressive psychological depth, machine-readable capabilities, and AI voice modeling.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF291C0E), height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Depth Selection
              const Text('INITIAL COMPLETION DEPTH', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E473B))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildDepthChip(CompletionDepth.quick, 'QUICK (3-MIN)'),
                  const SizedBox(width: 8),
                  _buildDepthChip(CompletionDepth.standard, 'STANDARD'),
                  const SizedBox(width: 8),
                  _buildDepthChip(CompletionDepth.deep, 'DEEP'),
                ],
              ),
              const SizedBox(height: 16),

              // Fields
              _buildTextField(_nameCtrl, 'CHARACTER NAME', 'e.g. Operator Sung', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_conceptCtrl, 'HIGH CONCEPT (ONE-LINER)', 'e.g. Shadow Monarch & Sovereign Arbiter', Icons.auto_awesome),
              const SizedBox(height: 12),
              _buildTextField(_archetypeCtrl, 'TACTICAL ARCHETYPE / CLASS', 'e.g. Vanguard Class', Icons.shield_outlined),
              const SizedBox(height: 12),
              _buildTextField(_wantCtrl, 'EXTERNAL WANT (IMMEDIATE GOAL)', 'e.g. Purge the anomaly wave', Icons.flag_outlined),
              const SizedBox(height: 12),
              _buildTextField(_fearCtrl, 'CORE FEAR (VULNERABILITY)', 'e.g. Aether depletion', Icons.warning_amber_outlined),
              const SizedBox(height: 12),
              _buildTextField(_capNameCtrl, 'PRIMARY CAPABILITY NAME', 'e.g. Shadow Extraction Strike', Icons.bolt),
              const SizedBox(height: 24),

              // Save & Depart Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E473B),
                    foregroundColor: const Color(0xFFE1D4C2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _onSave,
                  child: const Text(
                    'AWAKEN SOUL VESSEL & VIEW DOSSIER',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepthChip(CompletionDepth depth, String label) {
    final isSelected = _selectedDepth == depth;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedDepth = depth),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6E473B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFA78D78)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFE1D4C2) : const Color(0xFF6E473B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Color(0xFF291C0E), fontSize: 12, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6E473B), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBEB5A9), fontSize: 11),
        prefixIcon: Icon(icon, color: const Color(0xFF6E473B), size: 18),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFA78D78)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6E473B), width: 1.8),
        ),
      ),
      validator: (val) => (val == null || val.trim().isEmpty) ? 'Field cannot be empty' : null,
    );
  }
}
