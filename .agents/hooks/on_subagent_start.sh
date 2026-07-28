#!/usr/bin/env bash
# .agents/hooks/on_subagent_start.sh
# Subagent Lifecycle Initialization & Context Logger

INPUT=$(cat)
SUBAGENT_NAME=$(python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get("subagent_name",""))' <<< "$INPUT" 2>/dev/null || echo "")

DATE=$(date +%Y-%m-%d\ %H:%M:%S)
echo "[$DATE] [SUBAGENT_START] Subagent: ${SUBAGENT_NAME:-default}" >> .claude/subagent_audit.log 2>/dev/null || true

exit 0
