---
name: napkin-memory
description: >-
  Maintain session-bound context scratchpads, persistent logs, and atomic handover notes
  to optimize context window efficiency across multi-agent sessions.
---

# Napkin Memory & Multi-Agent Context Skill

This skill defines the operational protocol for maintaining memory across agent sessions, context windows, and devices.

## Core Memory Locations

1. **`.antigravity/napkin.md`**: Rapid, high-density session scratchpad for recording current decisions, active task checklists, and immediate blockers.
2. **`BRAINS.md`**: Chronological engineering ledger tracking conversation IDs, milestone accomplishments, and modified files across sessions.
3. **`HANDOVER.md`**: Master state documentation containing executive project status, environment runbooks, and setup guides.

## Protocol & Conventions
- **Keep it Atomic**: Update `.antigravity/napkin.md` before concluding major steps.
- **Cross-Reference Sessions**: Record newly completed features in `BRAINS.md` under the active session ID.
- **Zero Hallucinated State**: Ensure documentation strictly matches verified repository state.
