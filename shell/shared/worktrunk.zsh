#!/usr/bin/env zsh

##
# WorkTrunk - Git worktree management
# https://worktrunk.dev

# Initialize WorkTrunk shell integration
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

sanitize() {
  local str="$1"
  # Replace non-allowed chars with '-' (matches worktrunk's sanitize filter)
  # Hyphen must be last in [...] to be literal, not a range operator
  # printf, not echo: zsh's echo swallows a lone "-", so `sanitize .` used to
  # return "" instead of "-" and silently dropped the repo prefix from labels.
  printf '%s\n' "${str//[^[:alnum:]_-]/-}"
}

# Directory name of the MAIN repository, i.e. worktrunk's `{{ repo_path | basename }}`.
# --path-format=absolute is required: from the primary worktree,
# `git rev-parse --git-common-dir` returns a relative ".git", whose dirname is
# "." — that is what produced labels like "_feat-foo" instead of
# "toc-sgp-app_feat-foo", leaving workspaces unclosable on `wt remove`.
_wt_repo_folder() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  [[ -n "$common" ]] || return 1
  basename "$(dirname "$common")"
}

# Session/workspace label, matching the worktrunk hook template exactly:
# '{{ repo_path | basename | sanitize }}_{{ branch | sanitize }}'
# Must stay in sync with the hooks in ~/.config/worktrunk/config.toml, otherwise
# the post-remove cleanup cannot find what wths()/wts() created.
_wt_label() {
  local branch="$1"
  printf '%s\n' "$(sanitize "$(_wt_repo_folder)")_$(sanitize "$branch")"
}

# post-start hook: automatically applies .worktreeinclude when a new worktree
# is created via `wt switch --create` or `wt switch <branch>`.
# Configured in ~/.config/worktrunk/config.toml (symlinked from dotfiles).
# Requires: brew install satococoa/tap/git-worktreeinclude
# See: https://github.com/satococoa/git-worktreeinclude

# wt sync: rebase stacked worktree branches in dependency order.
# Works automatically once `wt-sync` is on PATH (cargo install worktrunk-sync).
# See: https://github.com/pablospe/worktrunk-sync

# Runs a `wt switch` invocation and, if it fails only because the branch
# doesn't exist yet, offers to create it (equivalent to adding --create) and
# retries. Leaves any other failure (occupied path, branch already exists,
# etc.) untouched.
#
# Usage: _wt_switch_or_offer_create <runner-command-string> [switch-args...]
# <runner-command-string> is the command to run wt switch with, e.g.
# "wt switch" (shell-integrated, cds) or "command wt switch" (raw binary,
# used by wths() so the current pane's cwd is untouched).
_wt_switch_or_offer_create() {
  local runner="$1"
  shift
  local -a args=("$@")

  eval "$runner \"\${args[@]}\""
  local exit_code=$?
  [[ $exit_code -eq 0 ]] && return 0

  # Only offer to create when there's an explicit branch argument (skip the
  # interactive picker case).
  local branch_arg=""
  for arg in "${args[@]}"; do
    [[ "$arg" != -* ]] && branch_arg="$arg"
  done
  [[ -n "$branch_arg" ]] || return $exit_code

  # Already asked for --create? Then this failure is for another reason
  # (e.g. branch already exists) — don't offer again.
  for arg in "${args[@]}"; do
    [[ "$arg" == "-c" || "$arg" == "--create" ]] && return $exit_code
  done

  # Confirm the branch really doesn't exist (locally or remotely) before
  # assuming that's why wt switch failed.
  if wt list --format json --branches --remotes 2>/dev/null \
      | jq -e --arg b "$branch_arg" '.[] | select(.branch == $b)' >/dev/null 2>&1; then
    return $exit_code
  fi

  print -n "Branch '$branch_arg' doesn't exist. Create it? [y/N] "
  local reply
  read -r reply
  [[ "$reply" == [yY]* ]] || return $exit_code

  eval "$runner --create \"\${args[@]}\""
  return $?
}

# Wrapper for wt switch that also connects to tmux session
wts() {
  _wt_switch_or_offer_create "wt switch" "$@"
  local switch_exit=$?
  [[ $switch_exit -ne 0 ]] && return $switch_exit

  # Build session name matching the worktrunk post-switch hook template:
  # '{{ repo_path | basename | sanitize }}_{{ branch | sanitize }}'
  local branch=$(git branch --show-current 2>/dev/null)
  local session="$(_wt_label "$branch")"

  if tmux has-session -t "=$session" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "=$session"
    else
      tmux attach-session -t "=$session"
    fi
  fi
}

# Wrapper for wt switch that opens the target branch in a new herdr workspace
# WITHOUT changing the current workspace's working directory.
#
# Strategy: pre-create the herdr workspace, then run `command wt switch` (the
# binary, bypassing the shell function) in the current terminal. The binary
# creates the worktree and runs all hooks but does NOT cd, so the current
# workspace's path stays unchanged.
wths() {
  # Skip herdr flow if the server isn't running
  if ! herdr workspace list >/dev/null 2>&1; then
    _wt_switch_or_offer_create "wt switch" "$@"
    return
  fi

  # Parse branch name from args (last non-flag argument)
  local branch_arg=""
  for arg in "$@"; do
    [[ "$arg" != -* ]] && branch_arg="$arg"
  done

  if [[ -z "$branch_arg" ]]; then
    echo "wths: no branch specified" >&2
    return 1
  fi

  local label="$(_wt_label "$branch_arg")"

  # Look up existing workspace for this branch
  local workspace_id
  workspace_id=$(herdr workspace list 2>/dev/null \
    | jq -r --arg l "$label" '.result.workspaces[] | select(.label == $l) | .workspace_id' \
    | head -1)

  if [[ -z "$workspace_id" || "$workspace_id" == "null" ]]; then
    # ── Create workspace BEFORE wt switch ────────────────────────────────────
    # Pre-creating ensures the current workspace's pane CWD is never changed;
    # only the new workspace's pane will change to the worktree path.
    local result first_tab_id
    result=$(herdr workspace create --cwd "$PWD" --label "$label" --no-focus)
    workspace_id=$(echo "$result" | jq -r '.result.workspace.workspace_id')
    first_tab_id=$(echo "$result"  | jq -r '.result.tab.tab_id')

    if [[ -z "$workspace_id" || "$workspace_id" == "null" ]]; then
      echo "wths: failed to create herdr workspace, falling back to direct switch" >&2
      _wt_switch_or_offer_create "wt switch" "$@"
      return
    fi

    # Run wt switch as the raw binary (bypassing the shell function) in the
    # current terminal. `command wt` skips the shell function's `cd`, so the
    # current workspace's CWD is never changed. The binary still creates the
    # worktree, runs all pre-start/post-switch hooks, and prints progress here.
    # Set _WTHS_ACTIVE so herdr-session.sh (called by the post-switch hook)
    # skips workspace creation — wths already pre-created the correct one.
    export _WTHS_ACTIVE=1
    _wt_switch_or_offer_create "command wt switch" "$@"
    local wt_exit=$?
    unset _WTHS_ACTIVE

    if [[ $wt_exit -ne 0 ]]; then
      herdr workspace close "$workspace_id" >/dev/null 2>&1 || true
      return $wt_exit
    fi

    # Find the new worktree path for the remaining tabs' starting directory
    local new_path tab_cwd
    new_path=$(git worktree list --porcelain \
      | awk -v b="branch refs/heads/$branch_arg" '/^worktree /{p=$2} $0==b{print p; exit}')
    tab_cwd="${new_path:-$PWD}"

    # Create all four tabs with the correct worktree cwd, then close the
    # auto-created first tab (it was opened with $PWD = old path at pre-create time).
    herdr tab create --workspace "$workspace_id" --label ai       --cwd "$tab_cwd" --no-focus >/dev/null
    herdr tab create --workspace "$workspace_id" --label editor   --cwd "$tab_cwd" --no-focus >/dev/null
    herdr tab create --workspace "$workspace_id" --label metro    --cwd "$tab_cwd" --no-focus >/dev/null
    herdr tab create --workspace "$workspace_id" --label terminal --cwd "$tab_cwd" --no-focus >/dev/null
    herdr tab close "$first_tab_id" >/dev/null

  else
    # Workspace already exists — focus it; wt switch already ran (or will run
    # when the user is inside that workspace).
    :
  fi

  herdr workspace focus "$workspace_id"
  [[ -z "$HERDR_ENV" ]] && herdr
}
