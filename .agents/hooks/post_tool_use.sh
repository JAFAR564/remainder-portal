#!/usr/bin/env bash
# .agents/hooks/post_tool_use.sh
# Incremental AST re-parse with Graphify on code modifications

INPUT=$(cat)
TOOL_NAME=$(python3 -c 'import json, sys; d=json.load(sys.stdin); print(d.get("tool_name",""))' <<< "$INPUT" 2>/dev/null || echo "")

if [[ "$TOOL_NAME" =~ (write_to_file|replace_file_content|multi_replace_file_content) ]]; then
  # Run incremental update on changed files (fast tree-sitter AST re-parse)
  graphify . --update > /dev/null 2>&1 || true
fi

exit 0
