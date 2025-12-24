#!/usr/bin/env zsh

[ -x "$(command -v brew)" ] || eval "$(/opt/homebrew/bin/brew shellenv)"

# Opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

##
# Brew based apps
#

# Base root directory for brew installed apps
local BREW_BIN_DIR="$(brew --prefix)/bin"
local BREW_OPT_DIR="$(brew --prefix)/opt"

# asdf
local ASDF="$BREW_OPT_DIR/asdf"
[ -d $ASDF ] && source /opt/homebrew/opt/asdf/libexec/asdf.sh

# atuin
local ATUIN="$BREW_OPT_DIR/atuin"
if [ -d "$ATUIN" ]; then
  if ! brew services info atuin | grep -Eq "PID: [0-9]+"; then
    brew services start atuin
  fi
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
local GNU_SED="$BREW_OPT_DIR/gnu-sed"
[ -d "$GNU_SED" ] && export PATH="$GNU_SED/libexec/gnubin:$PATH"

# gnu-getopt
local GNU_GETOPT="$BREW_OPT_DIR/gnu-getopt"
[ -d "$GNU_GETOPT" ] && export PATH="$GNU_GETOPT/bin:$PATH"

# gnu-tar
local GNU_TAR="$BREW_OPT_DIR/gnu-tar"
[ -d "$GNU_TAR" ] && export PATH="$GNU_TAR/libexec/gnubin:$PATH"

# grep
local GREP="%BREW_OPT_DIR/grep"
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

# nvm
local NVM="$BREW_OPT_DIR/nvm"
if [ -d "$NVM" ]; then
  export NVM_DIR="$HOME/.nvm"
  # This loads nvm
  [ -s "$NVM/nvm.sh" ] && \. "$NVM/nvm.sh"
  # This loads nvm bash_completion
  [ -s "$NVM/etc/bash_completion.d/nvm" ] && \. "$NVM/etc/bash_completion.d/nvm"
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

# openssl
local OPENSSL="$(brew --prefix openssl@1.1)"
if [ -d "$OPENSSL" ]; then
  export PATH="$OPENSSL/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
  export CPPFLAGS="$CPPFLAGS -I$OPENSSL/include"
  export PKG_CONFIG_PATH="$OPENSSL/lib/pkgconfig:$PATH"
fi

# pinentry for gpg
local GPG_AGENT_FILE="$HOME/.gnupg/gpg-agent.conf"
if [[ -f "$GPG_AGENT_FILE" ]]; then
  if ! grep -q -E '^pinentry-program.*$' "$GPG_AGENT_FILE"; then
    echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" | tee -a "$GPG_AGENT_FILE" >/dev/null
  fi
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
local RBENV="$BREW_OPT_DIR/rbenv"
if [ -d "$RBENV" ]; then
  if ! grep -q 'eval "$(rbenv init -)"' ~/.zlogin; then
    echo 'eval "$(rbenv init -)"' >> ~/.zlogin
    eval "$(rbenv init - --no-rehash zsh)"
  fi

  export PATH="$HOME/.rbenv/bin:$PATH"

  # Shell completions
  FPATH="$RBENV/completions:$FPATH"

  autoload -U compinit
  compinit
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
local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/symlinks/git/custom-git-commands"
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

# idb (flipper)
if [ ! -x "$(command -v idb)" ]; then
  if [ -x "$(command -v python3)" ]; then
    local PYTHON_SITE_PACKAGES="$(python3 -m site --user-site)"
    local IDB="${PYTHON_SITE_PACKAGES%%"/lib/python/site-packages"}/bin/idb"
    sudo ln -s "$IDB" "$USR_LOCAL_BIN/idb"
  fi
fi

# rust
if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
fi

# sming - esp8266
[ -d "/opt/esp-quick-toolchain" ] && export ESP_HOME="/opt/esp-quick-toolchain"
[ -d "/opt/Sming" ] && export SMING_HOME="/opt/Sming/Sming"

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
if [ ! -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
  curl -L https://iterm2.com/shell_integration/zsh -o "${HOME}/.iterm2_shell_integration.zsh"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

##
# Load SSH keys from the macOS keychain
ssh-add --apple-load-keychain -q

