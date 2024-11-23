#!/usr/bin/env zsh

# zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# zsh extensions
autoload -U zmv

# opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# Check if DOTFILES variable is set
if [ -z "${DOTFILES}" ]; then
  echo "You have to define the DOTFILES env variable."
  exit 1
fi

# Set user-specific configuration directory
export XDG_CONFIG_HOME="$HOME/.config"
[ ! -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"

customize() {
  local USR_LOCAL_BIN="/usr/local/bin"
  [ ! -d "$USR_LOCAL_BIN" ] && sudo mkdir -p "$USR_LOCAL_BIN"

  local LOCAL_BIN="$HOME/.local/bin"
  [ ! -d "$LOCAL_BIN" ] && sudo mkdir -p "$LOCAL_BIN"
  [ -d "$LOCAL_BIN" ] && export PATH="$LOCAL_BIN:$PATH"

  ##
  # brew based apps
  #

  # base root directory for brew intalled apps
  local BREW_BIN_DIR="$(brew --prefix)/bin"
  local BREW_OPT_DIR="$(brew --prefix)/opt"

  # asdf
  local ASDF="$BREW_OPT_DIR/asdf"
  [ -d $ASDF ] && source /opt/homebrew/opt/asdf/libexec/asdf.sh

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
  if [ -d "$RUBY" ]; then
    export PATH="$RUBY/bin:$PATH"
    export LDFLAGS="$LDFLAGS -L$RUBY/lib"
    export CPPFLAGS="$CPPFLAGS -I$RUBY/include"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$RUBY/lib/pkgconfig:$PATH"
  fi

  # rbenv - ruby environment
  local RBENV="$BREW_OPT_DIR/rbenv"
  [ -d "$RBENV" ] && eval "$(rbenv init - zsh)"

  # rvm - ruby version manager
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

  # sqlite
  local SQLITE="$BREW_OPT_DIR/sqlite"
  if [ -d "$SQLITE" ]; then
    export PATH="$SQLITE/bin:$PATH"
    export LDFLAGS="$LDFLAGS -L$SQLITE/lib"
    export CPPFLAGS="$CPPFLAGS -I$SQLITE/include"
  fi

  # zulu
  local ZULU_VERSION="17"
  local ZULU_JDK="/Library/Java/JavaVirtualMachines/zulu-$ZULU_VERSION.jdk"
  if [ -d "$ZULU_JDK" ]; then
    export JAVA_HOME="$ZULU_JDK/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi

  ##
  # git
  #
  #
  local GIT_EXTRAS="$BREW_OPT_DIR/git-extras"
  [ -d "$GIT_EXTRAS" ] && source "$GIT_EXTRAS/share/git-extras/git-extras-completion.zsh"

  # custom git scripts
  local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/symlinks/git/custom-git-commands"
  [ -d "$CUSTOM_GIT_COMMANDS_SYMLINK" ] && export PATH="$CUSTOM_GIT_COMMANDS_SYMLINK:$PATH"

  ##
  # other apps
  #

  # android
  local ANDROID="$HOME/Library/Android"
  if [ -d "$ANDROID" ]; then
    local ANDROID_SDK_VERSION="34.00"
    export ANDROID_HOME="$ANDROID/sdk"
    export ANDROID_SDK_ROOT="$ANDROID/sdk"
    export PATH="$ANDROID_HOME/build-tools/$ANDROID_SDK_VERSION:$PATH"
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

  # ruby gems
  if [ -d "$HOME/.gem" ]; then
    export GEM_HOME="$HOME/.gem"
    export PATH="$HOME/.gem/bin:$PATH"
  fi

  # rust
  if [ -d "$HOME/.cargo" ]; then
    source "$HOME/.cargo/env"
  fi

  # sming - esp8266
  if [ -d "$HOME/opt" ]; then
    export ESP_HOME="$HOME/opt/esp-quick-toolchain"
    export SMING_HOME="$HOME/opt/Sming/Sming"
  fi
  
  ##
  # symlinks
  #
  local DOTFILES_SYMLINKS="$DOTFILES/symlinks"

  # git configs
  declare -a GIT_CONFIGS=(
    "gitconfig"
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

  # app configs
  local DOTFILES_SYMLINKS_CONFIG="$DOTFILES_SYMLINKS/config"

  declare -a APP_CONFIGS=(
    "lazygit"
    "lvim"
    "pip"
  )

  local APP_CONFIG
  for APP_CONFIG in "${APP_CONFIGS[@]}"; do
    if [ -x "$(command -v $APP_CONFIG)" ]; then
      local XDG_CONFIG_HOME_APP="$XDG_CONFIG_HOME/$APP_CONFIG"
      if [ ! -d "$XDG_CONFIG_HOME_APP" ]; then
        ln -s "$DOTFILES_SYMLINKS_CONFIG/$APP_CONFIG" "$XDG_CONFIG_HOME_APP"
      fi
    fi
  done

  # ssh config
  local HOME_SSH="$HOME/.ssh"
  local HOME_SSH_CONFIG="$HOME_SSH/config"
  if [ ! -f "$HOME_SSH_CONFIG" ]; then
    [ ! -d "$HOME_SSH" ] && mkdir -p "$HOME_SSH" && chmod 700 "$HOME_SSH"
    ln -s "$DOTFILES_SYMLINKS/ssh/config" "$HOME_SSH_CONFIG"
    chmod 600 "$HOME_SSH_CONFIG"
  fi
}

customize
unset -f customize

##
# Bindkeys
#
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

##
# Alias
#

# list all files colorized in long format
if [ -x "$(command -v eza)" ]; then
  alias ls="eza --all --header --long --octal-permissions --git --icons=always --show-symlinks" 
else
  # Detect which `ls` flavor is in use
  if ls --color > /dev/null 2>&1; then # GNU `ls`
      colorflag="--color"
  else # OS X `ls`
      colorflag="-G"
  fi

  alias ls="ls -lisa ${colorflag}"

  # list all files colorized in long format, including dot files
  alias la="ls -lA ${colorflag}"

  # list only directories
  alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

  alias lisa="ls -Gisa"
  alias lis="ls -Gis"
  alias ll="ls -GalF"
  alias l="ls -GCF"
fi

# grep color
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# file size
alias fs="stat -f \"%z bytes\""

# trim new lines and copy to clipboard
alias cp="tr -d '\n' | pbcopy"

# ip addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

# list npm or yarn global packages
alias global-packages="yarn global list; npm list --global --depth 0"

# npm package
alias scripts="jq -r .scripts package.json"
alias dependencies="jq -r .dependencies package.json"
alias devDependencies="jq -r .devDependencies package.json"

# android adb
alias a:devices="adb devices"
alias a:reverse="adb reverse tcp:8081 tcp:8081; adb reverse tcp:8097 tcp:8097"
alias a:reload="adb shell input text 'RR'"
alias a:shake="adb shell input keyevent 82"

# ios
alias i:simulator="xcrun simctl list devices"

# react native - android
alias a:task="cd ./android && ./gradlew -PversionCode=1 tasks && cd .."
alias a:clean="cd ./android && ./gradlew -PversionCode=1 clean && cd .."
alias a:debug="cd ./android && ./gradlew -PversionCode=1 -PversionName=\"0.0.1\" app:installDebug && cd .."

# time
alias timestamp2date='fn(){ date -jf "%s" "$1" +"%Y-%m-%d %H:%M:%S"; unset -f fn; }; fn'

# vim
alias v="nvim"
alias lv="lvim"
