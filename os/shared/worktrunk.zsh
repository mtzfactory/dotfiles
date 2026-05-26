#!/usr/bin/env zsh

##
# WorkTrunk - Git worktree management
# https://worktrunk.dev

# Initialize WorkTrunk shell integration
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

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
  local branch=$(git branch --show-current 2>/dev/null | tr '/' '-')
  if [[ -n "$branch" ]] && tmux has-session -t "$branch" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$branch"
    else
      tmux attach-session -t "$branch"
    fi
  fi
}
