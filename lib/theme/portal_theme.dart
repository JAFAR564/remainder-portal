import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortalTheme {
  // Color Palette constants from DESIGN.md / Ennoia brand migration
  static const Color creamBg = Color(0xFF0A0A0C); // Deep Basalt Background
  static const Color lightGraySurface = Color(0xFF121215); // Obsidian Surface Card
  static const Color tealNavyAccent = Color(0xFF4CA0C6); // Glowing Blue-Teal Accent
  static const Color goldAccent = Color(0xFFD4A857); // Warm Gold highlight accent
  static const Color charcoalNearBlackText = Color(0xFFFAF9F6); // Ivory Title
  static const Color warmGrayBodyText = Color(0xFF8E95A5); // Muted body text
  static const Color silverGrayBorder = Color(0xFF1F1F25); // Hairline border
  
  // Functional States
  static const Color successMoss = Color(0xFF10B981);
  static const Color alertTerracotta = Color(0xFFEF4444);
  static const Color infoSlate = Color(0xFF64748B);

  // Typography Families & Styles
  // Headlines: Cormorant Garamond (refined serif)
  // Body: Jost (clean geometric sans-serif)
  // Stats: JetBrains Mono (pristine monospace)

  static TextStyle get displayHeadline => GoogleFonts.cormorantGaramond(
        fontSize: 38.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.2,
        height: 1.2,
        color: charcoalNearBlackText,
      );

  static TextStyle get sectionHeader => GoogleFonts.cormorantGaramond(
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        height: 1.3,
        color: charcoalNearBlackText,
      );

  static TextStyle get subsectionHeader => GoogleFonts.cormorantGaramond(
        fontSize: 22.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: charcoalNearBlackText,
      );

  static TextStyle get bodyText => GoogleFonts.jost(
        fontSize: 14.5,
        fontWeight: FontWeight.w300,
        height: 1.6,
        color: warmGrayBodyText,
      );

  static TextStyle get smallText => GoogleFonts.jost(
        fontSize: 13.0,
        fontWeight: FontWeight.w300,
        height: 1.5,
        color: warmGrayBodyText,
      );

  static TextStyle get statsText => GoogleFonts.jetBrainsMono(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: charcoalNearBlackText,
      );

  static TextStyle get ctaButtonText => GoogleFonts.jost(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: Colors.white,
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBg,
      colorScheme: const ColorScheme.dark(
        primary: tealNavyAccent,
        surface: lightGraySurface,
        onSurface: charcoalNearBlackText,
        error: alertTerracotta,
      ),
      textTheme: TextTheme(
        displayLarge: displayHeadline,
        headlineMedium: sectionHeader,
        titleLarge: subsectionHeader,
        bodyLarge: bodyText,
        bodyMedium: bodyText,
        bodySmall: smallText,
        labelLarge: ctaButtonText,
      ),
      dividerTheme: const DividerThemeData(
        color: silverGrayBorder,
        thickness: 1.0,
      ),
    );
  }
}
