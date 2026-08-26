import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'main_navigation_shell.dart';

class StoryPrologueScreen extends ConsumerStatefulWidget {
  const StoryPrologueScreen({super.key});

  @override
  ConsumerState<StoryPrologueScreen> createState() => _StoryPrologueScreenState();
}

class _StoryPrologueScreenState extends ConsumerState<StoryPrologueScreen> {
  int _currentStep = 0;

  final List<_StorySlide> _slides = [
    _StorySlide(
      actTitle: 'ACT I: THE AWAKENING IN PENTELIC LIGHT',
      narrative:
          'You awaken to the sensation of falling through soft, glowing parchment. The sky above is written in golden cursive runes that dissolve like stardust into petrichor.\n\nA voice resonates through the white marble archways—calm, majestic, and vast.',
      arbiterDialogue:
          '"Fragment of the waking world: you have slipped through the seams of your previous existence. Tell me... what is the last memory you carry before your soul took flesh in the Sovereign Realm?"',
      options: ['I remember a world of noise and glass.', 'I remember a battle under a dying sun.', 'I remember nothing but a yearning for freedom.'],
    ),
    _StorySlide(
      actTitle: 'ACT II: THE SANCTUARY PLEDGE',
      narrative:
          'The parchment settles beneath your feet into polished Pentelic White Marble. Around you, three ancient pillars of light rise toward an infinite golden sky—the Aether-Wake, the Amatsukrion Grid, and the Wyrd-Loom.',
      arbiterDialogue:
          '"The World Arbiter (Cardinal) has verified your spirit cores. You stand within Sanctuary 4. As a Traveler, your prose and actions will shape the fate of all registered guilds."',
      options: ['I pledge my Aether to protect the innocent.', 'I seek to master the laws of reality.', 'I march to conquer dungeons and claim glory.'],
    ),
    _StorySlide(
      actTitle: 'ACT III: THE FIRST DECREE',
      narrative:
          'A radiant Golden Astrolabe emblem descends from the sky, hovering before your chest. The World Arbiter inscribes your traveler title upon the eternal loom.',
      arbiterDialogue:
          '"Your oath is recorded in the Chrono-Loom. Step through the archway, Traveler. The Sovereign Realm awaits your command."',
      options: ['STEP THROUGH THE ARCHWAY INTO THE REALM'],
    ),
  ];

  void _nextSlide(int optionIndex) async {
    if (_currentStep < _slides.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Complete prologue and enter main dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentStep];
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GENESIS PROLOGUE — CHAPTER ${_currentStep + 1}/${_slides.length}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E473B),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    profile?.name.toUpperCase() ?? 'TRAVELER',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF291C0E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _slides.length,
                  backgroundColor: const Color(0xFFBEB5A9).withValues(alpha: 0.4),
                  color: const Color(0xFF6E473B),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 20),

              // Story Card
              Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFA78D78), width: 1.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Act Title
                          Text(
                            slide.actTitle,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E473B),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Scene Narrative
                          Text(
                            slide.narrative,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF291C0E),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // World Arbiter Dialogue Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA78D78).withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: Color(0xFF6E473B), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'WORLD ARBITER (CARDINAL)',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6E473B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  slide.arbiterDialogue,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: Color(0xFF291C0E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Choices
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(slide.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E473B),
                        foregroundColor: const Color(0xFFE1D4C2),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () => _nextSlide(index),
                      child: Text(
                        slide.options[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySlide {
  final String actTitle;
  final String narrative;
  final String arbiterDialogue;
  final List<String> options;

  _StorySlide({
    required this.actTitle,
    required this.narrative,
    required this.arbiterDialogue,
    required this.options,
  });
}
