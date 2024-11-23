#!/usr/bin/env zsh

# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

source "$DOTFILES/os/env.zsh"
source "$DOTFILES/os/alias.zsh"

local OS=$(uname | tr '[:upper:]' '[:lower:]')

source "$DOTFILES/os/$OS/customize-$OS.zsh"
