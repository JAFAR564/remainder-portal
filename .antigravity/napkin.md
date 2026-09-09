# 📱 Napkin Notes (Antigravity CLI & Mobile Termux Workspace)

## 🎯 Active Execution Context & Session State
- **Session ID:** `88d7ef76-46f7-4c8c-b65a-33a4ca08fa2c`
- **Target Device:** Honor X8 (Android / Termux environment)
- **Active Branch:** `main`
- **Current Version:** `1.1.8+12`
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
   - Completely purged legacy cyan, dark obsidian, and ancient gold tokens across all 15 presentation screens and custom widgets.
   - Standardized `PortalTheme.espresso`, `terracotta`, `taupe`, `cashmere`, and `cream` tokens.

2. **High-Speed Cloud CI Pipeline (75%+ Reduction):**
   - Implemented `--split-per-abi` in `.github/workflows/flutter-build.yml` targeting `arm64-v8a`.
   - Download payload dropped from ~86MB to ~18MB (`remainder-portal-arm64.apk`), cutting download duration to ~1m20s.

3. **UTRCS SQLite Persistence & Sanctuary Chat Hydration (Phase 1):**
   - Added Drift SQLite `UtrcsCharacters` table (Schema v4), hydrating character profile on startup and auto-persisting edits.
   - Wired `ChatHistoryNotifier` to `ChatMessages` table, saving every player action and GM response.
   - Injected configurable `BACKEND_URL` with mobile localhost trap detection and offline D20 fallback badging.

4. **Visual Luxury Redesign of Character Dossier & Live Play Card (Phase 4):**
   - Want vs. Need balance scale (`WantVsNeedScaleWidget`) with dynamic psychological equilibrium evaluation.
   - 8-stage cognitive processing loop timeline (`CognitiveLoopTimelineWidget`) mapping live character traits across decision steps.
   - 8-register voice player (`VoiceRegisterPlayerWidget`) with acoustic frequency wave animations and clipboard export.
   - 4-part anti-Mary-Sue capability anatomy cards (`CapabilityAnatomyCard`) with interactive D20 check simulation.
   - Ornate parchment astrolabe styling across `CharacterDossierScreen` and `UtrcsLivePlayCard`.

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
