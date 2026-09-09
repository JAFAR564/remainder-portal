import 'package:flutter/material.dart';

/// Reusable responsive section header for the Celestial Astrolabe design system.
///
/// Combines an astral glyph prefix, flexible serif title with guaranteed ellipsis
/// truncation, and an optional trailing action/badge widget to prevent horizontal overflow.
class AstrolabeSectionHeader extends StatelessWidget {
  final String title;
  final String glyph;
  final Widget? trailing;
  final double letterSpacing;
  final Color titleColor;
  final double fontSize;

  const AstrolabeSectionHeader({
    super.key,
    required this.title,
    this.glyph = '✦',
    this.trailing,
    this.letterSpacing = 1.2,
    this.titleColor = const Color(0xFF6E473B),
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (glyph.isNotEmpty)
          Text(
            '$glyph ',
            style: TextStyle(
              color: titleColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: letterSpacing,
              color: titleColor,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}
