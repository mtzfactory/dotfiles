#!/usr/bin/env zsh

##
# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

## 
# Zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

##
# Zsh extensions
autoload -U zmv

local USR_LOCAL_BIN="/usr/local/bin"
[ ! -d "$USR_LOCAL_BIN" ] && sudo mkdir -p "$USR_LOCAL_BIN"
[ -d "$USR_LOCAL_BIN" ] && export PATH="$USR_LOCAL_BIN:$PATH"

local LOCAL_BIN="$HOME/.local/bin"
[ ! -d "$LOCAL_BIN" ] && sudo mkdir -p "$LOCAL_BIN"
[ -d "$LOCAL_BIN" ] && export PATH="$LOCAL_BIN:$PATH"

##
# Set user-specific configuration directory
export XDG_CONFIG_HOME="$HOME/.config"
[ ! -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"

##
# Customize the OS
local OS=$(uname | tr '[:upper:]' '[:lower:]')
source "$DOTFILES/os/env.zsh"
source "$DOTFILES/os/alias.zsh"
source "$DOTFILES/os/$OS/customize-$OS.zsh"

# Create symlinks
$DOTFILES/os/create-symlinks.zsh
