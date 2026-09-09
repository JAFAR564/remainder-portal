import 'dart:math';
import 'package:flutter/material.dart';
import 'celestial_panel.dart';

/// Celestial Astrolabe Aether Resonance Oracle Widget with D20 Divination Mechanics.
class AetherResonanceOracleWidget extends StatefulWidget {
  const AetherResonanceOracleWidget({super.key});

  @override
  State<AetherResonanceOracleWidget> createState() => _AetherResonanceOracleWidgetState();
}

class _AetherResonanceOracleWidgetState extends State<AetherResonanceOracleWidget> {
  int _lastRoll = 20;
  String _divineBlessing = 'NATURAL 20: World Arbiter grants +15% Aether Multiplier to all Sanctuary travelers!';
  bool _isCommuning = false;

  final List<String> _blessings = [
    'NATURAL 20: World Arbiter grants +15% Aether Multiplier to all Sanctuary travelers!',
    'GREAT FORTUNE: Celestial Leylines resonate. +10% Essence Affinity across Sector 4.',
    'ARBITER HARMONY: The Cardinal Scribes canonize your soul vessel rank.',
    'SACRED SHIELD: Divine Pentelic Aura protects your squad against shadow corruption.',
    'CELESTIAL TIDE: Sovereign Guild treasury taxes reduced by 2% for 24 hours.',
  ];

  void _communeWithArbiter() {
    setState(() => _isCommuning = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final rng = Random();
      final roll = rng.nextInt(20) + 1;
      final index = rng.nextInt(_blessings.length);
      setState(() {
        _lastRoll = roll;
        _divineBlessing = 'D20 ROLL: [$roll] — ${_blessings[index]}';
        _isCommuning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CelestialPanel(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Header with Flex-Safety (Fixes Defect 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF6E473B), size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'AETHER RESONANCE ORACLE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: Color(0xFF6E473B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E473B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF6E473B)),
                  ),
                  child: Text(
                    'D20 ORACLE: $_lastRoll',
                    style: const TextStyle(
                      color: Color(0xFF6E473B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Prophecy Parchment Scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1D4C2).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
              ),
              child: Text(
                _isCommuning ? 'Communing with the Cardinal Scribes...' : '“$_divineBlessing”',
                style: const TextStyle(
                  color: Color(0xFF291C0E),
                  fontSize: 11,
                  height: 1.4,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E473B),
                  foregroundColor: const Color(0xFFE1D4C2),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                icon: _isCommuning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1D4C2)),
                      )
                    : const Icon(Icons.casino_outlined, size: 16),
                label: Text(
                  _isCommuning ? 'DIVINING...' : 'COMMUNE WITH WORLD ARBITER (ROLL D20)',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                onPressed: _isCommuning ? null : _communeWithArbiter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
