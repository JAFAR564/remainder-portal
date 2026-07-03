import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A touch animation wrapper that implements an underdamped spring-mass-damper
/// system (zeta ≈ 0.85, m=1.0, k=200.0, c=24.0) for a fluid elastic rebound.
/// 
/// Complies with the system layout rules from AGENTS.md.
class SpringTapWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SpringTapWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  ConsumerState<SpringTapWrapper> createState() => _SpringTapWrapperState();
}

class _SpringTapWrapperState extends ConsumerState<SpringTapWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  // Damping ratio (zeta) ≈ 0.85:
  // mass (m) = 1.0, stiffness (k) = 200.0, damping (c) = 24.0
  // Equation: d^2x/dt^2 + 2*zeta*omega_n*dx/dt + omega_n^2*x = 0
  final SpringDescription _springDescription = const SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 24.0,
  );

  @override
  void initState() {
    super.initState();
    // Default to fully scaled (1.0)
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerSpring(double targetValue) {
    final simulation = SpringSimulation(
      _springDescription,
      _controller.value,
      targetValue,
      _controller.velocity, // Maintains kinetic velocity for fluid tracking
    );
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _triggerSpring(0.95), // Scale down slightly on press
      onTapUp: (_) {
        _triggerSpring(1.0); // Release to snap back with elastic rebound
        widget.onTap?.call();
      },
      onTapCancel: () => _triggerSpring(1.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
