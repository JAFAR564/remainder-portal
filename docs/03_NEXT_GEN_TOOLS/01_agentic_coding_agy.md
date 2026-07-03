# Module 3: Next-Gen & Agentic Tools Comparison

## 3.1 — Agentic Coding via `agy`: Paradigm Shift Analysis

> **Part of:** Module 3: Next-Gen Tools
> **Navigation:** Up to `README.md` | Next to `02_cicd_deployment.md`

---

### 3.1.1 — How `agy` Differs from Traditional Coding

Antigravity CLI brings the core capabilities of Antigravity 2.0 (multi-step reasoning, multi-file editing, tool calling, and persistent history) directly to your terminal.

Traditional Flutter development is a human-driven loop: spec → mental model → code → compile → debug → repeat. `agy` inverts this model into a goal-driven agentic loop.

| Dimension | Traditional Coding | `agy` Agentic Coding |
|---|---|---|
| **Input** | Developer writes Dart by hand | Developer describes goal in natural language |
| **Context** | Developer holds context mentally | `agy` reads widget tree, active routes, Dart analysis output, and running app state |
| **Multi-file edits** | Open files manually, edit in sequence | Agent edits multiple related files atomically |
| **Feedback loop** | Manual `flutter run` after each change | When Antigravity's agent modifies a Flutter file, it triggers Flutter's hot reload automatically |
| **Verification** | Developer runs tests manually | Agent can run tests and verify its own changes to ensure correctness |
| **Boilerplate** | High: freezed, Riverpod providers, go_router | Agent generates boilerplate from skill templates in `AGENTS.md` |

### 3.1.2 — Guardrails for Cross-Platform Flutter Codebases

**Guardrail 1: AGENTS.md as Architectural Constitution**
The `AGENTS.md` file is the agent's binding contract. Rules files placed in `.agents/skills/` or `AGENTS.md` instruct the agent on specific coding style guidelines or architectural patterns.

**Guardrail 2: Agent Mode Selection**
In Agent-driven mode, the agent runs commands (including hot reload) without asking for per-step approval. For production projects, use Review-driven mode instead, with the same capability but the agent pauses and asks before executing commands like `flutter pub add` or file deletions.

**Guardrail 3: Scoped Skill Files**
Each major architectural concern has its own skill file that constrains `agy`'s generation patterns:

```markdown
# .agents/skills/responsive_layout_skill.md
## Responsive Layout Skill
ALWAYS use ResponsiveLayout widget from lib/ui/layouts/responsive_layout.dart
NEVER use MediaQuery directly for breakpoints
Desktop implementations MUST use DataTable2 for tabular data
Mobile implementations MUST use ListView.builder for long lists
Tablet implementations MUST use GridView with crossAxisCount: 2
```

**Guardrail 4: CI Test Gates**
Every `agy`-generated file must pass through automated widget and unit tests in the Harness pipeline before merging.

**Guardrail 5: Security Audit Hook**
A pre-commit hook runs `dart analyze` and a custom security linter to detect any direct API key exposure, direct Sheets API calls from client, or unguarded admin routes.

---

## 3.2 — `agy` CLI vs. Antigravity IDE: Detailed Comparison

| Dimension | `agy` CLI | Antigravity IDE |
|---|---|---|
| **Interface** | Terminal TUI; keyboard-driven | VS Code fork; GUI + agent panel |
| **Speed** | Built in Go; significantly faster startup than Gemini CLI | Slightly heavier startup (Electron-based) |
| **MCP Integration** | Global MCP servers stored in `~/.antigravity/mcp_config.json` | Same config; GUI MCP store for discovery |
| **Best for** | CI/CD scripts, remote SSH sessions, headless servers, power users | Visual debugging, widget inspection, beginners |
| **Agentic Hot Reload** | ✅ Supported | ✅ Supported (native) |
| **Session export** | Can export terminal sessions to Antigravity 2.0 GUI | Can import CLI sessions |
| **Stitch MCP** | ✅ Via `mcp_config.json` | ✅ Via GUI MCP store |
| **Skill files** | `~/.gemini/antigravity-cli/skills` (global, CLI-only) | `~/.gemini/skills` (shared across tools) |
| **Remote dev** | ✅ Optimal (SSH-native) | ❌ Requires GUI forwarding |
| **Recommended for Remainder Portal** | ✅ CI/CD generation steps, bulk widget scaffolding, remote pipelines | ✅ Active development, visual iteration, design-to-code |

**Recommendation:** Use both in tandem. Design sessions use Antigravity IDE for visual MCP feedback. CI/CD and batch generation steps use `agy` CLI for speed and scriptability.
