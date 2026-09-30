#!/bin/bash
# Worktrunk hook: open a herdr *worktree* workspace with four tabs when
# switching branches, if one doesn't already exist for this label.
#
# Usage: herdr-session.sh <label> <worktree_path> [base_worktree_path]
#
# Uses `herdr worktree open --cwd <base_worktree_path> --path <worktree_path>`
# (the same primitive behind the TUI's "New worktree"/"Open worktree..."
# menu, see `herdr worktree --help`) rather than `herdr workspace create`, so
# the new workspace is GROUPED under the space you switched FROM in the
# sidebar instead of appearing as a disconnected top-level space.
# base_worktree_path is worktrunk's "{{ base_worktree_path }}" — the worktree
# you switched from — falling back to $PWD if unset (e.g. manual invocation).

LABEL="$1"
WORKTREE_PATH="$2"
BASE_PATH="${3:-$PWD}"

if [ -z "$LABEL" ] || [ -z "$WORKTREE_PATH" ]; then
  echo "Error: label and worktree path required"
  exit 1
fi

# Skip if herdr server isn't running
if ! herdr workspace list >/dev/null 2>&1; then
  echo "⚠ Herdr server not running, skipping workspace creation"
  exit 0
fi

# Skip if wto is managing the workspace (it pre-creates the correct one)
if [[ -n "$_WTO_ACTIVE" ]]; then
  exit 0
fi

# Find existing workspace with this label
WORKSPACE_ID=$(herdr workspace list 2>/dev/null | jq -r --arg label "$LABEL" '.result.workspaces[] | select(.label == $label) | .workspace_id' | head -1)

if [ -n "$WORKSPACE_ID" ] && [ "$WORKSPACE_ID" != "null" ]; then
  echo "✓ Herdr workspace '$LABEL' already exists ($WORKSPACE_ID)"
  exit 0
fi

# Open as a herdr worktree workspace, grouped under the originating space
# ($BASE_PATH) in the sidebar. `--path` is the actual checkout to attach.
RESULT=$(herdr worktree open --cwd "$BASE_PATH" --path "$WORKTREE_PATH" --label "$LABEL" --no-focus)
WORKSPACE_ID=$(echo "$RESULT" | jq -r '.result.workspace.workspace_id')
FIRST_TAB_ID=$(echo "$RESULT" | jq -r '.result.tab.tab_id')

if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
  echo "Error: failed to open herdr worktree workspace"
  echo "$RESULT"
  exit 1
fi

# Create all four tabs with the correct worktree cwd, then close the
# auto-created first tab (its cwd is $BASE_PATH, not the new worktree).
herdr tab create --workspace "$WORKSPACE_ID" --label ai     --cwd "$WORKTREE_PATH" --no-focus >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label editor --cwd "$WORKTREE_PATH" --no-focus >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label metro  --cwd "$WORKTREE_PATH" --no-focus >/dev/null
herdr tab create --workspace "$WORKSPACE_ID" --label shell  --cwd "$WORKTREE_PATH" --no-focus >/dev/null
[ -n "$FIRST_TAB_ID" ] && [ "$FIRST_TAB_ID" != "null" ] && herdr tab close "$FIRST_TAB_ID" >/dev/null

echo "✓ Herdr worktree workspace '$LABEL' created ($WORKSPACE_ID)"
