# zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# zsh etenxions
autoload -U zmv

# opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

customize() {

  local USR_LOCAL_BIN="/usr/local/bin"
  [ ! -d "$USR_LOCAL_BIN" ] && sudo mkdir -p "$USR_LOCAL_BIN"

  ##
  # brew based apps
  #

  # base root directory for brew intalled apps
  local BREW_BIN_DIR="$(brew --prefix)/bin"
  local BREW_OPT_DIR="$(brew --prefix)/opt"

  # coreutils
  local COREUTILS="$BREW_OPT_DIR/coreutils"
  [ -d "$COREUTILS" ] && export PATH="$PATH:$COREUTILS/libexec/gnubin"

  # binutils
  local BINUTILS="$BREW_OPT_DIR/binutils"
  if [ -d "$BINUTILS" ]; then
    export PATH="$PATH:$BINUTILS/bin"
    export LDFLAGS="$LDFLAGS -L$BINUTILS/lib"
    export CPPFLAGS="$CPPFLAGS -I$BINUTILS/include"
  fi

  # gnu-sed
  local GNU_SED="$BREW_OPT_DIR/gnu-sed"
  [ -d "$GNU_SED" ] && export PATH="$PATH:$GNU_SED/libexec/gnubin"

  # gnu-getopt
  local GNU_GETOPT="$BREW_OPT_DIR/gnu-getopt"
  [ -d "$GNU_GETOPT" ] && export PATH="$PATH:$GNU_GETOPT/bin"

  # grep
  local GREP="%BREW_OPT_DIR/grep"
  [ -d "$GREP" ] && export PATH="$PATH:$GREP/libexec/gnubin"

  # gettext
  local GETTEXT="$BREW_OPT_DIR/gettext"
  if [ -d "$GETTEXT" ]; then
    export PATH="$PATH:$GETTEXT/bin"
    export LDFLAGS="$LDFLAGS -L$GETTEXT/lib"
    export CPPFLAGS="$CPPFLAGS -I$GETTEXT/include"
  fi

  # icu4c
  local ICU4C="$BREW_OPT_DIR/icu4c"
  if [ -d "$ICU4C" ]; then
    export PATH="$PATH:$ICU4C/bin:$ICU4C/sbin"
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
    export PATH="$PATH:$NCURSES/bin"
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
  local OPENSSL="$BREW_OPT_DIR/openssl@1.1"
  if [ -d "$OPENSSL" ]; then
    export PATH="$PATH:$OPENSSL/bin"
    export LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
    export CPPFLAGS="$CPPFLAGS -I$OPENSSL/include"
  fi

  # python@3
  local PYTHON3="$BREW_OPT_DIR/python@3"
  if [ -d "$PYTHON3" ]; then
    export PATH="$PATH:$PYTHON3/bin"
    export LDFLAGS="$LDFLAGS -L$PYTHON3/lib"
  fi

  # readline (required by sqlite)
  local READLINE="$BREW_OPT_DIR/readline"
  if [ -d "$READLINE" ]; then
    export LDFLAGS="$LDFLAGS -L$READLINE/lib"
    export CPPFLAGS="$CPPFLAGS -I$READLINE/include"
  fi

  # sqlite
  local SQLITE="$BREW_OPT_DIR/sqlite"
  if [ -d "$SQLITE" ]; then
    export PATH="$PATH:$SQLITE/bin"
    export LDFLAGS="$LDFLAGS -L$SQLITE/lib"
    export CPPFLAGS="$CPPFLAGS -I$SQLITE/include"
  fi

  ##
  # git
  #
  local GIT_EXTRAS="$BREW_OPT_DIR/git-extras"
  if [ -d "$GIT_EXTRAS" ]; then
    source "$GIT_EXTRAS/share/git-extras/git-extras-completion.zsh"
  fi

  ##
  # other apps
  #

  # android
  local ANDROID="$HOME/Library/Android"
  if [ -d "$ANDROID" ]; then
    export ANDROID_HOME="$ANDROID/sdk"
    export ANDROID_SDK_ROOT="$ANDROID/sdk"
    export PATH="$PATH:$ANDROID_HOME/emulator"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    export PATH="$PATH:$ANDROID_HOME/tools"
    export PATH="$PATH:$ANDROID_HOME/tools/bin"
  fi

  # esp-idf
  local ESP_IDF="$HOME/esp/esp-idf"
  [ -d "$ESP_IDF" ] && alias get_idf=". $ESP_IDF/export.sh"

  # fontcustom
  local FONTFORGE="/Applications/FontForge.app"
  [ -d "$FONTFORGE" ] && export PATH="$PATH:$FONTFORGE/Contents/Resources/opt/local/bin"

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
    export PATH="$PATH:$HOME/.gem/bin"
  fi

  # sming - esp8266
  if [ -d "$HOME/opt" ]; then
    export ESP_HOME="$HOME/opt/esp-quick-toolchain"
    export SMING_HOME="$HOME/opt/Sming/Sming"
  fi
  
  ##
  # symlinks
  #
  if [ -z "${DOTFILES}" ]; then
    echo "You have to define the DOTFILES env variable."
    exit 1
  fi

  local DOTFILES_SYMLINKS="$DOTFILES/symlinks"

  local CUSTOM_GIT_COMMANDS_SYMLINK="$DOTFILES/custom-git-commands"
  [ -d "$CUSTOM_GIT_COMMANDS_SYMLINK" ] && export PATH="$PATH:$CUSTOM_GIT_COMMANDS_SYMLINK"

  local GITCONFIG_SYMLINK="$HOME/.gitconfig"
  if [ ! -f "$GITCONFIG_SYMLINK" ]; then
    ln -s "$DOTFILES_SYMLINKS/_gitconfig" "$GITCONFIG_SYMLINK"
  fi

  local GITCONFIG_PERSONAL_SYMLINK="$HOME/.gitconfig-personal"
  if [ ! -f "$GITCONFIG_PERSONAL_SYMLINK" ]; then
    ln -s "$DOTFILES_SYMLINKS/_gitconfig-personal" "$GITCONFIG_PERSONAL_SYMLINK"
  fi

  local GITCONFIG_WORK_SYMLINK="$HOME/.gitconfig-work"
  if [ ! -f "$GITCONFIG_WORK_SYMLINK" ]; then
    ln -s "$DOTFILES_SYMLINKS/_gitconfig-work" "$GITCONFIG_WORK_SYMLINK"
  fi

  local GITIGNORE_GLOBAL_SYMLINK="$HOME/.gitignore-global"
  if [ ! -f "$GITIGNORE_GLOBAL_SYMLINK" ]; then
    ln -s "$DOTFILES_SYMLINKS/_gitconfig-personal" "$GITIGNORE_GLOBAL_SYMLINK"
  fi
  
  local HOME_CONFIG_DIRECTORY="$HOME/.config"
  local NVIM_CONFIG_SYMLINK="$HOME_CONFIG_DIRECTORY/nvim"
  if [ ! -d "$NVIM_CONFIG_SYMLINK" ]; then
    [ ! -d "$HOME_CONFIG_DIRECTORY" ] && mkdir -p "$HOME_CONFIG_DIRECTORY"
    ln -s "$DOTFILES_SYMLINKS/_config/nvim" "$NVIM_CONFIG_SYMLINK"
  fi

  local HOME_SSH_DIRECTORY="$HOME/.ssh"
  local SSH_CONFIG_SYMLINK="$HOME_SSH_DIRECTORY/config"
  if [ ! -f "$SSH_CONFIG_SYMLINK" ]; then
    [ ! -d "$HOME_SSH_DIRECTORY" ] && mkdir -p "$HOME_SSH_DIRECTORY" && chmod 700 "$HOME_SSH_DIRECTORY"
    ln -s "$DOTFILES_SYMLINKS/_ssh/config" "$SSH_CONFIG_SYMLINK"
    chmod 600 ~/.ssh/config
  fi
}

customize
unset -f customize

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

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
alias ls="ls -lisa ${colorflag}"

# list all files colorized in long format, including dot files
alias la="ls -lA ${colorflag}"

# list only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

alias lisa="ls -Gisa"
alias lis="ls -Gis"
alias ll="ls -GalF"
alias l="ls -GCF"

# grep color
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# file size
alias fs="stat -f \"%z bytes\""

# trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# ip addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

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

# neovim
export EDITOR="nvim"
alias v="nvim"

