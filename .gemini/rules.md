# 🏛️ Antigravity Operating Protocol & Visual Governance Rules

## 1. 🤝 Developer & Agent Division of Labor (The 4-Layer System)

| Layer | Component | Primary Responsibilities |
| :--- | :--- | :--- |
| **Layer 1** | **Developer (Architect & Final Authority)** | • Vision, constraints, scope definition, and acceptance criteria.<br>• Approving/rejecting architecture, dependencies, and irreversible decisions.<br>• Session hygiene, token monitoring (`/usage`), rollback triggers (`/rewind`, `/fork`).<br>• Secret management, credential protection, production release authorizations. |
| **Layer 2** | **AI Orchestrator** | • Task decomposition, dependency tracing, and risk identification.<br>• Drafting `implementation_plan.md` artifacts before code execution.<br>• Subagent delegation, lifecycle management, and structured synthesis.<br>• Continuous state maintenance across repository memory artifacts. |
| **Layer 3** | **Specialist Subagents** | • Ingesting noisy multi-thousand line logs (CI runs, compiler outputs, test failures).<br>• Performing isolated codebase research, dependency audits, and regression testing.<br>• Returning concise, 3-line structured summaries to the main orchestrator context. |
| **Layer 4** | **Persistent Artifacts (Repository as Memory)** | • `HANDOVER.md`: Master mobile setup, fast commands, and handover state.<br>• `BRAINS.md`: Chronological log of multi-agent development sessions.<br>• `ARCHITECTURE.md`: Module boundaries, data flow diagrams, and schema rules.<br>• `ACTIVE_TASK.md`: Real-time milestone tracker, active execution state, and checklists.<br>• `.antigravity/napkin.md` & `.gemini/napkin.md`: Session scratchpads and operational directives. |

---

## 2. 🎨 Master 5-Color Visual Theme Governance

All UI development, widgets, screens, and design audits **MUST strictly adhere** to the 5 master color tokens:

1. **Deep Espresso (`#291C0E` / `const Color(0xFF291C0E)`):** Primary typography, headings, dark borders, and obsidian accents.
2. **Warm Terracotta (`#6E473B` / `const Color(0xFF6E473B)`):** Primary buttons, active tabs, progress bars, and key interactive highlights.
3. **Almond Taupe (`#A78D78` / `const Color(0xFFA78D78)`):** Card borders, outlines, subtle glows, and secondary container frames.
4. **Cashmere Stone (`#BEB5A9` / `const Color(0xFFBEB5A9)`):** Subtitles, metadata, inactive tab indicators, and progress track backgrounds.
5. **Frosted Cream Sand (`#E1D4C2` / `const Color(0xFFE1D4C2)`):** Scaffold backgrounds, elevated cards, interactive pill badges.

> [!CAUTION]
> Legacy neon cyans, dark obsidian blacks, and ancient gold codes are strictly deprecated.

---

## 3. ⚡ Cloud CI & Local Offloading Directive

- **Device:** Honor X8 (Android / Termux).
- **Heavy Compilation Rule:** **NEVER** run heavy local Flutter/Dart compilations (`flutter build`, `flutter test`, `dart analyze`, `build_runner`) in Termux.
- **Offload Mechanism:** Commit code and trigger GitHub Actions workflows (`gh workflow run flutter-build.yml` or git push to `main`).
- **Monitoring & Sideloading:** Use `ci-watch` or dispatch subagent `ci-agent` for workflow tracking, and `ci-install` for fast ABI-split ARM64 deployment.
