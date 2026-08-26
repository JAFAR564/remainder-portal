# 📱 Napkin Notes (Antigravity CLI & Mobile Termux Workspace)

## 🎯 Active Execution Context & Session State
- **Session ID:** `e640b8d9-619f-466f-9d48-54880b6f8a6c`
- **Target Device:** Honor X8 (Android / Termux environment)
- **Active Branch:** `main` (Latest Commit: `b009d41`)
- **Current Version:** `1.1.2+6`
- **GitHub Account:** `@JAFAR564` (Authenticated via `gh`)

---

## 🎨 Master 5-Color Visual Palette Specification
Source: `97f2a71f96978724029cf44e5ced6eda.jpg`
1. `#291C0E` (`const Color(0xFF291C0E)`) &rarr; **Deep Espresso** (Primary typography, heavy headings, dark borders)
2. `#6E473B` (`const Color(0xFF6E473B)`) &rarr; **Warm Terracotta** (Primary buttons, active indicators, brand accent)
3. `#A78D78` (`const Color(0xFFA78D78)`) &rarr; **Almond Taupe** (Borders, card outlines, subtle dividers)
4. `#BEB5A9` (`const Color(0xFFBEB5A9)`) &rarr; **Cashmere Stone** (Secondary subtitles, metadata, inactive indicators)
5. `#E1D4C2` (`const Color(0xFFE1D4C2)`) &rarr; **Frosted Cream Sand** (Scaffold background, pill cards, elevated surfaces)

---

## 🚀 Key Architectural & Operational Breakthroughs
1. **Universal 5-Color Master Palette Migration (Session 4):**
   - Completely purged legacy cyan (`0xFF00E5FF`, `0xFF00F0FF`, `0xFF007791`), dark obsidian (`0xFF0F0E17`, `0xFF161520`), and ancient gold (`0xFFD4AF37`, `0xFFB8860B`) tokens across all 15 presentation screens and custom widgets.
   - Standardized `PortalTheme.espresso`, `terracotta`, `taupe`, `cashmere`, and `cream` tokens.

2. **High-Speed Cloud CI Pipeline (75%+ Reduction):**
   - Implemented `--split-per-abi` in `.github/workflows/flutter-build.yml` targeting `arm64-v8a`.
   - Download payload dropped from ~86MB to ~18MB (`remainder-portal-arm64.apk`), cutting download duration from ~10m to ~1m20s.

3. **Master Branding & Multi-Platform Emblem Deployment:**
   - Full Android mipmap suite, iOS `AppIcon.appiconset`, and Web icons (`favicon.png`, `Icon-192.png`, `Icon-512.png`).

4. **Mobile Termux CI Operations Suite (`~/.bashrc`):**
   - `ci-watch`, `ci-logs`, `ci-trigger`, `ci-install` with native Android notifications.

---

## 🏛️ Dependency Graph & Architectural Guardrails (`graphify`)
```
[Presentation Layer] (Riverpod StateNotifiers / Master 5-Color Theme System)
       │  (dispatches & observes)
       ▼
[Domain Layer] (Entities / CalculateProgression / EvaluateConsensus / OKF Lore)
       │  (interfaces)
       ▼
[Data Layer] (Drift SQLite DB / LiteRT / Gemma Downloader / P2P Relay / UpdateService)
```
- **Rule 1:** Presentation strictly consumes Domain/Data providers; never write direct database SQL in widgets.
- **Rule 2:** Domain logic is 100% pure Dart, free from Flutter UI bindings.
- **Rule 3:** Heavy Flutter/Dart compilations are always offloaded to GitHub Actions cloud runners (`gh workflow run`).
