#!/usr/bin/env zsh

# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

source $DOTFILES/os/env.zsh

local OS=$(uname | tr '[:upper:]' '[:lower:]')

$DOTFILES/os/$OS/install-$OS-apps.zsh
