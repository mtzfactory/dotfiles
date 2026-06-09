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
  echo "${str//[^[:alnum:]_-]/-}"
}

# post-start hook: automatically applies .worktreeinclude when a new worktree
# is created via `wt switch --create` or `wt switch <branch>`.
# Configured in ~/.config/worktrunk/config.toml (symlinked from dotfiles).
# Requires: brew install satococoa/tap/git-worktreeinclude
# See: https://github.com/satococoa/git-worktreeinclude

# wt sync: rebase stacked worktree branches in dependency order.
# Works automatically once `wt-sync` is on PATH (cargo install worktrunk-sync).
# See: https://github.com/pablospe/worktrunk-sync

# Wrapper for wt switch that also connects to tmux session
wts() {
  wt switch "$@"

  # Build session name matching the worktrunk post-switch hook template:
  # '{{ repo_path | basename | sanitize }}_{{ branch | sanitize }}'
  # Use --git-common-dir to get the main repo path (not the worktree path)
  local folder=$(basename "$(dirname "$(git rev-parse --git-common-dir 2>/dev/null)")")
  local branch=$(git branch --show-current 2>/dev/null)
  local session="$(sanitize "$folder")_$(sanitize "$branch")"

  if tmux has-session -t "=$session" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "=$session"
    else
      tmux attach-session -t "=$session"
    fi
  fi
}
