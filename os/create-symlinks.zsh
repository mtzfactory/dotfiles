#!/usr/bin/env zsh

##
# Symlinks
#
local DOTFILES_SYMLINKS="$DOTFILES/symlinks"

##
# Git configs
declare -a GIT_CONFIGS=(
  "gitconfig"
  "gitconfig-personal"
  "gitconfig-work"
  "gitignore-global"
)

local GIT_CONFIG
for GIT_CONFIG in "${GIT_CONFIGS[@]}"; do
  local GIT_CONFIG_SYMLINK="$HOME/.$GIT_CONFIG"
  if [ ! -f "$GIT_CONFIG_SYMLINK" ]; then
    ln -s "$DOTFILES_SYMLINKS/git/$GIT_CONFIG" "$GIT_CONFIG_SYMLINK"
  fi
done

##
# App configs
local DOTFILES_SYMLINKS_CONFIG="$DOTFILES_SYMLINKS/config"

declare -a APP_CONFIGS=(
  "lazygit"
  "lvim"
  "pip"
)

local APP_CONFIG
for APP_CONFIG in "${APP_CONFIGS[@]}"; do
  if [ -x "$(command -v $APP_CONFIG)" ] || [[ "$(type -w $APP_CONFIG)" = *"alias" ]]; then
    local XDG_CONFIG_HOME_APP="$XDG_CONFIG_HOME/$APP_CONFIG"
    if [ ! -d "$XDG_CONFIG_HOME_APP" ]; then
      ln -s "$DOTFILES_SYMLINKS_CONFIG/$APP_CONFIG" "$XDG_CONFIG_HOME_APP"
    fi
  fi
done

##
# Ssh config
local HOME_SSH="$HOME/.ssh"
local HOME_SSH_CONFIG="$HOME_SSH/config"
if [ ! -f "$HOME_SSH_CONFIG" ]; then
  [ ! -d "$HOME_SSH" ] && mkdir -p "$HOME_SSH" && chmod 700 "$HOME_SSH"
  ln -s "$DOTFILES_SYMLINKS/ssh/config" "$HOME_SSH_CONFIG"
  chmod 600 "$HOME_SSH_CONFIG"
fi

