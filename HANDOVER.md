# 🤝 SESSION HANDOVER: Session 01 Complete $\rightarrow$ Session 02 Action Plan

**Repository:** `remainder-portal` (`/home/vortex/remainder-portal`)  
**Branch:** `main`  
**Latest Commit:** `c9a1eb7` ("feat(arch): resolve build_runner code generation, offline rule engine, and IC/OOC chat filters")  
**Current Status:** Session 01 tasks completed and verified. Ready for Session 02.

---

## 📑 Key Reference Artifacts & Documentation
- **Phase 1 Implementation Plan:** [phase1_implementation_plan.md](file:///home/vortex/.gemini/antigravity-cli/brain/6b68b114-1b9a-4511-be06-5d787c0e463f/phase1_implementation_plan.md)
- **Phase 1 Audit Report:** [AUDIT.md](file:///home/vortex/remainder-portal/AUDIT.md)
- **Product Vision & 4-Phase Roadmap:** [VISION.md](file:///home/vortex/remainder-portal/VISION.md)
- **Engineering Log:** [BRAINS.md](file:///home/vortex/remainder-portal/BRAINS.md)

---

## ✅ Session 01 Accomplishments (`session: 01-database-and-domain`) - COMPLETED
1. **Offline Rule Engine Fallback:** Integrated local d20 dice roll + class attribute modifier (+3 Vanguard/Hacker) GM responses in `LiteRtService` when offline.
2. **IC / OOC Dual Chat Mode:** Added `isIC` status, `ChatFilter` provider, `[ALL] | [IC ONLY] | [OOC ONLY]` view filter, and IC/OOC input toggle in `TerminalScreen`.
3. **Drift Database Schema & Cleanup:** Added all 18 domain tables to `@DriftDatabase`, configured version 1 $\rightarrow$ 2 $\rightarrow$ 3 migration strategy, fixed widget prop syntax in `expedition_screen.dart`, and removed unused imports.

---

## 🎯 Executive Checklist for Session 02 (`session: 02-expeditions-and-social`)

Execute the following 3 concrete Phase 2 social & cooperative features:

### 🟢 Task 1: Cooperative Expeditions & Trust Matrix Integration
- **Files to Inspect/Verify:**
  - [lib/presentation/providers/expedition_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/expedition_provider.dart)
  - [lib/presentation/providers/trust_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/trust_provider.dart)
  - [lib/presentation/screens/expedition_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/expedition_screen.dart)
- **Action:** Ensure player trust metrics dynamically influence cooperative squad skill check modifiers in `ExpeditionScreen`.

### 🟢 Task 2: Sovereign Guild Treasury & Sector Governance
- **Files to Inspect/Verify:**
  - [lib/presentation/providers/guild_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/guild_provider.dart)
  - [lib/presentation/screens/guild_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/guild_screen.dart)
- **Action:** Verify guild creation, member rank assignments, treasury allocation, and sector law parameter displays.

### 🟢 Task 3: Democratic Chrono-Loom Lore Voting
- **Files to Inspect/Verify:**
  - [lib/presentation/providers/chrono_loom_provider.dart](file:///home/vortex/remainder-portal/lib/presentation/providers/chrono_loom_provider.dart)
  - [lib/presentation/screens/chrono_loom_screen.dart](file:///home/vortex/remainder-portal/lib/presentation/screens/chrono_loom_screen.dart)
- **Action:** Wire lore proposal submission and democratic voting mechanisms into local Drift database caching (`LoreProposals` & `LoreHistory`).

---

## ⚡ Recommended Offloaded Workflow
To prevent local hardware performance issues or terminal lag:
- Heavy compilation, build_runner code generation, and test execution are offloaded to **GitHub Actions workflows**.
- Commit and push changes directly to `main` for CI execution:
  ```bash
  git add .
  git commit -m "feat(social): implement Phase 2 cooperative squad checks and guild governance"
  git push
  ```

---

## 🚀 How to Prompt the Next Session
When opening your next conversation (`session: 02-expeditions-and-social`), send this prompt:

> `"Read file:///home/vortex/remainder-portal/HANDOVER.md and let's execute Session 2!"`
