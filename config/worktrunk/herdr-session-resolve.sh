#!/bin/bash
# Worktrunk pre-remove hook: record which herdr workspace belongs to the
# worktree that is about to be deleted.
#
# Usage: herdr-session-resolve.sh <worktree_path>
#
# Why this exists: the reliable way to map a worktree to its herdr workspace is
# `herdr worktree list` (path -> open_workspace_id), but that mapping is gone
# the moment the checkout is removed. So the id is resolved here, while the
# worktree still exists, and stashed for the post-remove hook to consume.
#
# pre-remove hooks are blocking: this script always exits 0 so it can never
# abort a removal.

set -u

# shellcheck source=herdr-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/herdr-common.sh"

WORKTREE_PATH="${1:-}"

[ -n "$WORKTREE_PATH" ] || exit 0
herdr_running || exit 0

WORKSPACE_ID="$(herdr_workspace_for_path "$WORKTREE_PATH")"

if [ -n "$WORKSPACE_ID" ] && [ "$WORKSPACE_ID" != "null" ]; then
  mkdir -p "$HERDR_STASH_DIR" 2>/dev/null || exit 0
  printf '%s\n' "$WORKSPACE_ID" > "$(herdr_stash_file "$WORKTREE_PATH")" 2>/dev/null
fi

exit 0
