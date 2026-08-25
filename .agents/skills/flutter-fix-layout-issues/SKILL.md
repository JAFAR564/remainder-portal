---
name: flutter-fix-layout-issues
description: >-
  Diagnose, debug, and resolve Flutter layout constraints, RenderFlex overflow errors,
  unbounded height/width issues, and responsive design adaptations.
---

# Flutter Layout & RenderFlex Issue Resolution Skill

This skill provides step-by-step diagnostic strategies and patterns to eliminate Flutter layout exceptions.

## Common Issues & Solutions

### 1. RenderFlex Overflow (Yellow/Black Stripes)
- **Cause**: Content exceeds available screen dimension in a `Row` or `Column`.
- **Fixes**:
  - Wrap flexing children in `Expanded` or `Flexible`.
  - Wrap unbounded columns in `SingleChildScrollView` with a `ConstrainedBox` or `SafeArea`.
  - Use `overflow: TextOverflow.ellipsis` on `Text` widgets inside bounded parents.

### 2. Vertical Viewport Was Given Unbounded Height
- **Cause**: Nesting a `ListView`, `GridView`, or `SingleChildScrollView` inside an unconstrained `Column`.
- **Fixes**:
  - Set `shrinkWrap: true` and `physics: const ClampingScrollPhysics()` on nested scroll views.
  - Or wrap the scroll view in an `Expanded` widget.

### 3. Responsive Breakpoints & Multi-Platform Adaptation
- Use `LayoutBuilder` or `MediaQuery.sizeOf(context)` to adapt grids and padding across mobile (Android/iOS), desktop (Windows/Linux/macOS), and Web.
- Adhere strictly to the Hellenic White Marble & Imperial Gold design system tokens (`#F8F6F0`, `#FFFFFF`, `#D4AF37`, `#B8860B`).
