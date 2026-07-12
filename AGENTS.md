# AGENTS.md — The Remainder Portal

This file serves as the system's "AI Constitution" and project-scoped rules. It guides and constrains the agy engine's code generation to maintain strict structural consistency and prevent architectural drift.

## Architecture Constraints
- ALL widgets must be built with Riverpod ConsumerWidget or ConsumerStatefulWidget
- NEVER use StatefulWidget with direct setState for business logic
- ALL async operations must use AsyncNotifierProvider
- Cross-platform breakpoints: mobile < 600dp | tablet 600–899dp | desktop 900dp+
- ALWAYS use LayoutBuilder, never MediaQuery.of(context).size directly

## Design System Rules
- ALL cards must use GlassCard from lib/ui/components/glass_card.dart
- GlassCard: Gaussian blur coefficients must be tuned within strict performance parameters to prevent GPU bottlenecks:
  - sigma_x, sigma_y in [6.0, 12.0]
- Touch animations MUST use SpringTapWrapper from lib/ui/animations/
- SpringTapWrapper: Must use an underdamped spring-mass-damper system with damping ratio (zeta) ≈ 0.85 (e.g., c=24 for k=200, m=1) for a fluid elastic rebound:
  - Equation: d^2x/dt^2 + 2*zeta*omega_n*dx/dt + omega_n^2*x = 0
- Color palette: ONLY use constants from lib/theme/portal_theme.dart
- Typography: Headlines=Cormorant Garamond, Body=Jost, Stats=JetBrains Mono
- Shader Compilation: Iridescent accents must use custom fragment shaders via the FragmentProgram API running on device GPU. Verify real-time compilation without main-thread skips on native Impeller backend on test device.

## Sheets Service Rules
- NEVER call Google Sheets API directly from Flutter client
- ALL Sheets operations route through CloudRunSheetsProxy service
- Use optimistic updates with Riverpod invalidation on error
- ROSTER DATA MUST BE CACHED LOCALLY: Use HydratedStateNotifier or Isar to store the roster as an offline-first cache. App opens instantly from local cache; background fetches update silently. This prevents Google Sheets API rate-limit exhaustion (60 req/min) and ensures snappy, fluid spring animations even on slow connections.

## AI Router & RAG Rules  
- NEVER call AI APIs directly from Flutter client
- ALL AI calls route through CloudRunAIRouter
- DeepSeek-V4-Pro: grading tasks (grounded in Gemini 1.5 Pro context caching RAG pipeline to bypass NotebookLM API vector search constraints)
- Groq Llama 4: real-time UI/tone evaluation tasks (latency budget < 200ms)
- Gemini 1.5 Pro: narrative chronicle synthesis and 2M token context caching RAG

## Routing & Deep Links
- Use go_router for ALL navigation with typed routes
- Deep Links: Test native intent filters (/login-callback) early to verify alignment with Supabase transactional token hashes.

## Code Style
- Use freezed for ALL data models
- Write widget tests for ALL GlassCard component variations

## Build & Compilation Constraints
- NEVER execute local native builds (e.g., `flutter build apk`) on the local WSL2 host to prevent terminal lockups and hardware freezes.
- Delegate all compilations to the GitHub Actions cloud runner pipeline.
- Commit current changes and push directly to git remote (`jafar` on `main`) to trigger compilation.
- Direct the user to monitor and fetch artifacts from the [Actions Dashboard](https://github.com/JAFAR564/remainder-portal/actions).
