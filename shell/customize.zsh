#!/usr/bin/env zsh

##
# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

##
# Re-entrancy guard: este fichero prepende a PATH y crea symlinks, así que
# cargarlo dos veces en el MISMO shell (p.ej. el export manual de ~/.zshrc más
# el bloque que inyecta Ansible) duplicaría entradas de PATH.
#
# Sin `export` a propósito: exportada, la heredarían los shells hijos y un
# `exec zsh` o un shell anidado se saltaría toda la configuración, quedándose
# sin aliases ni PATH. Cada proceso debe cargarla una vez.
if [ -n "${DOTFILES_LOADED:-}" ]; then
  return 0
fi
typeset -g DOTFILES_LOADED=1

## 
# Zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# Agents write bash-style commands: pass an unmatched glob through literally
# instead of aborting the whole command line.
[ -n "$CLAUDECODE" ] && setopt no_nomatch

##
# Zsh extensions
autoload -U zmv

##
# PATH sin duplicados: `path` como array único. Varias rutas de abajo (y de
# customize-$OS.zsh) ya vienen en el PATH por defecto del sistema, así que
# prependerlas a ciegas duplicaba entradas en cada login. Con -U zsh deduplica
# en cada asignación y mantiene la aparición más a la izquierda, que es la
# precedencia que se busca al prepender.
typeset -U PATH path

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
source "$DOTFILES/shell/env.zsh"
source "$DOTFILES/shell/alias.zsh"
source "$DOTFILES/shell/shared/wt-session.zsh"
source "$DOTFILES/shell/shared/herdr-epic.zsh" # depends on sanitize()/_wt_repo_folder() above
source "$DOTFILES/shell/$OS/customize-$OS.zsh"

# Create symlinks
source $DOTFILES/shell/create-symlinks.zsh
