import 'package:flutter/material.dart';

class EquipmentSlotsWidget extends StatelessWidget {
  const EquipmentSlotsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 16),
              SizedBox(width: 6),
              Text(
                'MMORPG EQUIPMENT & GEAR SLOTS',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
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
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFF00B4D8), fontWeight: FontWeight.bold),
        ),
        Text(
          item,
          style: const TextStyle(fontSize: 9, color: Colors.white70),
        ),
      ],
    );
  }
}
