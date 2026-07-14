import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'descent_screen.dart';

class GenesisScreen extends ConsumerStatefulWidget {
  const GenesisScreen({super.key});

  @override
  ConsumerState<GenesisScreen> createState() => _GenesisScreenState();
}

class _GenesisScreenState extends ConsumerState<GenesisScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  String _selectedClass = 'Aether-Wake';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<String> _classes = ['Aether-Wake', 'Amatsukrion Sync', 'Wyrd-Born'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onAwaken() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Establish a designation identifier (Name).')),
      );
      return;
    }

    // Create Drift profile
    await ref.read(playerProfileProvider.notifier).createProfile(name, _selectedClass);

    // Initialize repository asynchronously
    await ref.read(okfRepositoryProvider).initialize();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DescentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17), // Sleek deep cyberpunk background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color(0xFF1D1B26),
                Color(0xFF0F0E17),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 12,
                color: const Color(0xFF161520).withOpacity(0.85), // Glassmorphism container
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(
                    color: const Color(0xFFFF8E3C).withOpacity(0.3), // Cyberpunk accent border
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Runic Emblem placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53170).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53170), Color(0xFFFF8E3C)],
                          ),
                        ),
                        child: const Icon(
                          Icons.vpn_key_sharp,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'THE REMAINDER PORTAL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AWAKENING SEQUENCE INITIALIZED',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFE53170).withOpacity(0.9),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Character Designation Text Field
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'CHARACTER DESIGNATION',
                          labelStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0F0E17).withOpacity(0.5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF8E3C)),
                          ),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFFF8E3C)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Class Selection Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0E17).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClass,
                            dropdownColor: const Color(0xFF161520),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF8E3C)),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: _classes.map((cls) => DropdownMenuItem(
                              value: cls,
                              child: Text(cls),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedClass = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Awakening Button with glow effect
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _onAwaken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53170),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFFE53170).withOpacity(0.6),
                          ),
                          child: const Text(
                            'INITIATE DESCENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
