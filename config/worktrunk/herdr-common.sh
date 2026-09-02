#!/bin/bash
# Shared helpers for the worktrunk <-> herdr lifecycle hooks.
# Sourced by herdr-session-resolve.sh (pre-remove) and herdr-session-close.sh
# (post-remove). Not meant to be executed directly.

# Where pre-remove stashes "this worktree path -> this workspace id", so
# post-remove can still resolve the workspace after the checkout is deleted.
HERDR_STASH_DIR="${TMPDIR:-/tmp}/worktrunk-herdr"

# True when the herdr server is reachable.
herdr_running() {
  herdr workspace list >/dev/null 2>&1
}

# Stash file for a worktree path. Hashed so the key stays a single flat
# filename and survives the directory being removed.
herdr_stash_file() {
  local path="$1"
  printf '%s/%s\n' "$HERDR_STASH_DIR" \
    "$(printf '%s' "$path" | shasum -a 1 | cut -d' ' -f1)"
}

# Workspace id bound to a worktree checkout, using herdr's own
# worktree <-> workspace mapping. This is the robust key: it does not depend on
# label strings matching between the creating and closing scripts.
# Requires the checkout to still exist on disk.
herdr_workspace_for_path() {
  local path="$1"
  [ -n "$path" ] && [ -d "$path" ] || return 1
  herdr worktree list --cwd "$path" 2>/dev/null \
    | jq -r --arg p "$path" \
        '.result.worktrees[]? | select(.path == $p) | .open_workspace_id // empty' \
    | head -1
}

# Workspace id for an exact label. Fallback only.
herdr_workspace_for_label() {
  local label="$1"
  [ -n "$label" ] || return 1
  herdr workspace list 2>/dev/null \
    | jq -r --arg l "$label" \
        '.result.workspaces[]? | select(.label == $l) | .workspace_id' \
    | head -1
}

# True while the workspace still exists. `herdr workspace get` exits 0 even for
# an unknown id, so the JSON body is what decides.
herdr_workspace_exists() {
  local id="$1"
  [ -n "$id" ] || return 1
  herdr workspace get "$id" 2>/dev/null | jq -e '.result' >/dev/null 2>&1
}

# Close a workspace and everything in it. `workspace close` already takes the
# tabs with it; the tab sweep is a fallback for the case where a pane refuses
# to go and leaves the workspace behind.
herdr_close_workspace() {
  local id="$1"
  herdr workspace close "$id" >/dev/null 2>&1

  herdr_workspace_exists "$id" || return 0

  herdr tab list --workspace "$id" 2>/dev/null \
    | jq -r '.result.tabs[]?.tab_id' \
    | while read -r tab_id; do
        [ -n "$tab_id" ] && herdr tab close "$tab_id" >/dev/null 2>&1
      done
  herdr workspace close "$id" >/dev/null 2>&1
}
