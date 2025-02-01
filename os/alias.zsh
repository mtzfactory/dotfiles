#!/usr/bin/env zsh

local OS=$(uname | tr '[:upper:]' '[:lower:]')

killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port_number>"
    return 1
  fi

  local PID=$(lsof -i :"$1" -t)

  if [ -n "$PID" ]; then
    kill -15 "$PID" && echo "Process with PID $PID killed on port $1"
  else
    echo "No process found on port $1"
  fi
}

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
# alias scripts='f() { if [ -n "$1" ]; then if [ -f "$1" ]; then PACKAGE_FILE="$1"; else echo "No file $1"; exit 1; fi; else PACKAGE_FILE="package.json"; fi; jq -r .scripts "$PACKAGE_FILE" }; f'
scripts() {
  local PACKAGE_FILE

  if [ ! -x $(command -v jq) ]; then
      echo "Error: jq is not installed" >&2
      return 1
  fi

  if [ -n "$1" ]; then
    PACKAGE_FILE="$1"
  else
    PACKAGE_FILE="package.json"
  fi

  if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: File not found: $PACKAGE_FILE" >&2
    return 1
  fi

  if ! jq -e . >/dev/null 2>&1 <"$PACKAGE_FILE"; then
    echo "Error: Invalid JSON in $PACKAGE_FILE" >&2
    return 1
  fi

  jq -e '.scripts // empty' "$PACKAGE_FILE"
}

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

# time
alias timestamp2date='fn(){ date -jf "%s" "$1" +"%Y-%m-%d %H:%M:%S"; unset -f fn; }; fn'

# lazygit
alias lg="lazygit"

# vim
alias v="nvim"
alias lv="lvim"

# by OS
if [ "$OS" = "darwin" ]; then
  # ios
  alias i:simulator="xcrun simctl list devices"

  # python
  alias pip="pip3"
fi

