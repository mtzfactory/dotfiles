# zsh etenxions
autoload -U zmv

# opting out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

##
# apps
##

# android
ANDROID="$HOME/Library/Android"
if [ -d "$ANDROID" ]; then
  export ANDROID_HOME="$ANDROID/sdk"
  export ANDROID_SDK_ROOT="$ANDROID/sdk"
  export PATH="$PATH:$ANDROID_HOME/emulator"
  export PATH="$PATH:$ANDROID_HOME/platform-tools"
  export PATH="$PATH:$ANDROID_HOME/tools"
  export PATH="$PATH:$ANDROID_HOME/tools/bin"
fi

# base root directory for brew intalled apps
USR_LOCAL_OPT="/usr/local/opt"

# coreutils
COREUTILS="$USR_LOCAL_OPT/coreutils"
[ -d "$COREUTILS" ] && export PATH="$PATH:$COREUTILS/libexec/gnubin"

# binutils
BINUTILS="$USR_LOCAL_OPT/binutils"
if [ -d "$BINUTILS" ]; then
  export PATH="$PATH:$BINUTILS/bin"
  export LDFLAGS="$LDFLAGS -L$BINUTILS/lib"
  export CPPFLAGS="$CPPFLAGS -I$BINUTILS/include"
fi

# esp-idf
ESP_IDF="$HOME/esp/esp-idf"
[ -d "$ESP_IDF" ] && alias get_idf=". $ESP_IDF/export.sh"

# gnu-sed
GNU_SED="$USR_LOCAL_OPT/gnu-sed"
[ -d "$GNU_SED" ] && export PATH="$PATH:$GNU_SED/libexec/gnubin"

# gnu-getopt
GNU_GETOPT="$USR_LOCAL_OPT/gnu-getopt"
[ -d "$GNU_GETOPT" ] && export PATH="$PATH:$GNU_GETOPT/bin"

# grep
GREP="%USR_LOCAL_OPT/grep"
[ -d "$GREP" ] && export PATH="$PATH:$GREP/libexec/gnubin"

# gettext
GETTEXT="$USR_LOCAL_OPT/gettext"
if [ -d "$GETTEXT" ]; then
  export PATH="$PATH:$GETTEXT/bin"
  export LDFLAGS="$LDFLAGS -L$GETTEXT/lib"
  export CPPFLAGS="$CPPFLAGS -I$GETTEXT/include"
fi

# icu4c
ICU4C="$USR_LOCAL_OPT/icu4c"
if [ -d "$ICU4C" ]; then
  export PATH="$PATH:$ICU4C/bin"
  export PATH="$PATH:$ICU4C/sbin"
  export LDFLAGS="$LDFLAGS -L$ICU4C/lib"
  export CPPFLAGS="$CPPFLAGS -I$ICU4C/include"
fi

# libffi
LIBFFI="$USR_LOCAL_OPT/libffi"
[ -d "$LIBFFI" ] && export LDFLAGS="$LDFLAGS -L$LIBFFI/lib"

# ncurses
NCURSES="$USR_LOCAL_OPT/ncurses"
if [ -d "$NCURSES" ]; then
  export PATH="$PATH:$NCURSES/bin"
  export LDFLAGS="$LDFLAGS -L$NCURSES/lib"
  export CPPFLAGS="$CPPFLAGS -I$NCURSES/include"
  export PKG_CONFIG_PATH="$NCURSES/lib/pkgconfig"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
NVM="$USR_LOCAL_OPT/nvm"
# This loads nvm
[ -s "$NVM/nvm.sh" ] && . "$NVM/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM/etc/bash_completion.d/nvm" ] && . "$NVM/etc/bash_completion.d/nvm"

# openjdk
OPENJDK="$USR_LOCAL_OPT/openjdk"
if [ -d "$OPENJDK" ]; then
  export PATH="$PATH:$OPENJDK/bin"
  export CPPFLAGS="$CPPFLAGS -I$OPENJDK/include"
fi

# openssl
OPENSSL="$USR_LOCAL_OPT/openssl@1.1"
if [ -d "$OPENSSL" ]; then
  export PATH="$PATH:$OPENSSL/bin"
  export LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
  export CPPFLAGS="$CPPFLAGS -I$OPENSSL/include"
fi

# readline
READLINE="$USR_LOCAL_OPT/readline"
if [ -d "$READLINE" ]; then
  export LDFLAGS="$LDFLAGS -L$READLINE/lib"
  export CPPFLAGS="$CPPFLAGS -I$READLINE/include"
fi

# python@3
PYTHON3="$USR_LOCAL_OPT/python@3"
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
SQLITE="$USR_LOCAL_OPT/sqlite"
if [ -d "$SQLITE" ]; then
  export PATH="$PATH:$SQLITE/bin"
  export LDFLAGS="$LDFLAGS -L$SQLITE/lib"
  export CPPFLAGS="$CPPFLAGS -I$SQLITE/include"
fi

##
# custom git commands
##
export PATH="$PATH:$HOME/custom-git-commands"

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


