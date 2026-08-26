import 'package:flutter/material.dart';

/// Design system constants and ThemeExtension for The Remainder Portal.
///
/// Implements a lightweight, Apple-inspired holographic HUD design language
/// conforming to the visual specifications of the UI analysis.
@immutable
class PortalTheme extends ThemeExtension<PortalTheme> {
  // --- Master 5-Color Palette (from 97f2a71f96978724029cf44e5ced6eda.jpg) ---
  static const Color espresso = Color(0xFF291C0E);
  static const Color terracotta = Color(0xFF6E473B);
  static const Color taupe = Color(0xFFA78D78);
  static const Color cashmere = Color(0xFFBEB5A9);
  static const Color cream = Color(0xFFE1D4C2);

  // --- Theme Token Properties ---
  final Color baseBackground;
  final Color surfaceOverlay;
  final Color primaryAccent;
  final Color secondaryText;
  final Color glassBorder;

  // --- Glow & Shadow Effects ---
  final List<BoxShadow> neonGlow;
  final List<BoxShadow> glassShadow;

  const PortalTheme({
    required this.baseBackground,
    required this.surfaceOverlay,
    required this.primaryAccent,
    required this.secondaryText,
    required this.glassBorder,
    required this.neonGlow,
    required this.glassShadow,
  });

  /// Factory configuration for the Warm Espresso & Terracotta Cream Theme.
  factory PortalTheme.dark() {
    return PortalTheme(
      baseBackground: cream,
      surfaceOverlay: Colors.white,
      primaryAccent: terracotta,
      secondaryText: espresso,
      glassBorder: taupe,
      neonGlow: [
        BoxShadow(
          color: terracotta.withValues(alpha: 0.25),
          blurRadius: 16.0,
          spreadRadius: 1.0,
        ),
      ],
      glassShadow: [
        BoxShadow(
          color: espresso.withValues(alpha: 0.08),
          blurRadius: 14.0,
          spreadRadius: 2.0,
        ),
      ],
    );
  }

  // --- Geometry Constants ---
  /// Corner radius for standard pill containers (30px / 30.0).
  static const double borderRadiusPill = 30.0;
  static const BorderRadius clipRadiusPill = BorderRadius.all(Radius.circular(borderRadiusPill));

  /// Corner radius for fully circular widgets.
  static const double borderRadiusCircular = 999.0;
  static const BorderRadius clipRadiusCircular = BorderRadius.all(Radius.circular(borderRadiusCircular));

  // --- Spacing System ---
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;

  // --- Typography Specs ---
  static TextStyle get titleStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        color: espresso,
        letterSpacing: -0.5,
      );

  static TextStyle get cardLabelStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: terracotta,
        letterSpacing: 0.2,
      );

  static TextStyle get cardValueStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: espresso,
        letterSpacing: 0.2,
      );

  static TextStyle get widgetValueStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: espresso,
      );

  @override
  PortalTheme copyWith({
    Color? baseBackground,
    Color? surfaceOverlay,
    Color? primaryAccent,
    Color? secondaryText,
    Color? glassBorder,
    List<BoxShadow>? neonGlow,
    List<BoxShadow>? glassShadow,
  }) {
    return PortalTheme(
      baseBackground: baseBackground ?? this.baseBackground,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      secondaryText: secondaryText ?? this.secondaryText,
      glassBorder: glassBorder ?? this.glassBorder,
      neonGlow: neonGlow ?? this.neonGlow,
      glassShadow: glassShadow ?? this.glassShadow,
    );
  }

  @override
  PortalTheme lerp(ThemeExtension<PortalTheme>? other, double t) {
    if (other is! PortalTheme) return this;
    return PortalTheme(
      baseBackground: Color.lerp(baseBackground, other.baseBackground, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      neonGlow: t < 0.5 ? neonGlow : other.neonGlow,
      glassShadow: t < 0.5 ? glassShadow : other.glassShadow,
    );
  }
}

/// Helper extension to easily access PortalTheme from BuildContext.
extension PortalThemeGetter on BuildContext {
  PortalTheme get portalTheme => Theme.of(this).extension<PortalTheme>() ?? PortalTheme.dark();
}
