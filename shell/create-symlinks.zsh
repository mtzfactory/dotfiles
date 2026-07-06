#!/usr/bin/env zsh

##
# Symlinks
#
local DOTFILES_SYMLINKS="$DOTFILES/config"

##
# Git configs
declare -a GIT_CONFIGS=(
  "gitconfig"
  "gitconfig-homelab"
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
declare -a APP_CONFIGS=(
  "lazygit"
  "lvim"
  "pip"
)

local APP_CONFIG
for APP_CONFIG in "${APP_CONFIGS[@]}"; do
  if [[ -n ${commands[$APP_CONFIG]} || -n ${aliases[$APP_CONFIG]} ]]; then
    local XDG_CONFIG_HOME_APP="$XDG_CONFIG_HOME/$APP_CONFIG"
    if [[ -d "$XDG_CONFIG_HOME_APP" ]] && [[ ! -L "$XDG_CONFIG_HOME_APP" ]]; then
      mv "$XDG_CONFIG_HOME_APP" "${XDG_CONFIG_HOME_APP}.bak"
      ln -s "$DOTFILES_SYMLINKS/$APP_CONFIG" "$XDG_CONFIG_HOME_APP"
    elif [[ ! -e "$XDG_CONFIG_HOME_APP" ]]; then
      ln -s "$DOTFILES_SYMLINKS/$APP_CONFIG" "$XDG_CONFIG_HOME_APP"
    fi
  fi
done

##
# WorkTrunk config
# Binary is `wt`, not `worktrunk`, so handled separately from APP_CONFIGS
if command -v wt >/dev/null 2>&1; then
  local XDG_CONFIG_HOME_WORKTRUNK="$XDG_CONFIG_HOME/worktrunk"
  if [[ -d "$XDG_CONFIG_HOME_WORKTRUNK" ]] && [[ ! -L "$XDG_CONFIG_HOME_WORKTRUNK" ]]; then
    mv "$XDG_CONFIG_HOME_WORKTRUNK" "${XDG_CONFIG_HOME_WORKTRUNK}.bak"
    ln -s "$DOTFILES_SYMLINKS/worktrunk" "$XDG_CONFIG_HOME_WORKTRUNK"
  elif [[ ! -e "$XDG_CONFIG_HOME_WORKTRUNK" ]]; then
    ln -s "$DOTFILES_SYMLINKS/worktrunk" "$XDG_CONFIG_HOME_WORKTRUNK"
  fi
fi

##
# Neovim config — selected by $NVIM_CONFIG (astronvim | nvim | lvim)
# lvim manages its own config dir (~/.config/lvim), not ~/.config/nvim
if [[ "$NVIM_CONFIG" != "lvim" ]]; then
  local NVIM_CONFIG_NAME="${NVIM_CONFIG:-astronvim}"
  local NVIM_DOTFILES_DIR="$DOTFILES_SYMLINKS/$NVIM_CONFIG_NAME"
  local NVIM_XDG_DIR="$XDG_CONFIG_HOME/nvim"
  if [[ -d "$NVIM_XDG_DIR" ]] && [[ ! -L "$NVIM_XDG_DIR" ]]; then
    mv "$NVIM_XDG_DIR" "${NVIM_XDG_DIR}.bak"
    echo "info: backed up $NVIM_XDG_DIR to ${NVIM_XDG_DIR}.bak"
    ln -s "$NVIM_DOTFILES_DIR" "$NVIM_XDG_DIR"
  elif [[ ! -e "$NVIM_XDG_DIR" ]]; then
    ln -s "$NVIM_DOTFILES_DIR" "$NVIM_XDG_DIR"
  fi
fi

##
# Ssh config
local HOME_SSH="$HOME/.ssh"
local HOME_SSH_CONFIG="$HOME_SSH/config"
if [ ! -f "$HOME_SSH_CONFIG" ]; then
  [ ! -d "$HOME_SSH" ] && mkdir -p "$HOME_SSH" && chmod 700 "$HOME_SSH"
  ln -s "$DOTFILES_SYMLINKS/ssh/config" "$HOME_SSH_CONFIG"
  chmod 600 "$HOME_SSH_CONFIG"
fi

