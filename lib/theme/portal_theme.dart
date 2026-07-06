import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortalTheme {
  // Color Palette constants from DESIGN.md / Ennoia brand migration
  static const Color creamBg = Color(0xFF080B11); // Deep Prussian Blue / Obsidian Background
  static const Color lightGraySurface = Color(0xFF101622); // Obsidian Surface Card
  static const Color tealNavyAccent = Color(0xFF4DB6AC); // Glowing Teal Accent
  static const Color charcoalNearBlackText = Color(0xFFF5F6F8); // Bone White Title text
  static const Color warmGrayBodyText = Color(0xFF8E96AA); // Muted Silver-Gray Body text
  static const Color silverGrayBorder = Color(0xFF222E3E); // Subtle Border Navy
  
  // Functional States
  static const Color successMoss = Color(0xFF10B981);
  static const Color alertTerracotta = Color(0xFFEF4444);
  static const Color infoSlate = Color(0xFF64748B);

  // Typography Families & Styles
  // Headlines: Cormorant Garamond (refined serif)
  // Body: Jost (clean geometric sans-serif)
  // Stats: JetBrains Mono (pristine monospace)

  static TextStyle get displayHeadline => GoogleFonts.cormorantGaramond(
        fontSize: 48.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02 * 48.0,
        color: charcoalNearBlackText,
      );

  static TextStyle get sectionHeader => GoogleFonts.cormorantGaramond(
        fontSize: 36.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 36.0,
        color: charcoalNearBlackText,
      );

  static TextStyle get subsectionHeader => GoogleFonts.cormorantGaramond(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        color: charcoalNearBlackText,
      );

  static TextStyle get bodyText => GoogleFonts.jost(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: warmGrayBodyText,
      );

  static TextStyle get smallText => GoogleFonts.jost(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: warmGrayBodyText,
      );

  static TextStyle get statsText => GoogleFonts.jetBrainsMono(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: charcoalNearBlackText,
      );

  static TextStyle get ctaButtonText => GoogleFonts.jost(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01 * 16.0,
        color: Colors.white,
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBg,
      colorScheme: ColorScheme.dark(
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
