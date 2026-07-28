#!/usr/bin/env bash
# .agents/hooks/pre_tool_use.sh
# Guardrail & Safety validation before executing tool actions

INPUT=$(cat)
TOOL_NAME=$(python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get("tool_name",""))' <<< "$INPUT" 2>/dev/null || echo "")
COMMAND_LINE=$(python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get("arguments",{}).get("CommandLine",""))' <<< "$INPUT" 2>/dev/null || echo "")

# Guardrail against catastrophic operations
if [[ "$COMMAND_LINE" =~ (rm\ -rf\ /|git\ reset\ --hard\ HEAD~|mkfs|dd\ if=) ]]; then
  echo '{"status": "blocked", "reason": "Dangerous operation blocked by pre_tool_use guardrail"}'
  exit 1
fi

echo '{"status": "approved"}'
exit 0
