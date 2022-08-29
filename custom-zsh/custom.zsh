# zsh extended glob operators
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-EXTENDED_005fGLOB
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Operators
setopt extended_glob

# zsh etenxions
autoload -U zmv

# opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

customize() {
  ##
  # apps
  ##

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

  # java
  # https://docs.gradle.org/current/userguide/compatibility.html#java
  local JAVA_VERSION="jdk-14.0.2.jdk"
  local JAVA="/Library/Java/JavaVirtualMachines/$JAVA_VERSION"
  if [ -d "$JAVA" ]; then
    export JAVA_HOME="$JAVA/Contents/Home"
  fi

  # base root directory for brew intalled apps
  local USR_LOCAL_OPT="/usr/local/opt"

  # coreutils
  local COREUTILS="$USR_LOCAL_OPT/coreutils"
  [ -d "$COREUTILS" ] && export PATH="$PATH:$COREUTILS/libexec/gnubin"

  # binutils
  local BINUTILS="$USR_LOCAL_OPT/binutils"
  if [ -d "$BINUTILS" ]; then
    export PATH="$PATH:$BINUTILS/bin"
    export LDFLAGS="$LDFLAGS -L$BINUTILS/lib"
    export CPPFLAGS="$CPPFLAGS -I$BINUTILS/include"
  fi

  # esp-idf
  local ESP_IDF="$HOME/esp/esp-idf"
  [ -d "$ESP_IDF" ] && alias get_idf=". $ESP_IDF/export.sh"

  # fontcustom
  local FONTCUSTOM="/Applications/FontForge.app"
  [ -d "$FONTCUSTOM" ] && export PATH="$PATH:$FONTCUSTOM/Contents/Resources/opt/local/bin"

  # gnu-sed
  local GNU_SED="$USR_LOCAL_OPT/gnu-sed"
  [ -d "$GNU_SED" ] && export PATH="$PATH:$GNU_SED/libexec/gnubin"

  # gnu-getopt
  local GNU_GETOPT="$USR_LOCAL_OPT/gnu-getopt"
  [ -d "$GNU_GETOPT" ] && export PATH="$PATH:$GNU_GETOPT/bin"

  # grep
  local GREP="%USR_LOCAL_OPT/grep"
  [ -d "$GREP" ] && export PATH="$PATH:$GREP/libexec/gnubin"

  # gettext
  local GETTEXT="$USR_LOCAL_OPT/gettext"
  if [ -d "$GETTEXT" ]; then
    export PATH="$PATH:$GETTEXT/bin"
    export LDFLAGS="$LDFLAGS -L$GETTEXT/lib"
    export CPPFLAGS="$CPPFLAGS -I$GETTEXT/include"
  fi

  # icu4c
  local ICU4C="$USR_LOCAL_OPT/icu4c"
  if [ -d "$ICU4C" ]; then
    export PATH="$PATH:$ICU4C/bin"
    export PATH="$PATH:$ICU4C/sbin"
    export LDFLAGS="$LDFLAGS -L$ICU4C/lib"
    export CPPFLAGS="$CPPFLAGS -I$ICU4C/include"
  fi

  # libffi
  local LIBFFI="$USR_LOCAL_OPT/libffi"
  [ -d "$LIBFFI" ] && export LDFLAGS="$LDFLAGS -L$LIBFFI/lib"

  # ncurses
  local NCURSES="$USR_LOCAL_OPT/ncurses"
  if [ -d "$NCURSES" ]; then
    export PATH="$PATH:$NCURSES/bin"
    export LDFLAGS="$LDFLAGS -L$NCURSES/lib"
    export CPPFLAGS="$CPPFLAGS -I$NCURSES/include"
    export PKG_CONFIG_PATH="$NCURSES/lib/pkgconfig"
  fi

  # nvm
  export NVM_DIR="$HOME/.nvm"
  local NVM="$USR_LOCAL_OPT/nvm"
  # This loads nvm
  [ -s "$NVM/nvm.sh" ] && . "$NVM/nvm.sh"
  # This loads nvm bash_completion
  [ -s "$NVM/etc/bash_completion.d/nvm" ] && . "$NVM/etc/bash_completion.d/nvm"

  # openjdk
  local OPENJDK="$USR_LOCAL_OPT/openjdk"
  if [ -d "$OPENJDK" ]; then
    # sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    export PATH="$OPENJDK/bin:$PATH"
    export CPPFLAGS="$CPPFLAGS -I$OPENJDK/include"
  fi

  # openssl
  local OPENSSL="$USR_LOCAL_OPT/openssl@1.1"
  if [ -d "$OPENSSL" ]; then
    export PATH="$PATH:$OPENSSL/bin"
    export LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
    export CPPFLAGS="$CPPFLAGS -I$OPENSSL/include"
  fi

  # readline
  local READLINE="$USR_LOCAL_OPT/readline"
  if [ -d "$READLINE" ]; then
    export LDFLAGS="$LDFLAGS -L$READLINE/lib"
    export CPPFLAGS="$CPPFLAGS -I$READLINE/include"
  fi

  # python@3
  local PYTHON3="$USR_LOCAL_OPT/python@3"
  if [ -d "$PYTHON3" ]; then
    export PATH="$PATH:$PYTHON3/bin"
    export LDFLAGS="$LDFLAGS -L$PYTHON3/lib"
  fi

  # python@2.7
  #export PATH="$HOME/Library/Python/2.7/bin:$PATH"

  # ruby
  if [ -d "$HOME/.gem" ]; then
    export GEM_HOME="$HOME/.gem"
    export PATH="$PATH:$HOME/.gem/bin"
  fi
  #RUBY="$USR_LOCAL_OPT/ruby"
  #export PATH="$PATH:$RUBY/bin"
  #export LDFLAGS="$LDFLAGS -L$RUBY/lib"
  #export CPPFLAGS="$CPPFLAGS -I$RUBY/include"

  # sming - esp8266
  if [ -d "$HOME/opt" ]; then
    export ESP_HOME="$HOME/opt/esp-quick-toolchain"
    export SMING_HOME="$HOME/opt/Sming/Sming"
  fi

  # sqlite
  local SQLITE="$USR_LOCAL_OPT/sqlite"
  if [ -d "$SQLITE" ]; then
    export PATH="$PATH:$SQLITE/bin"
    export LDFLAGS="$LDFLAGS -L$SQLITE/lib"
    export CPPFLAGS="$CPPFLAGS -I$SQLITE/include"
  fi

  ##
  # customization
  ##
  local DOTFILES="$HOME/personal/dotfiles"
  local DOTFILES_SYMLINKS="$DOTFILES/symlinks"

  local DOTFILES_SYMLINK="$HOME/dotfiles"
  if [ ! -d "$DOTFILES_SYMLINK" ]; then
    ln -s "$DOTFILES" "$DOTFILES_SYMLINK"
  fi

  local CUSTOM_GIT_COMMANDS_SYMLINK="$HOME/custom-git-commands"
  if [ ! -d "$CUSTOM_GIT_COMMANDS_SYMLINK" ]; then
    ln -s "$DOTFILES/custom-git-commands" "$CUSTOM_GIT_COMMANDS_SYMLINK"
  fi

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
    ln -s "$DOTFILES_SYMLINKS/ssh/config" "$SSH_CONFIG_SYMLINK"
    chmod 600 ~/.ssh/config
  fi
}

customize
unset -f customize

##
# alias
#
alias ls="ls -lisa"

# npm package
alias scripts="jq -r .scripts package.json"
alias dependencies="jq -r .dependencies package.json"
alias devDependencies="jq -r .devDependencies package.json"

# android adb
alias a:devices="adb devices"
alias a:reverse="adb reverse tcp:8081 tcp:8081; adb reverse tcp:8097 tcp:8097"
alias a:reload="adb shell input text 'RR'"
alias a:shake="adb shell input keyevent 82"

# react native - android
alias a:task="cd ./android && ./gradlew -PversionCode=1 tasks && cd .."
alias a:clean="cd ./android && ./gradlew -PversionCode=1 clean && cd .."
alias a:debug="cd ./android && ./gradlew -PversionCode=1 -PversionName=\"0.0.1\" app:installDebug && cd .."

# neovim
export EDITOR="nvim"
alias v="nvim"

