import 'package:flutter/material.dart';

class CelestialBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CelestialBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<_NavbarItem> items = const [
      _NavbarItem(assetPath: 'assets/icon/nav/nav_dashboard.png', label: 'DASHBOARD'),
      _NavbarItem(assetPath: 'assets/icon/nav/nav_terminal.png', label: 'NEXUS CHAT'),
      _NavbarItem(assetPath: 'assets/icon/nav/nav_expeditions.png', label: 'SQUADS'),
      _NavbarItem(assetPath: 'assets/icon/nav/nav_guilds.png', label: 'GUILDS'),
      _NavbarItem(assetPath: 'assets/icon/nav/nav_profile.png', label: 'SETTINGS'),
    ];

    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFA78D78), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E473B).withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF291C0E).withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6E473B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: const Color(0xFF291C0E)) : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6E473B).withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.60,
                      child: Image.asset(
                        item.assetPath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE1D4C2),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavbarItem {
  final String assetPath;
  final String label;

  const _NavbarItem({
    required this.assetPath,
    required this.label,
  });
}
