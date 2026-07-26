# 🤝 SESSION HANDOVER: Phase 1 Action Plan & Compilation Cleanup

**Repository:** `remainder-portal` (`/home/vortex/remainder-portal`)  
**Branch:** `main`  
**Target Goal:** Complete Phase 1 PRD action items and run Drift code generation for zero compilation errors.  

---

## 📑 Key Reference Artifacts & Documentation
- **Approved Implementation Plan:** [phase1_implementation_plan.md](file:///home/vortex/.gemini/antigravity-cli/brain/6b68b114-1b9a-4511-be06-5d787c0e463f/phase1_implementation_plan.md)
- **Phase 1 Audit Report:** [AUDIT.md](file:///home/vortex/remainder-portal/AUDIT.md)
- **Product Vision & 4-Phase Roadmap:** [VISION.md](file:///home/vortex/remainder-portal/VISION.md)
- **Engineering Log:** [BRAINS.md](file:///home/vortex/remainder-portal/BRAINS.md)

---

## 🎯 Executive Checklist for Session 01 (`session: 01-database-and-domain`)

Execute the following 3 concrete tasks and code generation steps:

### 🔴 Task 1: Offline Rule Engine Integration
- **File to Edit:** [lib/data/services/litert_service.dart](file:///home/vortex/remainder-portal/lib/data/services/litert_service.dart)
- **Action:** Replace raw HTTP error strings when offline (`catch (e)`) with a dynamic local deterministic RPG Rule Engine (`_generateOfflineStoryResponse`).

### 🟠 Task 2: IC / OOC Dual Chat Mode
- **Files to Edit:**
  - [lib/presentation/providers/game_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/game_provider.dart)
  - [lib/presentation/screens/terminal_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/terminal_screen.dart)
- **Action:** Add IC/OOC toggle, `chatFilterProvider`, and visual styles for In-Character vs Out-of-Character messages.

### 🟠 Task 3: Drift Database Generation & Migration Cleanup
- **Files to Edit:**
  - [lib/data/services/database_service.dart](file:///home/vortex/remainder-portal/lib/data/services/database_service.dart)
  - [lib/presentation/screens/expedition_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/expedition_screen.dart)
- **Action:**
  1. Ensure `@DriftDatabase(tables: [...])` includes all tables (`Expeditions`, `ExpeditionMembers`, `Endorsements`, `Guilds`, `GuildMembers`, `GovernanceRules`, `LoreProposals`, `LoreHistory`, `OfflineQueue`, `PlayerTrades`, `TradeEscrow`, `CreatorContent`).
  2. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `database_service.g.dart`.
  3. Fix minor widget prop mismatches in `expedition_screen.dart` and `dashboard_screen.dart`.

---

## ⚡ Verification Command Sequence
Once completed, run the verification sequence:

```bash
dart run build_runner build --delete-conflicting-outputs
dart analyze
flutter test
git add .
git commit -m "feat(arch): resolve build_runner code generation, offline rule engine, and IC/OOC chat filters"
git push
```

---

## 🚀 How to Prompt the Next Session
When opening your new conversation (`session: 01-database-and-domain`), send this prompt:

> `"Read file:///home/vortex/remainder-portal/HANDOVER.md and let's execute Session 1!"`
