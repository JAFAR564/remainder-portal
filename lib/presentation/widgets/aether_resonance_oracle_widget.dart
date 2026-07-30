import 'dart:math';
import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFB8860B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'AETHER RESONANCE ORACLE',
                    style: TextStyle(
                      color: Color(0xFFB8860B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF007791).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF007791)),
                ),
                child: Text(
                  'D20 ORACLE: $_lastRoll',
                  style: const TextStyle(
                    color: Color(0xFF007791),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
            ),
            child: Text(
              _isCommuning ? 'Communing with the Cardinal Scribes...' : _divineBlessing,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 11,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 1,
              ),
              icon: _isCommuning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A1A)),
                    )
                  : const Icon(Icons.casino_outlined, size: 16),
              label: Text(
                _isCommuning ? 'DIVINING...' : 'COMMUNE WITH WORLD ARBITER (ROLL D20)',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              onPressed: _isCommuning ? null : _communeWithArbiter,
            ),
          ),
        ],
      ),
    );
  }
}
