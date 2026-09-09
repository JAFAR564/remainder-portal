import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/utrcs_character.dart';

/// Ornate 8-Register Voice Player & Cadence Widget for UTRCS Characters.
class VoiceRegisterPlayerWidget extends StatefulWidget {
  final PresentationLayer presentation;
  final String characterName;

  const VoiceRegisterPlayerWidget({
    super.key,
    required this.presentation,
    this.characterName = 'Operator',
  });

  @override
  State<VoiceRegisterPlayerWidget> createState() => _VoiceRegisterPlayerWidgetState();
}

class _VoiceRegisterData {
  final String key;
  final String label;
  final IconData icon;
  final String defaultQuote;
  final String cadenceInfo;

  const _VoiceRegisterData({
    required this.key,
    required this.label,
    required this.icon,
    required this.defaultQuote,
    required this.cadenceInfo,
  });
}

class _VoiceRegisterPlayerWidgetState extends State<VoiceRegisterPlayerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedRegisterIndex = 0;
  bool _isPlaying = false;

  static const List<_VoiceRegisterData> _registers = [
    _VoiceRegisterData(
      key: 'formal',
      label: 'Formal / Sovereign',
      icon: Icons.account_balance_outlined,
      defaultQuote: 'By the decree of the Sovereign Core, this Sanctuary shall remain unyielding against the void.',
      cadenceInfo: 'Resolute • Measured Cadence • High Dignity',
    ),
    _VoiceRegisterData(
      key: 'battle',
      label: 'Battle / High-Intensity',
      icon: Icons.flash_on_outlined,
      defaultQuote: 'Shields up! Leyline rupture in Sector 4—hold the frontline at all costs!',
      cadenceInfo: 'Staccato • High Urgency • Fortissimo',
    ),
    _VoiceRegisterData(
      key: 'intimate',
      label: 'Intimate / Low Whisper',
      icon: Icons.favorite_border,
      defaultQuote: 'Even when the aether dims... I will not forget what we swore beneath the spire.',
      cadenceInfo: 'Soft • Vulnerable Cadence • Pianissimo',
    ),
    _VoiceRegisterData(
      key: 'broken',
      label: 'Broken / Grief',
      icon: Icons.sentiment_very_dissatisfied_outlined,
      defaultQuote: 'We fought for consensus... yet the ashes feel just as cold. How much more can we bleed?',
      cadenceInfo: 'Fragmented • Trembling • Grief Resonance',
    ),
    _VoiceRegisterData(
      key: 'analytical',
      label: 'Analytical / Cold',
      icon: Icons.psychology_alt_outlined,
      defaultQuote: 'Compute reserve at 14%. Probability of containment failure within three standard cycles.',
      cadenceInfo: 'Even Pitch • Monotone Precision • Detached',
    ),
    _VoiceRegisterData(
      key: 'casual',
      label: 'Casual / Campfire',
      icon: Icons.fireplace_outlined,
      defaultQuote: 'Pass the rations. If we survive tomorrow, the first round of aether brew is on me.',
      cadenceInfo: 'Warm • Relaxed Cadence • Comradely',
    ),
    _VoiceRegisterData(
      key: 'ritual',
      label: 'Ritual / Incantation',
      icon: Icons.auto_awesome_outlined,
      defaultQuote: 'Aetheromaru, Kami-Aether... heed the call of the Wanderer. Weave the severance veil.',
      cadenceInfo: 'Harmonic • Resonant Chant • Celestial Vow',
    ),
    _VoiceRegisterData(
      key: 'sardonic',
      label: 'Sardonic / Defiant',
      icon: Icons.sentiment_neutral_outlined,
      defaultQuote: 'You call this a god? I have crushed sturdier algorithms beneath my boot.',
      cadenceInfo: 'Biting Irony • Defiant Smirk • Edge Accent',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animController.reverse();
        } else if (status == AnimationStatus.dismissed && _isPlaying) {
          _animController.forward();
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animController.forward();
      } else {
        _animController.stop();
      }
    });
  }

  void _copyQuote(BuildContext context, String text, String registerLabel) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF6E473B),
        content: Text(
          '$registerLabel quote copied to clipboard!',
          style: const TextStyle(color: Color(0xFFE1D4C2), fontFamily: 'monospace'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getActiveQuote(_VoiceRegisterData reg) {
    if (widget.presentation.voiceSamples.containsKey(reg.key)) {
      return widget.presentation.voiceSamples[reg.key]!;
    }
    // Also check case-insensitive match
    for (final entry in widget.presentation.voiceSamples.entries) {
      if (entry.key.toLowerCase() == reg.key.toLowerCase()) {
        return entry.value;
      }
    }
    return reg.defaultQuote;
  }

  @override
  Widget build(BuildContext context) {
    final currentReg = _registers[_selectedRegisterIndex];
    final activeQuote = _getActiveQuote(currentReg);

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
                  Icon(Icons.graphic_eq, size: 18, color: Color(0xFF6E473B)),
                  SizedBox(width: 8),
                  Text(
                    '8-REGISTER VOICE PLAYER',
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
                  '${_selectedRegisterIndex + 1} OF 8 REGISTERS',
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

          // Register Selector Scroll Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _registers.asMap().entries.map((entry) {
                final idx = entry.key;
                final reg = entry.value;
                final isSelected = idx == _selectedRegisterIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRegisterIndex = idx;
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
                      ),
                      child: Row(
                        children: [
                          Icon(
                            reg.icon,
                            size: 13,
                            color: isSelected ? const Color(0xFFE1D4C2) : const Color(0xFF6E473B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reg.label.split(' / ').first.toUpperCase(),
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

          // Active Quote Parchment Box
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentReg.label.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E473B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      currentReg.cadenceInfo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        color: Color(0xFFA78D78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Spoken Quote
                Text(
                  '"$activeQuote"',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: Color(0xFF291C0E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Simulated Audio Waveform Bar Visualizer
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return SizedBox(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(14, (i) {
                          final phase = (i * 0.45);
                          final animValue = _isPlaying
                              ? math.sin(_animController.value * 2 * math.pi + phase).abs()
                              : 0.2;
                          final barHeight = 4 + (animValue * 18);

                          return Container(
                            width: 3.5,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: _isPlaying ? const Color(0xFF6E473B) : const Color(0xFFBEB5A9),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Player Control Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _togglePlayback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E473B),
                    foregroundColor: const Color(0xFFE1D4C2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 16),
                  label: Text(
                    _isPlaying ? 'PAUSE CADENCE' : 'PLAY VOICE CADENCE',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _copyQuote(context, activeQuote, currentReg.label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6E473B),
                  side: const BorderSide(color: Color(0xFFA78D78)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy, size: 14),
                label: const Text(
                  'COPY QUOTE',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
