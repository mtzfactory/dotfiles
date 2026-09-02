#!/bin/bash
# Worktrunk post-remove hook: close the herdr workspace (and therefore all its
# tabs) that belonged to the worktree just removed.
#
# Usage: herdr-session-close.sh <label> [worktree_path] [branch]
#
# Resolution order — first hit wins:
#   1. Workspace id stashed by the pre-remove hook (herdr-session-resolve.sh).
#      The only source that still works once the checkout is gone.
#   2. Live path -> workspace mapping via `herdr worktree list`. Covers the case
#      where pre-remove did not run or the checkout is still on disk.
#   3. Exact label match.
#   4. Legacy label "_<branch>" — workspaces created before the missing-repo-
#      prefix bug in worktrunk.zsh's wths()/wts() was fixed.
#
# Always exits 0: a failed cleanup must not make `wt remove` look broken.

set -u

# shellcheck source=herdr-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/herdr-common.sh"

LABEL="${1:-}"
WORKTREE_PATH="${2:-}"
BRANCH="${3:-}"

if [ -z "$LABEL" ] && [ -z "$WORKTREE_PATH" ]; then
  echo "herdr-session-close: label or worktree path required" >&2
  exit 0
fi

herdr_running || exit 0

WORKSPACE_ID=""
MATCHED_BY=""
STASH=""

# 1. pre-remove stash
if [ -n "$WORKTREE_PATH" ]; then
  STASH="$(herdr_stash_file "$WORKTREE_PATH")"
  if [ -s "$STASH" ]; then
    WORKSPACE_ID="$(head -1 "$STASH")"
    MATCHED_BY="pre-remove stash"
  fi
fi

# 2. live worktree path mapping
if [ -z "$WORKSPACE_ID" ] && [ -n "$WORKTREE_PATH" ]; then
  WORKSPACE_ID="$(herdr_workspace_for_path "$WORKTREE_PATH")"
  [ -n "$WORKSPACE_ID" ] && MATCHED_BY="worktree path"
fi

# 3. exact label
if [ -z "$WORKSPACE_ID" ] && [ -n "$LABEL" ]; then
  WORKSPACE_ID="$(herdr_workspace_for_label "$LABEL")"
  [ -n "$WORKSPACE_ID" ] && MATCHED_BY="label '$LABEL'"
fi

# 4. legacy label without the repo prefix
if [ -z "$WORKSPACE_ID" ] && [ -n "$BRANCH" ]; then
  WORKSPACE_ID="$(herdr_workspace_for_label "_$BRANCH")"
  [ -n "$WORKSPACE_ID" ] && MATCHED_BY="legacy label '_$BRANCH'"
fi

[ -n "$STASH" ] && rm -f "$STASH" 2>/dev/null

if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
  # Loud on purpose: the old version returned silently, which is why orphaned
  # workspaces went unnoticed.
  echo "⚠ Herdr: no workspace matched '${LABEL:-$WORKTREE_PATH}' — nothing closed" >&2
  exit 0
fi

if [ "${HERDR_WORKSPACE_ID:-}" = "$WORKSPACE_ID" ]; then
  # We are running inside the workspace we are about to close, so this pane dies
  # mid-call. nohup + background survives the SIGHUP and finishes the teardown.
  echo "✓ Herdr workspace $WORKSPACE_ID closing (matched by $MATCHED_BY) — this pane goes with it"
  nohup bash -c '
    source "$1/herdr-common.sh"
    sleep 0.3
    herdr_close_workspace "$2"
  ' _ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" "$WORKSPACE_ID" >/dev/null 2>&1 &
  disown 2>/dev/null || true
else
  herdr_close_workspace "$WORKSPACE_ID"
  echo "✓ Herdr workspace $WORKSPACE_ID closed (matched by $MATCHED_BY)"
fi

exit 0
