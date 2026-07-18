import 'package:flutter/material.dart';

/// Design system constants and ThemeExtension for The Remainder Portal.
///
/// Implements a lightweight, Apple-inspired holographic HUD design language
/// conforming to the visual specifications of the UI analysis.
@immutable
class PortalTheme extends ThemeExtension<PortalTheme> {
  // --- Color Palette ---
  /// Deep Space Gray background color (#1A1A24).
  final Color baseBackground;

  /// Transparent Frost White overlay color (rgba(255,255,255, 0.03)).
  final Color surfaceOverlay;

  /// Electric Cyan accent color (#00E5FF).
  final Color primaryAccent;

  /// Soft Silver-Gray text and secondary detail color (#B0B3C1).
  final Color secondaryText;

  /// Delicate glass border color (translucent silver-gray, rgba(176, 179, 193, 0.2)).
  final Color glassBorder;

  // --- Glow & Shadow Effects ---
  /// Cyan neon glowing shadows for active elements.
  final List<BoxShadow> neonGlow;

  /// Whisper-soft shadows for glassmorphic elements.
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

  /// Default configuration matching the UI Analysis source of truth.
  factory PortalTheme.dark() {
    return PortalTheme(
      baseBackground: const Color(0xFF1A1A24),
      surfaceOverlay: const Color(0x08FFFFFF), // ~3% opacity white
      primaryAccent: const Color(0xFF00E5FF),
      secondaryText: const Color(0xFFB0B3C1),
      glassBorder: const Color(0x33B0B3C1), // ~20% opacity silver-gray
      neonGlow: [
        BoxShadow(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
          blurRadius: 15.0,
          spreadRadius: 1.0,
        ),
      ],
      glassShadow: [
        BoxShadow(
          color: const Color(0xFF1A1A24).withValues(alpha: 0.5),
          blurRadius: 20.0,
          spreadRadius: 0.0,
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
  /// Typography rules matching high legibility sans-serif requirements.
  static TextStyle get titleStyle => const TextStyle(
        fontFamily: 'Inter', // Fallback to system sans-serif if unavailable
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        letterSpacing: -0.5,
      );

  static TextStyle get cardLabelStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: Color(0xFFB0B3C1),
        letterSpacing: 0.2,
      );

  static TextStyle get cardValueStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFFB0B3C1),
        letterSpacing: 0.2,
      );

  static TextStyle get widgetValueStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Color(0xFFB0B3C1),
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
