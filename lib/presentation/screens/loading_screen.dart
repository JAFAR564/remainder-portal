import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _progress = 0;
  String _statusText = 'INITIALIZING SYSTEM ADMINISTRATOR (CARDINAL)...';
  Timer? _timer;

  final List<String> _stages = [
    'INITIALIZING SYSTEM ADMINISTRATOR (CARDINAL)...',
    'CONNECTING TO NEURAL REALM & SECTOR NODES...',
    'SYNCHRONIZING DRIFT SQLITE PERSISTENCE LEDGER...',
    'VERIFYING SOVEREIGN SYSTEM REPUTATION & CLASS...',
    'SYSTEM ONLINE. WELCOME OPERATOR.',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_progress < 100) {
          _progress += 20;
          int stageIdx = (_progress / 25).floor().clamp(0, _stages.length - 1);
          _statusText = _stages[stageIdx];
        } else {
          _timer?.cancel();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotating Celestial Ring Dial
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.6), width: 1.5),
                        ),
                      ),
                      const Icon(Icons.hub_outlined, color: Color(0xFFD4AF37), size: 36),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Status Progress Telemetry
              Text(
                '$_progress%',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 12),
              
              // Linear Gold Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status Readout
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFF00B4D8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
