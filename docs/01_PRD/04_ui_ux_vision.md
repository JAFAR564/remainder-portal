# PRD §1.5 — UI/UX Vision: *Light Ethereal & Elegant Fantasy meets Next-Gen Aristocratic*

> **Part of:** Module 1: Product Requirement Document
> **Navigation:** Up from `03_functional_requirements.md` | Next to `05_mobile_first_adaptability.md`

---

## 1.5.1 — Design Language Definition

The Remainder Portal exists at the intersection of a Victorian estate and a next-generation OS. The visual grammar is defined by three forces:

| Force | Expression |
|---|---|
| **Lightness** | White-to-warm-ivory backgrounds; content feels suspended in luminescent air |
| **Materiality** | Frosted glass surfaces (`BackdropFilter` + `ImageFilter.blur`) layered atop soft textured backgrounds |
| **Aristocracy** | Luminous soft-gold (`#D4A857`) and subtle iridescent accents; micro-serif headlines; no harsh shadows |

---

## 1.5.2 — Flutter Implementation Patterns

### Glassmorphic Card System

```dart
// lib/ui/components/glass_card.dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final Color tintColor;

  const GlassCard({
    super.key,
    required this.child,
    this.blurSigma = 12.0, // Strict rendering limit: [6.0, 12.0] for Impeller performance
    this.tintColor = const Color(0x1AFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        // Enforce strict performance rendering limits: sigmaX, sigmaY in [6.0, 12.0]
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0x33D4A857), // soft-gold iridescent border
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14D4A857),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### Spring-Based Touch Animation System

```dart
// All interactive elements use SpringSimulation for magical underdamped fluidity
class SpringTapWrapper extends StatefulWidget { ... }

class _SpringTapWrapperState extends State<SpringTapWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration.zero);
    _scaleAnimation = _controller.drive(
      Tween(begin: 1.0, end: 0.95).chain(
        // Underdamped spring fluidity: setting zeta (damping ratio) ≈ 0.85
        // c / (2 * sqrt(k * m)) = 24 / (2 * sqrt(200 * 1)) ≈ 24 / 28.28 ≈ 0.85
        CurveTween(curve: const SpringCurve(mass: 1, stiffness: 200, damping: 24)),
      ),
    );
  }
  // ... gesture detector wrapping child with Transform.scale(_scaleAnimation)
}
```

### Iridescent Shader Highlights
Subtle iridescent highlights are generated using custom fragment shaders via Flutter's `FragmentProgram` API, running natively on the device GPU to keep the main thread free. To prevent rendering skips during compilation, make sure the local test device runs the Impeller backend natively so shaders compile in real-time.

### Color Palette (Defined as `ThemeData`)

```dart
// lib/theme/portal_theme.dart
const Color portalGold        = Color(0xFFD4A857);  // Luminous soft-gold
const Color portalIvory       = Color(0xFFFAF8F4);  // Warm ivory surface
const Color portalFrost       = Color(0x1AFFFFFF);  // Glass tint
const Color portalIridescent  = Color(0xFF9BB5CE);  // Subtle blue iridescence
const Color portalInk         = Color(0xFF1A1410);  // Deep parchment ink
const Color portalSilver      = Color(0xFFE8E0D0);  // Muted silver border
```

### Typography

- **Headlines:** `Cormorant Garamond` (serif, elegant aristocratic weight) — Google Fonts
- **Body:** `Jost` (clean, modern, high legibility on mobile)
- **Monospace/Stats:** `JetBrains Mono` (for numeric stat fields)
