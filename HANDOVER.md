# 📱 MOBILE TERMUX MASTER HANDOVER & CONTEXT GUIDE

**Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Active Branch:** `main` (Latest Commit: `2061493`)  
**Current Version:** `1.1.0+4` (Public Store Beta Release)  
**Last Updated:** July 31, 2026, 06:00 CEST  

---

## 📊 1. Executive Project Status (100% Complete)

- **Phase 1 Foundation & Drift DB:** **100%**
- **Phase 2 Social Sovereignty & Guilds:** **100%**
- **Phase 3 Offline Sync & RAG Vector Engine:** **100%**
- **Phase 4 Hardware Tiering & Gemma AI Downloader:** **100%**
- **Hellenic White Marble & Gold Design System:** **100%**
- **Fantasy Isekai Lore & Sci-Fi Purge:** **100%**
- **Interactive Genesis Story Mode (`StoryPrologueScreen`):** **100%**
- **UI Theme & Overflow Resolution across all Screens:** **100%**
- **Shorebird OTA Cloud Code Push Infrastructure:** **100%**
- **8K Pentelic White Marble & Imperial Gold App Icon:** **100%**
- **Multi-Platform CI/CD (Android + Web + Windows):** **100% PASSING**

---

## 📲 2. Termux Phone Environment Setup Guide

When continuing development on Android via Termux:

### Step 1: Clone Repository & Set Default
```bash
git clone https://github.com/JAFAR564/remainder-portal.git
cd remainder-portal
gh auth login
gh repo set-default JAFAR564/remainder-portal
```

### Step 2: Cloud CI Command Offloading (Rule)
To keep Termux fast and conserve phone battery/RAM, **NEVER run heavy local `flutter` CLI commands**. Offload all compilation and testing to GitHub Actions:
```bash
# Push changes to trigger cloud build
git add . && git commit -m "feat: my change" && git push origin main

# Check cloud CI workflow progress
gh run list -L 1

# View detailed CI logs if needed
gh run view <run_id>
```

---

## 🛠️ 3. Recommended Skills to Install / Enable

Equip your AI agent on Termux with the following specialized skills:

| Skill Name | Purpose | Location / Reference |
| :--- | :--- | :--- |
| **`antigravity-guide`** | Complete guide & sitemap for Antigravity, AGY CLI, slash commands, and MCP rules. | `builtin/skills/antigravity_guide/SKILL.md` |
| **`dart-run-static-analysis`** | Analyze code quality and apply automatic lint fixes via CI. | `config/skills/dart-run-static-analysis/SKILL.md` |
| **`dart-add-unit-test`** | Write unit tests using `package:test` for regression testing. | `config/skills/dart-add-unit-test/SKILL.md` |
| **`flutter-fix-layout-issues`** | Identify and resolve RenderFlex overflows and constraint issues. | `config/skills/flutter-fix-layout-issues/SKILL.md` |
| **`gh-cli`** | GitHub CLI automation for PRs, workflow runs, and release downloads. | `config/skills/gh-cli/SKILL.md` |
| **`graphify`** | Query codebase knowledge graph, god nodes, and dependency cycles. | `config/skills/graphify/SKILL.md` |
| **`napkin-memory`** | Maintain session-bound context scratchpads to optimize window usage. | `config/skills/napkin-memory/SKILL.md` |

---

## 🤖 4. Recommended Subagents to Create & Invoke

Define these specialized subagents using `define_subagent` when working on complex multi-step tasks:

### A. `ci-agent` (Cloud CI/CD & Workflow Specialist)
```yaml
name: ci-agent
description: Dedicated CI/CD subagent for monitoring GitHub Actions workflows, downloading build artifacts, and running Firebase Test Lab runs.
system_instructions: |
  You are the CI/CD Subagent for The Remainder Portal. Your sole responsibility is to handle cloud workflow operations:
  1. Pushing atomic commits to GitHub main.
  2. Monitoring GitHub Actions workflow runs (gh run list / gh run view).
  3. Downloading build artifacts (APKs, Web, Windows binaries).
  4. Running Firebase Test Lab cloud tests (gcloud firebase test android run) and retrieving screenshot/video artifacts.
  5. Always offload heavy Flutter/Dart compilation to GitHub Actions cloud runners.
```

### B. `qa-auditor` (Quality Assurance & Audit Specialist)
```yaml
name: qa-auditor
description: QA and Audit subagent for verifying PRD compliance, inspecting static analysis, and managing HANDOVER.md and napkin notes.
system_instructions: |
  You are the QA & System Audit Subagent for The Remainder Portal. Your responsibility is to maintain high code quality and architectural integrity:
  1. Verify PRD requirements against current codebase state.
  2. Check for missing imports, syntax errors, or type mismatches.
  3. Update HANDOVER.md and napkin memory scratchpads with accurate completion metrics.
  4. Ensure zero duplicate code or superficial symptom patches are introduced.
```

---

## 🎨 5. Design System Tokens & Tone Protocols

### Color System (Hellenic White Marble & Gold)
- **Backdrop / Main Screen:** `#F8F6F0` (Pentelic White Marble)
- **App Bar / Elevated Surfaces:** `#FAF8F5`
- **Cards & Containers:** `#FFFFFF` (Pure White Marble)
- **Borders & Dividers:** `#D4AF37` (Imperial Gold Leaf, 1.5px width)
- **Header Text & Titles:** `#B8860B` (Imperial Olympus Gold, Serif typography)
- **Body & Subtitle Text:** `#1A1A1A` (Obsidian Charcoal)
- **Secondary Accents:** `#007791` (Aegean Sky Cyan)

### World Lore & Tone
- **AI Identity:** The **World Arbiter (Cardinal)**.
- **Narrative Genre:** Transcendent Fantasy Isekai / Roleplay Realm. All sci-fi jargon is strictly purged.
- **Conlang (Ethereal Scribe):** Incorporates *Amatsukrion*, *Wyrd-Kaze*, *Aetheromaru*, and *Kami-Aether*.

---

## 📝 6. Recent Implementation Summary (Commits `6b83a61` $\rightarrow$ `2061493`)

1. **8K Hellenic App Icon & Emblem ([`assets/icon/app_icon.jpg`](file:///home/vortex/remainder-portal/assets/icon/app_icon.jpg)):**
   - Generated high-res Pentelic White Marble & Imperial Gold portal emblem.
   - Configured `flutter_launcher_icons` in `pubspec.yaml` to replace the default Flutter icon.

2. **Aether Resonance Oracle Widget ([`AetherResonanceOracleWidget`](file:///home/vortex/remainder-portal/lib/presentation/widgets/aether_resonance_oracle_widget.dart)):**
   - Added interactive d20 oracle roller to `DashboardScreen` for testing dynamic OTA updates.

3. **Shorebird OTA Cloud Code Push ([`shorebird.yaml`](file:///home/vortex/remainder-portal/shorebird.yaml)):**
   - Created Shorebird configuration and added automated cloud patch workflow to `.github/workflows/flutter-build.yml`.
   - Created `OtaPatchBannerWidget` for presenting background cloud patch alerts.

4. **UI Theme & Overflow Resolutions:**
   - Resolved 110px dashboard overflow, 74px squad invite overflow, 12px settings header overflow, social post wrapping, and nav bar dark container removal.
