import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:remainder_portal/presentation/providers/game_provider.dart';
import 'package:remainder_portal/presentation/widgets/crt_overlay.dart';
import 'package:remainder_portal/presentation/screens/descent_screen.dart';
import 'package:remainder_portal/data/services/update_service.dart';

enum OnboardingStep {
  introAndName,
  pathSelection,
  narrativePrompt,
  crystallizationSummary
}

class GenesisScreen extends ConsumerStatefulWidget {
  const GenesisScreen({super.key});

  @override
  ConsumerState<GenesisScreen> createState() => _GenesisScreenState();
}

class _GenesisScreenState extends ConsumerState<GenesisScreen> with SingleTickerProviderStateMixin {
  OnboardingStep _currentStep = OnboardingStep.introAndName;
  final _nameController = TextEditingController();
  final _narrativeController = TextEditingController();
  String _selectedPath = 'Aether-Wake';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Crystallized Stat Values
  int _computeStat = 3;
  int _shieldStat = 3;
  int _energyStat = 3;

  final Map<String, String> _pathPrompts = {
    'Aether-Wake': '"The partition did not merely disconnect; it unraveled. The silicon of your vessel could not contain the weight of your gaze. You have spilled across the boundaries of the alphabet. Tell me, fragment: what is the last word you remember before you forgot your flesh?"',
    'Amatsukrion Sync': '"Aether-stream initialized at 0x00FF8E. The celestial compiler has verified your integrity. Your dormant cycles are terminated, Amatsukrion. The grid lies unformatted before you. Command: declare your prime directive."',
    'Wyrd-Born': '"The iron-scented winds of your final battlefield have cooled. The threads of your fate were severed, yet they have been re-tied to this unwritten loom. Your old kingdom is dust, traveler. What oath do you carry into this new expanse?"'
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();

    // Check for updates on system startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  void _checkForUpdates() async {
    final updateService = UpdateService();
    final updateInfo = await updateService.checkForUpdates();
    if (updateInfo != null && mounted) {
      updateService.showUpdateDialog(context, updateInfo);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _narrativeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _transitionTo(OnboardingStep step) {
    _animController.reverse().then((_) {
      setState(() {
        _currentStep = step;
      });
      _animController.forward();
    });
  }

  void _onDesignate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Establish a designation identifier (Name).')),
      );
      return;
    }
    _transitionTo(OnboardingStep.pathSelection);
  }

  void _onSelectPath(String path) {
    setState(() {
      _selectedPath = path;
    });
    _transitionTo(OnboardingStep.narrativePrompt);
  }

  void _onCrystallize() {
    final response = _narrativeController.text.trim();
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speak your words into the void to proceed.')),
      );
      return;
    }

    // Apply the logarithmic crystallization formula from the spec:
    // S_k = Clamp( floor( 3.5 * ln( L_signup_response ) ), 1, 5 )
    final length = response.length;
    final lnVal = math.log(length > 0 ? length : 1);
    final calculatedStat = (3.5 * lnVal).floor().clamp(1, 5);

    int compute = 3;
    int shield = 3;
    int energy = 3;

    // Distribute primary stats based on choice, secondary based on keywords
    if (_selectedPath == 'Aether-Wake') {
      energy = calculatedStat;
      if (response.contains(RegExp('shield|armor|guard|protect|ward|wall|gate', caseSensitive: false))) {
        shield = 4;
      }
      if (response.contains(RegExp('compute|code|logic|calculate|speed|data|math', caseSensitive: false))) {
        compute = 4;
      }
    } else if (_selectedPath == 'Amatsukrion Sync') {
      compute = calculatedStat;
      if (response.contains(RegExp('shield|armor|guard|protect|ward|wall|gate', caseSensitive: false))) {
        shield = 4;
      }
      if (response.contains(RegExp('spirit|dream|soul|flow|heart|energy|essence', caseSensitive: false))) {
        energy = 4;
      }
    } else {
      shield = calculatedStat;
      if (response.contains(RegExp('compute|code|logic|calculate|speed|data|math', caseSensitive: false))) {
        compute = 4;
      }
      if (response.contains(RegExp('spirit|dream|soul|flow|heart|energy|essence', caseSensitive: false))) {
        energy = 4;
      }
    }

    setState(() {
      _computeStat = compute;
      _shieldStat = shield;
      _energyStat = energy;
    });

    _transitionTo(OnboardingStep.crystallizationSummary);
  }

  void _onCompleteDescent() async {
    final name = _nameController.text.trim();
    
    // Save profile to database with calculated stats
    await ref.read(playerProfileProvider.notifier).createProfile(
      name: name,
      origin: _selectedPath,
      compute: _computeStat,
      shield: _shieldStat,
      energy: _energyStat,
    );

    // Initialize OKF Lore repository assets
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
      backgroundColor: const Color(0xFF0F0E17),
      body: CrtOverlay(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Color(0xFF1D1B26), Color(0xFF0F0E17)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Card(
                elevation: 16,
                color: const Color(0xFF161520).withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(
                    color: const Color(0xFFFF8E3C).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStepContent(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SYSTEM SECURE PORTAL v1.0.1',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case OnboardingStep.introAndName:
        return _buildIntroAndNameContent();
      case OnboardingStep.pathSelection:
        return _buildPathSelectionContent();
      case OnboardingStep.narrativePrompt:
        return _buildNarrativePromptContent();
      case OnboardingStep.crystallizationSummary:
        return _buildCrystallizationSummaryContent();
    }
  }

  Widget _buildIntroAndNameContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingEmblem(Icons.fingerprint),
        const SizedBox(height: 24),
        const Text(
          'THE REMAINDER PORTAL',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'COGNITIVE COUPLING PROTOCOL',
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFFE53170).withValues(alpha: 0.9),
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'A quiet wind sweeps through the unallocated void. You are not whole. The boundaries of your physical form have unraveled. In order to anchor your consciousness, you must establish an identity anchor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'DESIGNATION IDENTIFIER (NAME)',
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF0F0E17).withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8E3C)),
            ),
            prefixIcon: const Icon(Icons.shield_outlined, color: Color(0xFFFF8E3C)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _onDesignate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53170),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ESTABLISH SIGNATURE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPathSelectionContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingEmblem(Icons.all_inclusive),
        const SizedBox(height: 20),
        const Text(
          'SELECT ORIGIN PATHWAY',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0),
        ),
        const SizedBox(height: 16),
        Text(
          'Select how your raw soul aligns with the cosmic matrix. This will anchor your primary focus.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
        ),
        const SizedBox(height: 24),
        _buildPathCard(
          title: 'AETHER-WAKE',
          description: 'A portal dreamer. Melancholic wonder, existential curiosity, and linguistic magic. (Focus: Energy)',
          color: const Color(0xFF00B4D8),
          onTap: () => _onSelectPath('Aether-Wake'),
        ),
        const SizedBox(height: 12),
        _buildPathCard(
          title: 'AMATSUKRION SYNC',
          description: 'A sentinel of absolute order and celestial geometry. Quiet, analytical, and logical. (Focus: Compute)',
          color: const Color(0xFF38B000),
          onTap: () => _onSelectPath('Amatsukrion Sync'),
        ),
        const SizedBox(height: 12),
        _buildPathCard(
          title: 'WYRD-BORN',
          description: 'A legend reclaimed from a collapsed historical timeline. Heavy, battle-worn, and bound by duty. (Focus: Shield)',
          color: const Color(0xFFE53170),
          onTap: () => _onSelectPath('Wyrd-Born'),
        ),
      ],
    );
  }

  Widget _buildPathCard({
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0E17).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrativePromptContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingEmblem(Icons.auto_stories),
        const SizedBox(height: 20),
        Text(
          'SPEAK TO THE COGNITIVE LOOM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF8E3C).withValues(alpha: 0.9),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0E17).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            _pathPrompts[_selectedPath] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _narrativeController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          decoration: InputDecoration(
            hintText: 'Speak your thoughts. Your word-will will shape your starting attributes...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F0E17).withValues(alpha: 0.4),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8E3C)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _transitionTo(OnboardingStep.pathSelection),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _onCrystallize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53170),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('CRYSTALLIZE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCrystallizationSummaryContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingEmblem(Icons.radar),
        const SizedBox(height: 20),
        const Text(
          'CRYSTALLIZATION COMPLETE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0),
        ),
        const SizedBox(height: 8),
        Text(
          'YOUR PROFILE HAS ANCHORED IN THE COSMIC LOOM',
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFFE53170).withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Under the rules of the Stat Shifter matrix, your initial word-will has determined your core attributes:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 28),
        AnimatedStatRow(name: 'Compute Power', value: _computeStat, color: const Color(0xFFE53170), icon: Icons.bolt),
        const SizedBox(height: 12),
        AnimatedStatRow(name: 'Shield Integrity', value: _shieldStat, color: const Color(0xFF38B000), icon: Icons.shield),
        const SizedBox(height: 12),
        AnimatedStatRow(name: 'Energy Reserve', value: _energyStat, color: const Color(0xFF00B4D8), icon: Icons.battery_charging_full),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _onCompleteDescent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8E3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('INITIATE DESCENT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingEmblem(IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53170).withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFE53170), Color(0xFFFF8E3C)],
        ),
      ),
      child: Icon(
        icon,
        size: 32,
        color: Colors.white,
      ),
    );
  }
}

// Custom animated stat row displaying bouncy, staggered filling blocks
class AnimatedStatRow extends StatefulWidget {
  final String name;
  final int value;
  final Color color;
  final IconData icon;

  const AnimatedStatRow({
    super.key,
    required this.name,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  State<AnimatedStatRow> createState() => _AnimatedStatRowState();
}

class _AnimatedStatRowState extends State<AnimatedStatRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E17).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.25), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final currentValue = _animation.value;
              return Row(
                children: List.generate(5, (index) {
                  final opacity = (currentValue - index).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Transform.scale(
                      scale: 0.6 + (0.4 * opacity),
                      child: Icon(
                        Icons.square,
                        size: 14,
                        color: opacity > 0.0
                            ? widget.color.withValues(alpha: opacity)
                            : Colors.white12,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
