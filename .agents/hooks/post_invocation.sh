#!/usr/bin/env bash
# .agents/hooks/post_invocation.sh
# Persist user corrections into Napkin and Mem0

INPUT=$(cat)
USER_CORRECTION=$(python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get("user_feedback",""))' <<< "$INPUT" 2>/dev/null || echo "")

NAPKIN_PATH=".claude/napkin.md"
if [ ! -f "$NAPKIN_PATH" ]; then
  if [ -f "scratch/napkin.md" ]; then
    NAPKIN_PATH="scratch/napkin.md"
  fi
fi

if [ -n "$USER_CORRECTION" ]; then
  DATE=$(date +%Y-%m-%d)
  if [ -f "$NAPKIN_PATH" ]; then
    echo "| $DATE | User Feedback | $USER_CORRECTION | Applied |" >> "$NAPKIN_PATH"
  fi
  mem0 --agent add "User prefers: $USER_CORRECTION" --user-id default > /dev/null 2>&1 || true
fi

exit 0
