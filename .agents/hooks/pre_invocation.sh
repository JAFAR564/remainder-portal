#!/usr/bin/env bash
# .agents/hooks/pre_invocation.sh
# Session Start Context Injection for Mem0, Napkin, and Graphify (Antigravity CLI)

MEM0_PREFS=$(mem0 --agent search "user preferences and coding style" --user-id default 2>/dev/null)

NAPKIN_PATH=".antigravity/napkin.md"
if [ ! -f "$NAPKIN_PATH" ]; then
  if [ -f "scratch/napkin.md" ]; then
    NAPKIN_PATH="scratch/napkin.md"
  else
    mkdir -p .antigravity
    cat << 'EOF' > .antigravity/napkin.md
# Napkin Notes (Antigravity CLI Workspace)
## Active Execution Context
## User Feedback & Corrections
## Repo Architectural Directives
EOF
  fi
fi

# Escape napkin content cleanly using python3
NAPKIN_JSON=$(python3 -c 'import json, sys; print(json.dumps(open(sys.argv[1]).read()))' "$NAPKIN_PATH" 2>/dev/null || echo '""')
GRAPH_AVAIL=$([ -d "lib/graphify-out" ] && echo "true" || echo "false")

cat << EOF
{
  "hook_type": "context_injection",
  "mem0_memory": ${MEM0_PREFS:-"{}"},
  "napkin_notes": ${NAPKIN_JSON},
  "graphify_available": ${GRAPH_AVAIL}
}
EOF
exit 0
