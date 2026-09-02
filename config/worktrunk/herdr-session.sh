#!/bin/bash
# Worktrunk hook: Create herdr workspace with four tabs if it doesn't exist
# Usage: herdr-session.sh <label> [cwd]

LABEL="$1"
CWD="${2:-$PWD}"

if [ -z "$LABEL" ]; then
  echo "Error: label required"
  exit 1
fi

# Skip if herdr server isn't running
if ! herdr workspace list >/dev/null 2>&1; then
  echo "⚠ Herdr server not running, skipping workspace creation"
  exit 0
fi

# Skip if wths is managing the workspace (it pre-creates the correct one)
if [[ -n "$_WTHS_ACTIVE" ]]; then
  exit 0
fi

# Find existing workspace with this label
WORKSPACE_ID=$(herdr workspace list 2>/dev/null | jq -r --arg label "$LABEL" '.result.workspaces[] | select(.label == $label) | .workspace_id' | head -1)

if [ -n "$WORKSPACE_ID" ] && [ "$WORKSPACE_ID" != "null" ]; then
  echo "✓ Herdr workspace '$LABEL' already exists ($WORKSPACE_ID)"
  exit 0
fi

# Create workspace (first tab created automatically)
RESULT=$(herdr workspace create --cwd "$CWD" --label "$LABEL" --no-focus)
WORKSPACE_ID=$(echo "$RESULT" | jq -r '.result.workspace.workspace_id')
FIRST_TAB_ID=$(echo "$RESULT" | jq -r '.result.tab.tab_id')

if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
  echo "Error: failed to create herdr workspace"
  exit 1
fi

herdr tab rename "$FIRST_TAB_ID" ai >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label editor --no-focus >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label metro --no-focus >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label shell --no-focus >/dev/null

echo "✓ Herdr workspace '$LABEL' created ($WORKSPACE_ID)"
