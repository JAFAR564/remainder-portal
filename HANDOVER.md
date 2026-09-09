# 📱 MOBILE TERMUX MASTER HANDOVER & CONTEXT GUIDE

**Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Active Branch:** `main`  
**Current Version:** `1.1.8+12` (UTRCS Universal Roleplay Character Architecture Edition)  
**Target Environment:** Honor X8 (Termux + Antigravity AGY CLI)  
**Last Updated:** September 9, 2026  

---

## 📊 1. Executive Project Status (100% Complete)

- **Phase 1 Foundation & Drift DB:** **100%**
- **Phase 2 Social Sovereignty & Guilds:** **100%**
- **Phase 3 Offline Sync & RAG Vector Engine:** **100%**
- **Phase 4 Hardware Tiering & Gemma AI Downloader:** **100%**
- **Phase 4 Visual Luxury Redesign (Dossier & UTRCS Live Play Card):** **100%** (Want vs. Need Scale, 8-Stage Cognitive Loop, 8-Register Voice Player, 4-Part Capability Anatomy)
- **Master 5-Color Palette Theme Design System:** **100%** (Frosted Cream, Warm Terracotta, Deep Espresso, Almond Taupe, Cashmere Stone)
- **Fantasy Isekai Lore & Sci-Fi Purge:** **100%**
- **Interactive Genesis Story Mode (`StoryPrologueScreen`):** **100%**
- **UI Theme & Overflow Resolution across all 15 Screens:** **100%**
- **Shorebird OTA Cloud Code Push Infrastructure:** **100%**
- **8K Master Astrolabe App Icon Suite (Android/iOS/Web):** **100%**
- **Patrol Native Android E2E Testing & Emulator CI:** **100%**
- **Universal Roleplay Character System (UTRCS 6-Layer Architecture & Dossier Viewer):** **100%**
- **SQLite Persistence & AI Pipeline Hardening (Drift Schema v4, Chat Hydration, Backend URL):** **100%**
- **Multi-Platform ABI-Split Fast Cloud CI/CD:** **100% PASSING**

---

## 📲 2. Honor X8 Termux Setup & Migration Guide

When setting up development on the **Honor X8** phone in Termux:

### Step 1: Initial Termux & Git Setup on Honor X8
```bash
# 1. Grant storage permission (maps /sdcard -> /storage/emulated/0)
termux-setup-storage

# 2. Update packages and install Git + GitHub CLI
pkg update -y && pkg install git gh -y

# 3. Authenticate GitHub CLI
gh auth login

# 4. Clone repository
git clone https://github.com/JAFAR564/remainder-portal.git
cd remainder-portal
gh repo set-default JAFAR564/remainder-portal
```

### Step 2: Offloading Builds & Running Cloud Tests (Rule)
To keep the Honor X8 fast and conserve battery/RAM, **NEVER run heavy local `flutter` CLI compilations**. Offload all compilation and testing to GitHub Actions cloud runners:
```bash
# Push changes to trigger cloud build & tests
git add . && git commit -m "feat: my change" && git push origin main

# Check cloud CI workflow progress
gh run list -L 1

# Manually trigger a test run anytime
gh workflow run flutter-build.yml
```

### Step 3: High-Speed APK Download & Install on Honor X8 (5–10 seconds)
Once the cloud CI run passes:
```bash
# 1. Fast download from CDN release (~18MB arm64-v8a build)
gh release download latest -p "remainder-portal-arm64.apk" -D /sdcard/Download/ --clobber

# 2. Rename & launch installer popup immediately
mv /sdcard/Download/remainder-portal-arm64.apk /sdcard/Download/remainder-portal.apk
termux-open /sdcard/Download/remainder-portal.apk
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

### Color System (5-Color Master Palette)
- **Deep Espresso (`#291C0E`):** Primary typography, heavy headings, dark borders
- **Warm Terracotta (`#6E473B`):** Primary buttons, active indicators, brand accent
- **Almond Taupe (`#A78D78`):** Borders, card outlines, subtle dividers
- **Cashmere Stone (`#BEB5A9`):** Secondary subtitles, metadata, inactive indicators
- **Frosted Cream Sand (`#E1D4C2`):** Scaffold background, pill cards, elevated surfaces

### World Lore & Tone
- **AI Identity:** The **World Arbiter (Cardinal)**.
- **Narrative Genre:** Transcendent Fantasy Isekai / Roleplay Realm. All sci-fi jargon is strictly purged.
- **Conlang (Ethereal Scribe):** Incorporates *Amatsukrion*, *Wyrd-Kaze*, *Aetheromaru*, and *Kami-Aether*.
