import 'package:flutter/material.dart';

class EquipmentSlotsWidget extends StatelessWidget {
  const EquipmentSlotsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF6E473B), size: 16),
              SizedBox(width: 6),
              Text(
                'EQUIPMENT & GEAR SLOTS',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6E473B),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSlot(icon: Icons.colorize, label: 'WEAPON', item: 'Shadow Dagger'),
              _buildSlot(icon: Icons.shield, label: 'ARMOR', item: 'Aegis Cuirass'),
              _buildSlot(icon: Icons.auto_awesome, label: 'RELIC', item: 'Astrolabe Core'),
              _buildSlot(icon: Icons.diamond_outlined, label: 'CHARM', item: 'Ionic Crystal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlot({required IconData icon, required String label, required String item}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE1D4C2).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA78D78), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF291C0E).withValues(alpha: 0.04),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF6E473B), size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFF6E473B), fontWeight: FontWeight.bold),
        ),
        Text(
          item,
          style: const TextStyle(fontSize: 9, color: Color(0xFF291C0E), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
