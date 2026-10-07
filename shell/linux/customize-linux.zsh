#!/usr/bin/env zsh

# Zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# Zsh extensions
autoload -U zmv

##
# Cargo for rust
local CARGO="$HOME/.cargo"
[ -d "$CARGO" ] && source "$CARGO/env"

##
# Git
#
# Git extras
local GIT_EXTRAS="/usr/share/zsh/vendor-completions/_git-extras"
[ -d $GIT_EXTRAS ] && source "/usr/share/zsh/vendor-completions/_git-extras"

# Custom git commands
local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/config/git/custom-git-commands"
[ -d $CUSTOM_GIT_COMMANDS_SYMLINK ] && export PATH="$CUSTOM_GIT_COMMANDS_SYMLINK:$PATH"

##
# Go
if [ -x "$(command -v go)" ]; then
  export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
fi

# Node version manager
# NVM se instaló bajo XDG ($XDG_CONFIG_HOME/nvm), no en la ruta por defecto
# del instalador (~/.nvm). Se prefiere la que exista de verdad, y se respeta
# un NVM_DIR ya exportado. Ansible usa la misma ruta vía la var `nvm_dir`.
if [ -z "${NVM_DIR:-}" ]; then
  if [ -s "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]; then
    export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
  else
    export NVM_DIR="$HOME/.nvm"
  fi
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ ! -x "$(command -v node)" ]; then
  nvm install --lts > /dev/null
fi

