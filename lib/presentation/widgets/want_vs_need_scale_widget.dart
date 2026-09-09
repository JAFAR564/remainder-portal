import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive Astrolabe Balance Scale contrasting External Want vs. Internal Need.
class WantVsNeedScaleWidget extends StatefulWidget {
  final String externalWant;
  final String? internalNeed;
  final double initialTension;

  const WantVsNeedScaleWidget({
    super.key,
    required this.externalWant,
    this.internalNeed,
    this.initialTension = 0.5,
  });

  @override
  State<WantVsNeedScaleWidget> createState() => _WantVsNeedScaleWidgetState();
}

class _WantVsNeedScaleWidgetState extends State<WantVsNeedScaleWidget> {
  late double _tension;

  @override
  void initState() {
    super.initState();
    _tension = widget.initialTension.clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant WantVsNeedScaleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTension != widget.initialTension) {
      _tension = widget.initialTension.clamp(0.0, 1.0);
    }
  }

  String get _tensionStatus {
    if (_tension > 0.6) {
      return 'AMBITION DOMINANT';
    } else if (_tension < 0.4) {
      return 'SOUL RECTIFICATION';
    }
    return 'HARMONIC EQUILIBRIUM';
  }

  String get _tensionDescription {
    if (_tension > 0.6) {
      return 'Mortal ambition outweighs spiritual truth. Vessel risks burnout and tragic blind spots.';
    } else if (_tension < 0.4) {
      return 'Inner necessity demands surrender of conscious desire. Reckoning with vulnerability begins.';
    }
    return 'Conscious ambition and unconscious purpose are balanced in celestial resonance.';
  }

  Color get _statusColor {
    if (_tension > 0.6) return const Color(0xFF6E473B); // Warm Terracotta
    if (_tension < 0.4) return const Color(0xFFA78D78); // Almond Taupe
    return const Color(0xFF291C0E); // Deep Espresso
  }

  @override
  Widget build(BuildContext context) {
    final tiltAngle = (_tension - 0.5) * 0.28; // Tilt angle in radians
    final effectiveNeed = widget.internalNeed != null && widget.internalNeed!.trim().isNotEmpty
        ? widget.internalNeed!
        : 'Spiritual Awakening (Unawakened)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78D78), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E473B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.balance, size: 18, color: Color(0xFF6E473B)),
                  SizedBox(width: 8),
                  Text(
                    'WANT VS. NEED BALANCE SCALE',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF6E473B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _statusColor, width: 1),
                ),
                child: Text(
                  _tensionStatus,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Celestial Scale Visualization
          Center(
            child: SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Fulcrum Base
                  Positioned(
                    top: 20,
                    child: Column(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6E473B),
                            border: Border.all(color: const Color(0xFFE1D4C2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6E473B).withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '⟐',
                              style: TextStyle(fontSize: 10, color: Color(0xFFE1D4C2), height: 1),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 60,
                          color: const Color(0xFFA78D78),
                        ),
                        Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E473B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tilting Beam & Hanging Pans
                  AnimatedRotation(
                    turns: tiltAngle / (2 * math.pi),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: const Alignment(0.0, -0.73),
                    child: SizedBox(
                      width: 290,
                      child: Column(
                        children: [
                          const SizedBox(height: 27),
                          // Beam Rod
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6E473B),
                                  Color(0xFFA78D78),
                                  Color(0xFF6E473B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Scale Pans Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Pan (Want)
                              _buildScalePan(
                                label: 'CONSCIOUS WANT',
                                value: widget.externalWant,
                                weightPercentage: (_tension * 100).toInt(),
                                isLeft: true,
                                panColor: const Color(0xFF6E473B),
                              ),
                              // Right Pan (Need)
                              _buildScalePan(
                                label: 'INTERNAL NEED',
                                value: effectiveNeed,
                                weightPercentage: ((1.0 - _tension) * 100).toInt(),
                                isLeft: false,
                                panColor: const Color(0xFFA78D78),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tension Assessment Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE1D4C2).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA78D78), width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology_outlined, size: 16, color: _statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tensionDescription,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF291C0E),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Interactive Tension Slider
          Row(
            children: [
              const Text(
                'NEED',
                style: TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFA78D78)),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF6E473B),
                    inactiveTrackColor: const Color(0xFFBEB5A9),
                    thumbColor: const Color(0xFF6E473B),
                    overlayColor: const Color(0xFF6E473B).withValues(alpha: 0.15),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _tension,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setState(() {
                        _tension = val;
                      });
                    },
                  ),
                ),
              ),
              const Text(
                'WANT',
                style: TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  setState(() {
                    _tension = 0.5;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1D4C2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFA78D78)),
                  ),
                  child: const Text(
                    'RESET',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6E473B)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScalePan({
    required String label,
    required String value,
    required int weightPercentage,
    required bool isLeft,
    required Color panColor,
  }) {
    return SizedBox(
      width: 125,
      child: Column(
        children: [
          // Suspension strings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 1, height: 14, color: const Color(0xFFA78D78)),
              const SizedBox(width: 24),
              Container(width: 1, height: 14, color: const Color(0xFFA78D78)),
            ],
          ),
          // Pan Plate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: panColor, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: panColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: panColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF291C0E),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: panColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$weightPercentage% TENSION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: panColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
