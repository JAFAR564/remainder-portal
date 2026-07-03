# Module 2: Technical Requirement Document (TRD)

## 2.1 — System Architecture Overview

```mermaid
graph TD
    subgraph "CLIENT LAYER — Flutter 3.44"
        A[Mobile iOS/Android] 
        B[Web — Flutter Web]
        C[Desktop — macOS/Windows]
    end

    subgraph "STATE & ROUTING"
        D[Riverpod 3.x AsyncNotifier]
        E[go_router 15.x — Route Guards]
    end

    subgraph "SERVICE LAYER — Dart"
        F[Google Sheets API Service]
        G[Multi-Model AI Router]
        H[Auth Service — Magic Links]
        I[OKF / RAG Service]
    end

    subgraph "MULTI-MODEL AI LAYER"
        J[DeepSeek R2 Pro\nStructural Grading]
        K[Groq — Llama 4 Scout\nFast Evaluation]
        L[Gemini 2.5 Pro\nPlot Synthesis]
        M[NotebookLM Plus\nCanonical RAG Source]
    end

    subgraph "DATA LAYER"
        N[Google Sheets\nPrimary Backend]
        O[Supabase\nAuth + Realtime + Deep Links]
        P[Firebase Storage\nImage Assets / IPAs]
    end

    subgraph "DEVOPS"
        Q[Harness CI/CD\n+ Codemagic for iOS]
        R[Google Stitch\nUI Design Canvas]
        S[Antigravity CLI agy\nCode Generation]
    end

    A & B & C --> D
    D --> E
    E --> F & G & H & I
    G --> J & K & L
    I --> M
    F --> N
    H --> O
    G --> O
    R -->|MCP Protocol| S
    S -->|Generated Dart| A
    Q --> A & B & C
```

---

## 2.2 — Project Structure

```
remainder_portal/
├── AGENTS.md                        # agy instruction file — coding rules, arch patterns
├── DESIGN.md                        # Stitch design system export — agent-readable
├── .agents/
│   └── skills/
│       ├── glass_card_skill.md      # Skill: generate glassmorphic widgets
│       ├── sheets_service_skill.md  # Skill: generate Sheets API calls
│       └── ai_router_skill.md       # Skill: generate AI routing logic
├── lib/
│   ├── main.dart
│   ├── theme/
│   │   └── portal_theme.dart
│   ├── router/
│   │   └── app_router.dart          # go_router config + route guards
│   ├── features/
│   │   ├── auth/                    # Magic link auth
│   │   ├── roster/                  # Community Roster feature
│   │   ├── admittance/              # Admin pipeline feature
│   │   ├── chronicles/              # World state / timeline feature
│   │   └── profile/                 # Character profile management
│   ├── services/
│   │   ├── sheets_service.dart      # Google Sheets read/write
│   │   ├── ai_router_service.dart   # Multi-model routing
│   │   ├── okf_service.dart         # OKF / RAG query interface
│   │   └── auth_service.dart        # Magic link + Supabase auth
│   ├── models/                      # Dart data classes (freezed)
│   └── ui/
│       ├── components/              # Shared: GlassCard, SpringTap, etc.
│       ├── layouts/                 # Responsive layout builders
│       └── animations/              # Custom springs, shimmer, glows
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── harness/                         # Harness pipeline YAML definitions
└── pubspec.yaml
```
