#!/usr/bin/env zsh

##
# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

local OS=$(uname | tr '[:upper:]' '[:lower:]')

##
# Install apps
source "$DOTFILES/os/env.zsh"
$DOTFILES/os/$OS/install-$OS-apps.zsh

##
# Install Zsh plugins
$DOTFILES/os/install-zsh-plugins.zsh
