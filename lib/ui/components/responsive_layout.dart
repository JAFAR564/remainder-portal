import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A baseline responsive layout container implementing the strict breakpoints
/// defined in AGENTS.md:
/// - Mobile: < 600dp
/// - Tablet: 600dp – 899dp
/// - Desktop: 900dp+
/// 
/// Consistently uses LayoutBuilder to evaluate constraints, in strict
/// alignment with project rules.
class ResponsiveLayout extends ConsumerWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Breakpoint limits in dp
  static const double mobileBreakPoint = 599.9;
  static const double tabletBreakPoint = 899.9;

  /// Helper to check if constraints correspond to mobile layout
  static bool isMobile(BoxConstraints constraints) {
    return constraints.maxWidth <= mobileBreakPoint;
  }

  /// Helper to check if constraints correspond to tablet layout
  static bool isTablet(BoxConstraints constraints) {
    return constraints.maxWidth > mobileBreakPoint && constraints.maxWidth <= tabletBreakPoint;
  }

  /// Helper to check if constraints correspond to desktop layout
  static bool isDesktop(BoxConstraints constraints) {
    return constraints.maxWidth > tabletBreakPoint;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop(constraints)) {
          return desktop;
        } else if (isTablet(constraints)) {
          return tablet ?? desktop; // Fallback to desktop if tablet is not specified
        } else {
          return mobile;
        }
      },
    );
  }
}
