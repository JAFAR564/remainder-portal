# 📋 UTRCS Integration — Architecture Analysis & Implementation Plan

**Feature:** Universal Roleplay Character System (UTRCS) Character Template & Bio Viewer  
**Stage:** 🟢 **Executed & Completed**  
**Target Location:** `/data/data/com.termux/files/home/remainder-portal/implementation_plan.md`  
**Date:** August 28, 2026  

---

## 1. Executive Summary

### What Exists Today [VERIFIED]
* **Minimal 3-Attribute Character Sheet:** `CharacterSheet` with `computePower`, `shieldIntegrity`, and `energyReserve` stored in Drift SQLite (`Users` table).
* **Linear Genesis Onboarding:** `GenesisScreen` capturing basic character name, path selection (`Aether-Wake`, `Amatsukrion Sync`, `Wyrd-Born`), and allocating initial stats.
* **Basic Chat & Expedition Integration:** `TerminalScreen` with IC/OOC toggle passing only `characterClass` string to `LiteRtService`; `ExpeditionScreen` running d20 checks via `EvaluateCooperativeCheck` based on raw stat sums and trust scores.

### What UTRCS Adds [PROPOSED]
* **6-Layer Character Architecture:** Invariant Identity (Wound, Lie, Want/Need, Fear, Contradictions), Setting, Role, Tripartite Relationships, Mechanical Capabilities (Scope, Cost, Condition, Failure), and Presentation.
* **Progressive Completion Depths:** Quick (5-min entry), Standard (full group RP/expeditions), and Deep (long-term chronicles/lore).
* **Machine-Readable Capability Engine:** Capabilities with structured operational tags consumed directly by the Expedition d20 resolver.
* **AI Behavioral & Voice Context Projections:** Converting character traits, voice cadence, and reaction matrices into token-efficient context packets for on-device Gemma LiteRT and cloud World Arbiter inference.
* **Portable Export & At-a-Glance Live-Play Card:** Instant character export and a scannable live-play card accessible during active chat and expeditions.

### Recommended Integration Strategy [PROPOSED]
* **Progressive Schema Extension:** Extend Drift SQLite with a new dedicated `UtrcsCharacters` table (storing structured JSON documents versioned by schema) while maintaining backward compatibility with the existing `Users` and `CharacterSheet` tables.
* **Tiered Context Projections:** Rather than dumping the entire Deep character dossier into the AI context window, generate targeted, token-budgeted projections (*Identity Context*, *Voice/Dialogue Context*, *Mechanical Capability Context*).
* **Unified Character Dossier UI:** Create an adaptive, tabbed `CharacterDossierScreen` supporting Quick/Standard/Deep views with an interactive **At-a-Glance Bottom Sheet Card** for in-game reference.

### Major Architectural Decisions & Risks [PROPOSED]
1. **Decision:** Use a structured, versioned JSON payload (`schemaVersion: "1.0.0"`) inside Drift SQLite for flexible UTRCS layers rather than fragmenting 40+ dynamic fields across separate relational SQL tables.
2. **Primary Risk:** AI context budget overflow when passing character data on low-memory mobile devices (Honor X8). Mitigated by strict token budgets ($<250$ tokens for local LiteRT, $<600$ tokens for cloud).

---

## 2. Repository Findings

| Component | Repository Fact | Verification Status |
| :--- | :--- | :---: |
| **Framework & Language** | Flutter 3.44.4 / Dart 3.12.2, Null-Safety | **VERIFIED** |
| **State Management** | Flutter Riverpod (`StateNotifierProvider`, `Provider`, `StateProvider`) | **VERIFIED** |
| **Persistence Engine** | Drift SQLite (`AppDatabase` with Native SQLite bindings) | **VERIFIED** |
| **Local AI Engine** | `LiteRtService` routing to local LiteRT-LM (Gemma 3 1B) for Tier S/A+ devices or Cloud Genkit / Deterministic d20 Fallback | **VERIFIED** |
| **Active Player Profile** | `playerProfileProvider` (`PlayerProfileNotifier`) managing single active profile | **VERIFIED** |
| **Combat & Check Resolvers**| `EvaluateCooperativeCheck` evaluating d20 rolls with stat contributions & trust scores | **VERIFIED** |
| **Chat System** | `TerminalScreen` with `isIC` filter toggles and `ChatHistoryNotifier` | **VERIFIED** |
| **UI Theme Tokens** | 5-Color Master Palette: Deep Espresso (`#291C0E`), Warm Terracotta (`#6E473B`), Almond Taupe (`#A78D78`), Cashmere Stone (`#BEB5A9`), Frosted Cream Sand (`#E1D4C2`) | **VERIFIED** |
| **Testing Architecture** | Unit tests (`flutter_test`), Widget tests, and Patrol E2E tests (`integration_test/`) | **VERIFIED** |

---

## 3. UTRCS Gap Analysis

| UTRCS Layer / Subsystem | UTRCS Specification Requirement | Existing Repository Equivalent | Gap | Recommended Treatment |
| :--- | :--- | :--- | :--- | :---: |
| **Layer 1: Identity** | Wound, Lie, Want/Need, Fear, Values, Contradictions | `PlayerProfile.origin` string | No psychological or internal conflict modeling | **NEW** (Store in UTRCS model) |
| **Layer 2: Setting** | World metaphors, faction standing, lore anchor | `PlayerProfile.activeSector` | Only simple sector string exists | **EXTEND** (Link to OKF lore) |
| **Layer 3: Role** | Tactical archetype, squad position | `reputationRanks` JSON string | Untyped JSON string without role mechanics | **EXTEND** (Structured role model) |
| **Layer 4: Relationship** | Tripartite model (Belief / Canon Fact / OOC Consent) | `Endorsements` & `ExpeditionMembers` | Only numeric trust scores exist | **NEW** (Tripartite relationship ledger) |
| **Layer 5: Mechanical** | Capabilities with Scope, Cost, Condition, Failure | `CharacterSheet` (3 numeric ints) | No structured skills or power limits | **NEW** (Structured capability model) |
| **Layer 6: Presentation**| Voice syntax, samples, nonverbal micro-actions | Display name & avatar path | No dialogue modeling | **NEW** (Voice & syntax rules) |
| **Behavioral Pipeline** | 8-stage stimulus-response decision loop | `_generateOfflineStoryResponse` | Hardcoded d20 outcome text | **DERIVED** (Project into AI prompts) |
| **Reaction Matrix** | 5-10 row trigger-response tendency table | None | No pre-configured behavioral impulses | **NEW** (Standard/Deep optional) |
| **Continuity Ledger** | High-value state tracking (debts, injuries) | `SyncLedger` | Only technical database sync tracked | **EXTEND** (Player state ledger) |
| **Evolution Tracker** | 4-state arc progression (Start, Current, Emerging, Future) | Level int (`88`) | No narrative arc tracking | **DEFERRED** (Future Phase 6) |

---

## 4. Proposed Data Model

```
┌────────────────────────────────────────────────────────────────────────┐
│                        UtrcsCharacterModel                             │
├────────────────────────────────────────────────────────────────────────┤
│ • id: String (UUID)                 • schemaVersion: "1.0.0"           │
│ • completionDepth: Quick | Standard | Deep                             │
│ • createdAt / updatedAt: DateTime   • syncStatus: Int                  │
├────────────────────────────────────────────────────────────────────────┤
│ 1. IdentityLayer (Invariant Core)                                      │
│    - name: String                   - concept: String (one-liner)      │
│    - coreWound: String?             - internalLie: String?             │
│    - externalWant: String           - internalNeed: String?            │
│    - coreFear: String               - values: List<String>             │
│    - contradictions: List<String>   - defaultBaseline: DefaultState?   │
├────────────────────────────────────────────────────────────────────────┤
│ 2. SettingLayer & 3. RoleLayer                                         │
│    - sectorOrigin: String           - factionAffiliation: String?      │
│    - tacticalArchetype: String      - guildRole: String?               │
├────────────────────────────────────────────────────────────────────────┤
│ 4. RelationshipLayer (Tripartite)                                      │
│    - relationships: List<UtrcsRelationshipEntry>                       │
│      [targetId, targetName, icBelief, establishedFact, oocAgreement]   │
├────────────────────────────────────────────────────────────────────────┤
│ 5. MechanicalLayer (Capabilities & Stats)                              │
│    - baseStats: CharacterSheet (compute, shield, energy)               │
│    - capabilities: List<UtrcsCapability>                               │
│      [name, type, scope, cost, condition, failureState, d20Modifier]   │
│    - weaknesses: List<UtrcsWeakness> [name, description, invocableBy]  │
├────────────────────────────────────────────────────────────────────────┤
│ 6. PresentationLayer (Voice & Format)                                  │
│    - voiceSyntax: String (cadence/formality)                           │
│    - voiceSamples: Map<String, String> (insult, compliment, argue...)  │
│    - nonverbalTells: List<String>                                      │
│    - oocConsentLimits: List<String> (content boundaries / hard limits) │
└────────────────────────────────────────────────────────────────────────┘
```

### Progressive Completion Requirements

| Field / Section | Quick Mode | Standard Mode | Deep Mode |
| :--- | :---: | :---: | :---: |
| **Name & Concept** | **Required** | **Required** | **Required** |
| **External Want & Core Fear** | **Required** | **Required** | **Required** |
| **Core Wound & Internal Need** | *Optional* | **Required** | **Required** |
| **Contradictions** | *Optional* | **Required (1-2)** | **Required (2-3)** |
| **Capabilities (Scope/Cost/Fail)** | 1 Basic | 2-3 Balanced | 4-5 Detailed |
| **Voice Syntax & Samples** | 1 Sample Line | 4 Registers | 8 Registers |
| **Tripartite Relationships** | *Optional* | 2-3 Key Contacts | Complete Web |
| **Reaction Matrix (5-10 rows)** | *Omitted* | 5 Rows | 10 Rows |
| **Continuity Ledger** | *Omitted* | *Optional* | Active Tracking |

---

## 5. Screen & UX Architecture

### 1. Creation Flow: Progressive Disclosure
* **UX Strategy:** Rather than an intimidating multi-page form, start in **Quick Mode (3 minutes)**.
* Upon completing Quick Mode, an optional banner offers: *"Deepen Character Psychology (Standard/Deep)"*, unlocking deeper tabs without invalidating the character.

### 2. Character Dossier (`CharacterDossierScreen`)
* **Tab 1: Overview & Persona:** High concept, visual emblem, core want/need, values, and default downtime state.
* **Tab 2: Capabilities & Loadout:** Structured capability cards with clear badges for Scope, Cost, Condition, and Failure consequences.
* **Tab 3: Psychology & Voice:** Core wound/lie, contradictions, voice registers, and dialogue sample selector.
* **Tab 4: Relationships & Lore:** Tripartite relationship ledger and OKF sector links.

### 3. At-a-Glance Live-Play Card (`UtrcsLivePlayCard`)
* Modal bottom sheet accessible via a quick icon in **Sanctuary Chat (`TerminalScreen`)** and **Squad Matrix (`ExpeditionScreen`)**.
* Contains: Concept, immediate want, 3 traits with tells, 1 voice sample, active capabilities summary, and hard OOC boundaries.

---

## 6. Integration Architecture & Data Flows

```
[Genesis / Dossier UI]
        │
        ▼
[UtrcsCharacterModel] ───(Validate & Store)───► [Drift SQLite: UtrcsCharacters]
        │
        ├─────────────────────────────────────────┬────────────────────────────────────────┐
        ▼                                         ▼                                        ▼
[Mechanical Projection]                   [AI Context Builder]                    [Portable JSON Export]
        │                                         │                                        │
        ▼                                         ▼                                        ▼
[EvaluateCooperativeCheck]             [LiteRt / Gemma Context]                   [Clipboard / File Export]
  • Capability Modifiers                 • Identity & Want/Need (40 tok)            • Portable UTRCS JSON
  • Scope & Failure Rules                • Voice & Dialogue Cadence (30 tok)        • Human-readable text
  • Expedition d20 Matrix                • Behavioral Boundaries (30 tok)           • Discord card format
```

---

## 7. Phased Implementation Plan

```
Phase 0 ──► Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5
(Core Mod)  (Quick UI)  (Deep UI)   (Export)    (Expedition)(AI Context)
```

### Phase 0: Domain Models & Drift Database Foundation
* **Objective:** Define immutable UTRCS domain models and Drift SQLite persistence table with JSON serialization.
* **Repository Areas:** `lib/data/models/utrcs_character.dart`, `lib/data/services/database_service.dart`, `lib/presentation/providers/utrcs_provider.dart`.
* **Size:** **M** | **Risk:** Low.
* **Exit Criteria:** Unit tests pass verifying serialization, deserialization, and schema validation.

### Phase 1: Quick Mode Creation & Dossier Viewer
* **Objective:** Deliver the complete create $\rightarrow$ save $\rightarrow$ inspect loop in Quick Mode.
* **Repository Areas:** `lib/presentation/screens/utrcs_creation_screen.dart`, `lib/presentation/screens/character_dossier_screen.dart`, `lib/presentation/widgets/utrcs_live_play_card.dart`.
* **Size:** **L** | **Risk:** Low.
* **Exit Criteria:** Player can create a Quick character, inspect the dossier, and view the At-a-Glance card.

### Phase 2: Standard & Deep Expansion (Psychology & Voice)
* **Objective:** Add progressive disclosure tabs for Want/Need quads, 4-part capabilities, and voice registers.
* **Repository Areas:** `lib/presentation/widgets/utrcs_capability_card.dart`, `lib/presentation/widgets/utrcs_psychology_tab.dart`.
* **Size:** **M** | **Risk:** Low.
* **Exit Criteria:** Player can expand an existing Quick character to Standard or Deep.

### Phase 3: Portable Export & Formatting
* **Objective:** Implement UTRCS JSON export and Discord/Forum text formatters.
* **Repository Areas:** `lib/data/services/utrcs_export_service.dart`.
* **Size:** **S** | **Risk:** Low.
* **Exit Criteria:** Character can be copied to clipboard as UTRCS JSON or Discord card.

### Phase 4: Expedition Mechanical Integration
* **Objective:** Feed capability scopes, costs, and modifiers into `EvaluateCooperativeCheck`.
* **Repository Areas:** `lib/domain/usecases/evaluate_cooperative_check.dart`, `lib/presentation/screens/expedition_screen.dart`.
* **Size:** **M** | **Risk:** Medium.
* **Exit Criteria:** Active character's capabilities appear as selectable skills in squad checks.

### Phase 5: World Arbiter & Gemma LiteRT Context Integration
* **Objective:** Project voice and behavioral rules into `LiteRtService` prompt pipelines.
* **Repository Areas:** `lib/data/services/litert_service.dart`, `lib/presentation/providers/game_provider.dart`.
* **Size:** **M** | **Risk:** Medium.
* **Exit Criteria:** World Arbiter responses reflect character traits within token limits.

---

## 8. Testing Strategy

1. **Data Layer Tests (`test/utrcs_model_test.dart`)**:
   - Verify Quick, Standard, and Deep JSON round-trip serialization.
   - Verify validation fails on missing required fields for each depth level.
2. **UI & Widget Tests (`test/character_dossier_test.dart`)**:
   - Verify tab navigation across Overview, Capabilities, Psychology, and Lore.
   - Verify `UtrcsLivePlayCard` bottom sheet rendering.
3. **Mechanics & Expedition Tests (`test/utrcs_expedition_test.dart`)**:
   - Test capability modifiers and failure consequences inside `EvaluateCooperativeCheck`.
4. **AI Context Budget Tests (`test/utrcs_ai_projection_test.dart`)**:
   - Ensure generated prompt projections remain under 150 tokens.

---

## 9. Risk Assessment & Mitigations

| Risk | Prob. | Impact | Evidence | Mitigation Strategy | Phase |
| :--- | :---: | :---: | :--- | :--- | :---: |
| **Low-Memory Mobile Overhead** | Low | Med | Honor X8 has 4-6GB RAM | Use lightweight JSON caching in Drift SQLite; lazy-load Deep tabs. | Phase 0 |
| **AI Prompt Token Explosion** | High | High | Gemma 3 1B has tight context limits | Enforce token-budgeted projections ($<150$ tokens) rather than raw dossiers. | Phase 5 |
| **Data Migration of Legacy Profiles** | Low | Low | Only `Users` table currently exists | Auto-synthesize a valid Quick UTRCS character from legacy profile name/class. | Phase 0 |
| **Form Fatigue During Creation** | High | Med | Deep mode has 30+ fields | Enforce Quick Mode by default with optional progressive deepening. | Phase 1 |

---

## 10. Deferred / Simplified UTRCS Systems

* **Evolution Tracker (4-State Arcs):** Deferred to Phase 6 to prevent overcomplicating initial release.
* **Full Multi-User Consent Web:** Simplified to local OOC boundary tags and relationship notes in v1.
* **10-Row Reaction Matrix:** Simplified to 5 standard triggers in Standard Mode; full 10 rows optional in Deep Mode.

---

## 11. Open Questions

### Non-Blocking Decisions (Sensible Defaults Recommended)
1. **Default Storage Mode:**
   - *Recommendation:* Store UTRCS character payload as a versioned JSON string in Drift SQLite table `UtrcsCharacters`.
2. **Export Format:**
   - *Recommendation:* Support both machine-readable JSON and human-readable Markdown/Discord card format.

---

## 12. Thread B Execution Handoff

### Approved Architecture
* Modular 6-layer UTRCS architecture supporting Quick $\rightarrow$ Standard $\rightarrow$ Deep progressive disclosure.
* Drift SQLite persistence with typed JSON serialization and AI context projection pipelines.

### First Implementation Task in Thread B
* Create `lib/data/models/utrcs_character.dart` and add `UtrcsCharacters` table to `lib/data/services/database_service.dart`.
