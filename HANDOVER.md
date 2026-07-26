# 🤝 SESSION HANDOVER: Phase 1 Action Plan Execution

**Repository:** `remainder-portal` (`/home/vortex/remainder-portal`)  
**Branch:** `main`  
**Target Goal:** Execute approved Phase 1 Action Items to reach 100% Phase 1 PRD Compliance.  

---

## 📑 Key Reference Artifacts & Documentation
- **Approved Implementation Plan:** [phase1_implementation_plan.md](file:///home/vortex/.gemini/antigravity-cli/brain/6b68b114-1b9a-4511-be06-5d787c0e463f/phase1_implementation_plan.md)
- **Phase 1 Audit Report:** [AUDIT.md](file:///home/vortex/remainder-portal/AUDIT.md)
- **Product Vision & 4-Phase Roadmap:** [VISION.md](file:///home/vortex/remainder-portal/VISION.md)
- **Engineering Log:** [BRAINS.md](file:///home/vortex/remainder-portal/BRAINS.md)

---

## 🎯 Executive Checklist for Next Conversation

The next session should execute the following 3 concrete tasks in order:

### 🔴 Task 1: Offline Rule Engine Integration
- **File to Edit:** [lib/data/services/litert_service.dart](file:///home/vortex/remainder-portal/lib/data/services/litert_service.dart)
- **Action:** Replace raw HTTP error strings when offline (`catch (e)`) with a dynamic local deterministic RPG Rule Engine (`_generateOfflineStoryResponse`).
- **Engine Logic:**
  1. Generate a d20 roll (1–20) + stat modifier (derived from `characterClass`).
  2. Evaluate outcomes: Critical Success (18+), Success (10-17), Complication (6-9), Critical Failure (1-5).
  3. Format atmospheric cyber-gothic text starting with `[OFFLINE RULE ENGINE] D20 Roll: X + Y = Z...`.

### 🟠 Task 2: IC / OOC Dual Chat Mode
- **Files to Edit:**
  - [lib/presentation/providers/game_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/game_provider.dart)
  - [lib/presentation/screens/terminal_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/terminal_screen.dart)
- **Action:**
  1. Add `final bool isIC;` field to `MessageModel` (default `true`).
  2. Add `enum ChatFilter { all, icOnly, oocOnly }` and `chatFilterProvider`.
  3. In `TerminalScreen`, add a segmented view toggle (`ALL` | `IC ONLY` | `OOC ONLY`) in the subheader bar.
  4. Add an input mode toggle button (`[IC]` vs `[OOC]`) next to the chat text field.
  5. Render distinct styles for IC posts (glowing cyan/orange border, origin badge) vs OOC posts (frosted silver gray container).

### 🟠 Task 3: Drift Database Migration Strategy
- **File to Edit:** [lib/data/services/database_service.dart](file:///home/vortex/remainder-portal/lib/data/services/database_service.dart)
- **Action:** Override `MigrationStrategy get migration` in `AppDatabase` with `onCreate`, `onUpgrade` (for future version bumps), and `beforeOpen` (`PRAGMA foreign_keys = ON;`).

---

## ⚡ Verification Command Sequence
Once the changes are completed, run the following verification sequence in the terminal:

```bash
dart analyze
flutter test
git add .
git commit -m "feat(phase1): complete offline rule engine, IC/OOC dual chat mode, and Drift migration strategy"
git push
```

---

## 🚀 How to Prompt the Next Session
When opening your new conversation, send this prompt:

> `"Read file:///home/vortex/remainder-portal/HANDOVER.md and let's execute the Phase 1 action plan!"`
