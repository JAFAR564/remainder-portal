import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'main_navigation_shell.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = true;
  final _nameController = TextEditingController(text: 'Operator Sung');
  String _selectedClass = 'Vanguard';
  String _selectedTitle = 'Shadow Monarch';

  final List<String> _classes = ['Vanguard', 'Cyber Hacker', 'Aegis Sentinel'];
  final List<String> _titles = ['Shadow Monarch', 'Vanguard Commander', 'High Aether Alchemist', 'Sovereign Administrator'];

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Create profile in Riverpod and Drift DB
    await ref.read(playerProfileProvider.notifier).createProfile(
      name: '$name ($_selectedTitle)',
      origin: _selectedClass,
      compute: 14,
      shield: 16,
      energy: 18,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationShell()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon Header Badge
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.asset(
                          'assets/icon/app_icon.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, color: Color(0xFFB8860B), size: 36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'SYSTEM ADMIN AUTHORIZATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFFB8860B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Establishes neural identity in the Sovereign Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // Login / Register Toggle Tabs
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSignUp ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFFFAF8F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _isSignUp ? const Color(0xFFB8860B) : const Color(0xFFE0DDD5)),
                            ),
                            child: Text(
                              'REGISTER OPERATOR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isSignUp ? const Color(0xFFB8860B) : const Color(0xFF777777),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isSignUp ? const Color(0xFF007791).withValues(alpha: 0.15) : const Color(0xFFFAF8F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: !_isSignUp ? const Color(0xFF007791) : const Color(0xFFE0DDD5)),
                            ),
                            child: Text(
                              'LOGIN LINK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: !_isSignUp ? const Color(0xFF007791) : const Color(0xFF777777),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Name Input
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'OPERATOR NAME',
                      labelStyle: const TextStyle(color: Color(0xFFB8860B), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: const Color(0xFFFAF8F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB8860B))),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sovereign Title Picker
                  DropdownButtonFormField<String>(
                    value: _selectedTitle,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'SOVEREIGN SYSTEM TITLE',
                      labelStyle: const TextStyle(color: Color(0xFFB8860B), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: const Color(0xFFFAF8F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                    ),
                    items: _titles.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTitle = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Class Archetype Selector
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'CLASS ARCHETYPE',
                      labelStyle: const TextStyle(color: Color(0xFFB8860B), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: const Color(0xFFFAF8F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0DDD5))),
                    ),
                    items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedClass = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    onPressed: _submit,
                    child: Text(
                      _isSignUp ? 'ENTHRONE OPERATOR PROFILE' : 'CONNECT NEURAL IDENTITY',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
