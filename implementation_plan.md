# 📋 Implementation Plan: Phase 4 — Visual Luxury Redesign of Character Dossier & UTRCS Live Play Card

**Target Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Active Branch:** `main`  
**Current Version:** `1.1.8+12`  
**Mode:** 🟡 **Thread B: Atomic Code Execution**  

---

## 1. Goal Description

Following the successful execution of **Phase 1 Persistence & AI Reality** (Drift SQLite schema v4, `UtrcsCharacters` table, `ChatMessages` SQLite hydration, configurable `BACKEND_URL`, and bio editing linkage), the active milestone moves to **Phase 4: Visual Luxury Redesign of the Character Dossier & UTRCS Live Play Card**.

The goal of this phase is to elevate the player character identity from a flat metadata sheet into an ornate, tactile **Celestial Astrolabe Parchment Dossier** that honors the master 5-color palette (`#291C0E`, `#6E473B`, `#A78D78`, `#BEB5A9`, `#E1D4C2`) and provides four specialized visual and roleplay interaction components:
1. **Want vs. Need Balance Scale:** An antique celestial balance beam widget displaying the psychological tension between conscious ambition (`externalWant`) and unconscious systemic healing (`internalNeed`), with dynamic tension state evaluation and interactive tuning.
2. **8-Stage Cognitive Processing Loop:** An interactive 8-step timeline stepper visualizing the exact decision loop utilized by the character and the Cognitive Loom AI Game Master (Sensory Intake → Appraisal → Want/Need Arbitration → Ethical Filter → Capability Selection → Voice & Intent → D20 Action Execution → Memory Integration).
3. **8-Register Voice Player UI:** An ornate acoustic dialogue quote player covering all 8 canonical roleplay registers (Formal, Battle, Intimate, Broken, Analytical, Casual, Ritual, Sardonic) with animated frequency audio bars, cadence indicators, and clipboard export.
4. **4-Part Anti-Mary-Sue Capability Anatomy:** Ornate cards segmenting each character capability into its 4 mandatory systemic pillars (Activation Cost, Scope & Boundary, Failure State Backlash, and Inherent Counter), paired with an interactive D20 check simulation roller.
5. **Dossier & Live Play Card Overhaul:** Re-styling `CharacterDossierScreen` and `UtrcsLivePlayCard` with warm parchment tones, astrolabe decorative accents, and seamless embedding of the new components while preserving 100% backward compatibility with existing tests.

---

## 2. Proposed Changes

```
┌────────────────────────────────────────────────────────────────────────┐
│               PHASE 4: VISUAL LUXURY REDESIGN ARCHITECTURE             │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Widget: want_vs_need_scale_widget.dart (Astrolabe balance beam)    │
│ 2. Widget: cognitive_loop_timeline_widget.dart (8-stage cognitive loop)│
│ 3. Widget: voice_register_player_widget.dart (8-register voice player) │
│ 4. Widget: capability_anatomy_card.dart (4-part anti-Mary-Sue cards)   │
│ 5. UI: utrcs_live_play_card.dart (Parchment luxury bottom sheet)       │
│ 6. Screen: character_dossier_screen.dart (Master astrolabe tabs)       │
│ 7. Test: test/phase4_visual_test.dart (Dedicated widget test suite)    │
│ 8. Test: test/character_dossier_test.dart (Regression verification)    │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Component 1: Want vs. Need Balance Scale Widget
#### [CREATE] `lib/presentation/widgets/want_vs_need_scale_widget.dart`
- Displays an ornate celestial balance scale with a fulcrum, beam, and hanging scale pans.
- Contrasts `externalWant` (Conscious Ambition) and `internalNeed` (Unconscious Healing).
- Dynamic tension assessment:
  - Ambition Dominant (>0.6): Warns of spiritual exhaustion.
  - Soul Rectification (<0.4): Prompts sacrifice of mortal ambitions.
  - Harmonic Equilibrium (0.4 - 0.6): Want and Need in celestial alignment.
- Interactive slider to inspect narrative inflection points.

---

### Component 2: 8-Stage Cognitive Processing Loop Widget
#### [CREATE] `lib/presentation/widgets/cognitive_loop_timeline_widget.dart`
- Renders the 8 canonical stages of roleplay decision-making:
  1. `S1: SENSORY INTAKE`
  2. `S2: APPRAISAL & FEAR`
  3. `S3: WANT/NEED ARBITRATION`
  4. `S4: ETHICAL FILTER`
  5. `S5: CAPABILITY SELECTION`
  6. `S6: VOICE & INTENT`
  7. `S7: D20 ACTION EXECUTION`
  8. `S8: MEMORY INTEGRATION`
- Provides an interactive stepper with animated transition and deep context cards binding each stage to the active character's data attributes.

---

### Component 3: 8-Register Voice Player Widget
#### [CREATE] `lib/presentation/widgets/voice_register_player_widget.dart`
- Features the 8 canonical voice registers:
  1. `Formal / Sovereign`
  2. `Battle / High-Intensity`
  3. `Intimate / Low Whisper`
  4. `Broken / Grief`
  5. `Analytical / Cold`
  6. `Casual / Campfire`
  7. `Ritual / Incantation`
  8. `Sardonic / Defiant`
- Includes animated audio frequency wave bars, cadence/pitch tags, playback simulation toggle, and instant clipboard export.

---

### Component 4: 4-Part Anti-Mary-Sue Capability Anatomy Card
#### [CREATE] `lib/presentation/widgets/capability_anatomy_card.dart`
- Visual parchment cards breaking down each `UtrcsCapability` into:
  1. `[ACTIVATION COST]` (Terracotta token)
  2. `[SCOPE & BOUNDARY]` (Taupe token)
  3. `[FAILURE BACKLASH]` (Espresso token)
  4. `[SYSTEMIC COUNTER]` (Cashmere Stone token)
- Interactive D20 Check simulation button rolling `d20 + d20Modifier` with live outcome dialog (Success vs Failure Backlash triggered).

---

### Component 5: UTRCS Live Play Card Luxury Overhaul
#### [MODIFY] `lib/presentation/widgets/utrcs_live_play_card.dart`
- Upgrade bottom sheet container with Frosted Cream parchment styling (`#FAF7F0`), dual terracotta borders, and celestial decorative corner brackets.
- Embed compact Want vs. Need mini-indicator.
- Embed compact 4-part capability pills.
- Embed compact voice quote preview with audio bars.
- Retain all test strings (`OPERATOR SUNG`, `ACTIVE CAPABILITIES`, `OPEN DOSSIER`, `DISCORD`, `JSON`).

---

### Component 6: Character Dossier Screen Luxury Overhaul
#### [MODIFY] `lib/presentation/screens/character_dossier_screen.dart`
- Elevate AppBar and TabBar with celestial astrolabe typography and borders.
- Overview Tab: Integrate `WantVsNeedScaleWidget`, high-concept parchment card, and sovereign stats.
- Capabilities Tab: Integrate `CapabilityAnatomyCard` instances with D20 test roll simulation and Add Capability modal.
- Psychology Tab: Integrate `CognitiveLoopTimelineWidget` and `VoiceRegisterPlayerWidget`.
- Lore & Bonds Tab: Ornate relationship pact seals and OOC consent boundary cards.
- Retain 100% of existing test assertion strings.

---

### Component 7: Unit & Widget Verification Suite
#### [CREATE] `test/phase4_visual_test.dart`
- Comprehensive test coverage for:
  - `WantVsNeedScaleWidget` rendering and tension calculations.
  - `CognitiveLoopTimelineWidget` 8-stage stepper switching and context bindings.
  - `VoiceRegisterPlayerWidget` 8-register switching, waveform animation state, and clipboard copy.
  - `CapabilityAnatomyCard` 4-quadrant anatomy rendering and D20 check simulation.
#### [MODIFY] `test/character_dossier_test.dart`
- Verify that existing test assertions pass without regression and add validation for the newly embedded luxury widgets.

---

## 3. Verification Plan

1. **Unit & Widget Tests:**
   - Execute dedicated Phase 4 test suite:
     ```bash
     flutter test test/phase4_visual_test.dart
     ```
   - Execute existing dossier and UTRCS test suite:
     ```bash
     flutter test test/character_dossier_test.dart test/utrcs_model_test.dart
     ```
2. **Cloud CI / Build Validation:**
   - Push atomic commit to `origin/main` and trigger GitHub Actions:
     ```bash
     gh workflow run flutter-build.yml
     ```
   - Verify Android, Web, and Windows builds pass with 0 analyzer errors.
