#!/usr/bin/env zsh

# Neovim config selector: astronvim (default) | nvim | lvim
# Override in your local shell profile before sourcing dotfiles, e.g.:
#   export NVIM_CONFIG=lvim
export NVIM_CONFIG="${NVIM_CONFIG:-astronvim}"

# editor
if [[ "$NVIM_CONFIG" == "lvim" ]]; then
  export EDITOR="lvim"
else
  export EDITOR="nvim"
fi

# fastlane
export FASTLANE_SKIP_ACTION_SUMMARY=1
export FASTLANE_HIDE_PLUGINS_TABLE=1
export FASTLANE_SKIP_UPDATE_CHECK=1
export SNAPSHOT_SKIP_OPEN_SUMMARY=1
