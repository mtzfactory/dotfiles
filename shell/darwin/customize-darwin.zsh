#!/usr/bin/env zsh

[ -x "$(command -v brew)" ] || eval "$(/opt/homebrew/bin/brew shellenv)"

# Opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

##
# Brew based apps
#

# Base root directory for brew installed apps (hardcoded for Apple Silicon)
local BREW_BIN_DIR="/opt/homebrew/bin"
local BREW_OPT_DIR="/opt/homebrew/opt"

# asdf
local ASDF="$BREW_OPT_DIR/asdf"
[ -d $ASDF ] && source /opt/homebrew/opt/asdf/libexec/asdf.sh

# atuin
# Daemon mode is off (daemon.enabled = false in ~/.config/atuin/config.toml,
# it's only needed for sync perf) so don't try to keep a background daemon
# alive here: `atuin init zsh` works standalone. A previous version of this
# block did `pgrep -x atuin || brew services start atuin` on every new
# shell; once the daemon's unix socket got orphaned (crash without cleanup)
# it crash-looped forever and `brew services start` kept failing with
# "Bootstrap failed" — printing to stderr during zsh init and breaking
# Powerlevel10k's instant prompt on every single shell.
local ATUIN="$BREW_OPT_DIR/atuin"
if [ -d "$ATUIN" ]; then
  eval "$(atuin init zsh)"
fi

# coreutils
local COREUTILS="$BREW_OPT_DIR/coreutils"
[ -d "$COREUTILS" ] && export PATH="$PATH:$COREUTILS/libexec/gnubin"
# keep path order because of: https://github.com/facebook/react-native/issues/32432

# binutils
local BINUTILS="$BREW_OPT_DIR/binutils"
if [ -d "$BINUTILS" ]; then
  export PATH="$BINUTILS/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$BINUTILS/lib"
  export CPPFLAGS="$CPPFLAGS -I$BINUTILS/include"
fi

# gnu-sed
if [ "$ENABLE_GNU_SED" ]; then
  local GNU_SED="$BREW_OPT_DIR/gnu-sed"
  [ -d "$GNU_SED" ] && export PATH="$GNU_SED/libexec/gnubin:$PATH"
fi

# gnu-getopt
local GNU_GETOPT="$BREW_OPT_DIR/gnu-getopt"
[ -d "$GNU_GETOPT" ] && export PATH="$GNU_GETOPT/bin:$PATH"

# gnu-tar
local GNU_TAR="$BREW_OPT_DIR/gnu-tar"
[ -d "$GNU_TAR" ] && export PATH="$GNU_TAR/libexec/gnubin:$PATH"

# grep
local GREP="$BREW_OPT_DIR/grep"
[ -d "$GREP" ] && export PATH="$GREP/libexec/gnubin:$PATH"

# gettext
local GETTEXT="$BREW_OPT_DIR/gettext"
if [ -d "$GETTEXT" ]; then
  export PATH="$GETTEXT/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$GETTEXT/lib"
  export CPPFLAGS="$CPPFLAGS -I$GETTEXT/include"
fi

# icu4c
local ICU4C="$BREW_OPT_DIR/icu4c"
if [ -d "$ICU4C" ]; then
  export PATH="$ICU4C/bin:$ICU4C/sbin:$PATH"
  export LDFLAGS="$LDFLAGS -L$ICU4C/lib"
  export CPPFLAGS="$CPPFLAGS -I$ICU4C/include"
fi

# libffi
local LIBFFI="$BREW_OPT_DIR/libffi"
if [ -d "$LIBFFI" ]; then
  export LDFLAGS="$LDFLAGS -L$LIBFFI/lib"
  export CPPFLAGS="$CPPFLAGS -I$LIBFFI/include"
fi

# ncurses
local NCURSES="$BREW_OPT_DIR/ncurses"
if [ -d "$NCURSES" ]; then
  export PATH="$NCURSES/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$NCURSES/lib"
  export CPPFLAGS="$CPPFLAGS -I$NCURSES/include"
fi

# nvm — lazy loaded to avoid ~500ms startup cost
# nvm, node, npm etc. are shimmed: the real nvm.sh is sourced on first use
# Not in agent sessions: Claude Code's shell snapshot keeps the shims but drops
# _nvm_lazy_load, so they would recurse into "command not found". Agents get
# node from the .nvmrc lookup in ~/.zshenv instead.
local NVM="$BREW_OPT_DIR/nvm"
if [ -d "$NVM" ] && [ -z "$CLAUDECODE" ]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  _nvm_lazy_load() {
    unfunction nvm node npm npx yarn pnpm corepack 2>/dev/null
    [ -s "$NVM/nvm.sh" ] && \. "$NVM/nvm.sh"
    [ -s "$NVM/etc/bash_completion.d/nvm" ] && \. "$NVM/etc/bash_completion.d/nvm"
  }
  nvm()      { _nvm_lazy_load; nvm "$@"; }
  node()     { _nvm_lazy_load; node "$@"; }
  npm()      { _nvm_lazy_load; npm "$@"; }
  npx()      { _nvm_lazy_load; npx "$@"; }
  yarn()     { _nvm_lazy_load; yarn "$@"; }
  pnpm()     { _nvm_lazy_load; pnpm "$@"; }
  corepack() { _nvm_lazy_load; corepack "$@"; }
elif [ -n "$CLAUDECODE" ]; then
  # Same .nvmrc lookup as the ~/.zshenv block, repeated this late on purpose:
  # the snapshot freezes the PATH of this interactive shell, and by now
  # path_helper and the lines above have pushed the Homebrew node back in front.
  () {
    local dir=$PWD ver bin
    # A deleted cwd leaves $PWD without a slash, which would never shorten.
    [[ $dir == /* ]] || return
    while [[ -n $dir ]]; do
      if [[ -r $dir/.nvmrc ]]; then
        ver=${${"$(<$dir/.nvmrc)"//[[:space:]]/}#v}
        bin=${NVM_DIR:-$HOME/.nvm}/versions/node/v$ver/bin
        [[ -d $bin ]] && path=($bin ${path:#${NVM_DIR:-$HOME/.nvm}/versions/node/*})
        return
      fi
      [[ $dir == */* ]] || return
      dir=${dir%/*}
    done
  }
  # `mise activate` runs at the end of ~/.zshrc. With the state inherited from
  # the shell that launched claude it rebuilds PATH from that shell's copy and
  # undoes the line above, so make it start from the PATH we have now.
  unset __MISE_ORIG_PATH __MISE_DIFF __MISE_SESSION
fi

# openjdk
local OPENJDK="$BREW_OPT_DIR/openjdk"
if [ -d "$OPENJDK" ]; then
  export PATH="$OPENJDK/bin:$PATH"
  export CPPFLAGS="$CPPFLAGS -I$OPENJDK/include"

  local LIBRARY_JVM_OPENJDK="/Library/Java/JavaVirtualMachines/openjdk.jdk"
  [ ! -d "$LIBRARY_JVM_OPENJDK" ] && sudo ln -sfn "$OPENJDK/libexec/openjdk.jdk" "$LIBRARY_JVM_OPENJDK"

  # https://docs.gradle.org/current/userguide/compatibility.html#java
  local OPENJDK_JVM="/Library/Java/JavaVirtualMachines/openjdk.jdk"
  [ -d "$OPENJDK_JVM" ] && export JAVA_HOME="$OPENJDK_JVM/Contents/Home"
fi

# openssl (hardcoded for Apple Silicon — avoids `brew --prefix` subprocess)
local OPENSSL="/opt/homebrew/opt/openssl@1.1"
if [ -d "$OPENSSL" ]; then
  export PATH="$OPENSSL/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
  export CPPFLAGS="$CPPFLAGS -I$OPENSSL/include"
  export PKG_CONFIG_PATH="$OPENSSL/lib/pkgconfig:$PATH"
fi

# pinentry for gpg
# The old `[[ -f $GPG_AGENT_FILE ]]` guard made this a no-op on a fresh box,
# where gpg has not written gpg-agent.conf yet — exactly the case worth
# covering. Create the file instead, and leave any pinentry-program line that
# is already there alone.
local GPG_AGENT_DIR="$HOME/.gnupg"
local GPG_AGENT_FILE="$GPG_AGENT_DIR/gpg-agent.conf"
if [[ ! -d "$GPG_AGENT_DIR" ]]; then
  mkdir -p "$GPG_AGENT_DIR" && chmod 700 "$GPG_AGENT_DIR"
fi
if ! grep -q -E '^[[:space:]]*pinentry-program[[:space:]]' "$GPG_AGENT_FILE" 2>/dev/null; then
  # ${BREW_OPT_DIR:h} rather than `brew --prefix`: same reason the openssl
  # block above hardcodes the prefix — no subprocess on shell init.
  echo "pinentry-program ${BREW_OPT_DIR:h}/bin/pinentry-mac" >> "$GPG_AGENT_FILE"
  chmod 600 "$GPG_AGENT_FILE"
  gpgconf --reload gpg-agent 2>/dev/null
fi

# python@3
local PYTHON3="$BREW_OPT_DIR/python@3"
if [ -d "$PYTHON3" ]; then
  export PATH="$PYTHON3/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$PYTHON3/lib"
fi

# readline (required by sqlite)
local READLINE="$BREW_OPT_DIR/readline"
if [ -d "$READLINE" ]; then
  export LDFLAGS="$LDFLAGS -L$READLINE/lib"
  export CPPFLAGS="$CPPFLAGS -I$READLINE/include"
fi

# ruby
local RUBY="$BREW_OPT_DIR/ruby"

# rbenv - ruby environment
# rbenv init runs via ~/.zlogin (login shells); here we only set PATH/FPATH
local RBENV="$BREW_OPT_DIR/rbenv"
if [ -d "$RBENV" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"

  # Shell completions
  FPATH="$RBENV/completions:$FPATH"
elif [ -d "$RUBY" ]; then
  export PATH="$RUBY/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$RUBY/lib"
  export CPPFLAGS="$CPPFLAGS -I$RUBY/include"
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$RUBY/lib/pkgconfig:$PATH"
fi

# sqlite
local SQLITE="$BREW_OPT_DIR/sqlite"
if [ -d "$SQLITE" ]; then
  export PATH="$SQLITE/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$SQLITE/lib"
  export CPPFLAGS="$CPPFLAGS -I$SQLITE/include"
fi

# zulu (java)
local ZULU_VERSION="17"
local ZULU_JDK="/Library/Java/JavaVirtualMachines/zulu-$ZULU_VERSION.jdk"
if [ -d "$ZULU_JDK" ]; then
  #export JAVA_HOME=$(/usr/libexec/java_home)
  export JAVA_HOME="$ZULU_JDK/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

##
# git
#

# Git extras
local GIT_EXTRAS="$BREW_OPT_DIR/git-extras"
[ -d "$GIT_EXTRAS" ] && source "$GIT_EXTRAS/share/git-extras/git-extras-completion.zsh"

# Custom git commands
local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/config/git/custom-git-commands"
[ -d "$CUSTOM_GIT_COMMANDS_SYMLINK" ] && export PATH="$CUSTOM_GIT_COMMANDS_SYMLINK:$PATH"

##
# Other apps
#

# android
local ANDROID="$HOME/Library/Android"
if [ -d "$ANDROID" ]; then
  local ANDROID_SDK_VERSION="34.0.0"
  export ANDROID_HOME="$ANDROID/sdk"
  export ANDROID_SDK_ROOT="$ANDROID/sdk"
  if [ -d "$ANDROID_HOME/build-tools/$ANDROID_SDK_VERSION" ]; then
    export PATH="$ANDROID_HOME/build-tools/$ANDROID_SDK_VERSION:$PATH"
  else
    echo "The Android SDK $ANDROID_SDK_VERSION is not installed"
  fi
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
  export PATH="$ANDROID_HOME/emulator:$PATH"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
  export PATH="$ANDROID_HOME/tools/bin:$PATH"
fi

# esp-idf
local ESP_IDF="$HOME/esp/esp-idf"
[ -d "$ESP_IDF" ] && alias get_idf=". $ESP_IDF/export.sh"

# fontcustom
local FONTFORGE="/Applications/FontForge.app"
[ -d "$FONTFORGE" ] && export PATH="$FONTFORGE/Contents/Resources/opt/local/bin:$PATH"

# idb (flipper) — symlink setup is a one-time operation, not done at shell startup
# If idb is missing, run manually:
#   sudo ln -s "$(python3 -m site --user-site | sed 's|/lib/python/site-packages||')/bin/idb" /usr/local/bin/idb

# rust
if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
fi

# sming - esp8266
[ -d "/opt/esp-quick-toolchain" ] && export ESP_HOME="/opt/esp-quick-toolchain"
[ -d "/opt/sming/Sming/" ] && export SMING_HOME="/opt/sming/Sming"
[ -d "/opt/sming/Tools/" ] && export PATH="$PATH:/opt/sming/Tools"
[ -d "/opt/esp-idf" ] && export IDF_PATH="/opt/esp-idf"
[ -d "/opt/esp32/" ] && export IDF_TOOLS_PATH="/opt/esp32"

##
# Bindkeys
#
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

##
# iTerm
#
if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  if [ ! -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
    curl -L https://iterm2.com/shell_integration/zsh -o "${HOME}/.iterm2_shell_integration.zsh"
  fi

  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

##
# Load SSH keys from the macOS keychain (login shells only — not every tab/pane)
[[ -o login ]] && ssh-add --apple-load-keychain -q

##
# Shell completions
fpath=(~/.zfunc $fpath)
autoload -Uz compinit

# compinit with dump-file caching: only rebuild if dump is older than 24h
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

