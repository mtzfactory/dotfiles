#!/usr/bin/env zsh

# zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# zsh etenxions
autoload -U zmv

local LOCAL_BIN="$HOME/.local/bin"
[[ ! -d $LOCAL_BIN ]] && mkdir -p "$LOCAL_BIN"
[[ ! -d $LOCAL_BIN ]] || export PATH="$PATH:$LOCAL_BIN"

# bat
if [[ ! -x $(command -v bat) ]]; then
  local BATCAT="/usr/bin/batcat"
  if [[ -f $BATCAT ]]; then
    ln -s $BATCAT $LOCAL_BIN/bat
  fi
fi

# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ ! -x $(command -v node) ]]; then
  nvm install --lts
fi

##
# git
#
# git-extras
local GIT_EXTRAS="/usr/share/zsh/vendor-completions/_git-extras"
[[ -d $GIT_EXTRAS ]] && source "/usr/share/zsh/vendor-completions/_git-extras"

# custom git scripts
local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/custom-git-commands"
[[ -d $CUSTOM_GIT_COMMANDS_SYMLINK ]] && export PATH="$CUSTOM_GIT_COMMANDS_SYMLINK:$PATH"

# alias
alias ls="ls -lisa"

# neovim
export EDITOR="nvim"
alias v="nvim"
