---
name: graphify
description: >-
  Analyze codebase dependency graphs, architectural layers, coupling metrics,
  and dependency cycle prevention.
---

# Codebase Dependency & Knowledge Graph Skill

This skill guides architectural dependency inspection, module decoupling, and layer boundary enforcement.

## Layer Boundaries & Flow

```
Presentation Layer (UI / Providers / Widgets)
       │  (reads/dispatches)
       ▼
Domain Layer (Entities / Usecases / Progression Rules)
       │  (abstracts)
       ▼
Data Layer (Drift DB / OKF Repositories / P2P Relay / OTA Updater)
```

## Architectural Rules
1. **Unidirectional Flow**: Presentation depends on Domain; Domain has zero dependencies on Presentation or Flutter UI widgets.
2. **Circular Dependency Prevention**: Data models and repositories must never import presentation widgets or UI theme elements.
3. **Riverpod Provider Scoping**: Keep state notifiers scoped and modular to prevent massive re-render trees.
