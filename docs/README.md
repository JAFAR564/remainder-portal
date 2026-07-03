# The Remainder Portal — Master Specification

**Version:** 1.0.0 | **Date:** June 30, 2026 | **Framework:** Flutter 3.44 | **Target:** Mobile-First (iOS/Android), Web, Desktop

---

## Document Index

| Module | File | Description |
|---|---|---|
| **PRD** | `01_PRD/01_vision_and_personas.md` | Product vision, core value propositions, user personas |
| **PRD** | `01_PRD/02_user_stories.md` | Player stories (P-01–P-06) & Administrator stories (A-01–A-07) |
| **PRD** | `01_PRD/03_functional_requirements.md` | FR-1 through FR-6: auth, roster, admittance, chronicles, profiles, AI dashboard |
| **PRD** | `01_PRD/04_ui_ux_vision.md` | Design language, GlassCard, SpringTap, theme, typography, color palette |
| **PRD** | `01_PRD/05_mobile_first_adaptability.md` | Breakpoint philosophy, pivot patterns (roster, admittance) |
| **TRD** | `02_TRD/01_system_architecture.md` | Architecture diagram, project structure |
| **TRD** | `02_TRD/02_data_knowledge_layer.md` | Google Sheets tabs, Sheets service, OKF architecture, anti-hallucination protocol |
| **TRD** | `02_TRD/03_multi_model_ai.md` | Model routing, Genkit Dart flows, responsibility matrix |
| **TRD** | `02_TRD/04_vibe_coding_pipeline.md` | Stitch→MCP→agy pipeline, AGENTS.md, Stitch Skills Loop |
| **TRD** | `02_TRD/05_state_management.md` | Riverpod architecture diagram, provider layer |
| **TRD** | `02_TRD/06_responsive_layout_and_auth.md` | Responsive layout system, magic link auth, deep linking security |
| **Tools** | `03_NEXT_GEN_TOOLS/01_agentic_coding_agy.md` | agy paradigm shift, agy CLI vs Antigravity IDE comparison |
| **Tools** | `03_NEXT_GEN_TOOLS/02_cicd_deployment.md` | Harness+Codemagic hybrid pipeline, backend comparison, migration path |
| **Tools** | `03_NEXT_GEN_TOOLS/03_notebooklm_rag_and_risk.md` | NotebookLM RAG loop, tools summary matrix, risk register |

---

## Key Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| UI Framework | Flutter 3.44 | Cross-platform (iOS/Android/Web/Desktop) from single codebase |
| State Management | Riverpod 3.x | Compile-safe, testable, no BuildContext dependency |
| Design Language | Light Ethereal / Warm Ivory | Frosted glass + soft-gold on `#FAF8F4` — aristocratic, luminous |
| Navigation | go_router 15.x | Typed routes, deep link support, route guards |
| Phase 1 Backend | Google Sheets + Cloud Run proxy | Existing admin familiarity, zero-migration start |
| Phase 2 Backend | Supabase | Realtime, RLS, pgvector, native magic link auth |
| AI Orchestration | Genkit Dart (Cloud Run) | Model-agnostic, typed schemas, observable flows |
| CI/CD | Harness orchestration + Codemagic builds | Enterprise policy + native Flutter mobile builds |
| Agentic Coding | agy CLI + Antigravity IDE | Stitch→MCP→agy pipeline for design-to-code loop |

---

## Status: Production-Ready v1.0.0
