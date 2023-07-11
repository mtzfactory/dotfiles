#!/usr/bin/env zsh

if [[ $(id -u) -ne 0 ]]; then
  echo -e "\nPlease run as root." >&2;
  exit 1;
fi

declare -a APT_APPS=(
  "bat"
  "neovim"
  "python3-neovim"
  "tree"
  "zsh"
)

for APP in "${APT_APPS[@]}"; do
  echo -e "\n-- Installing $APP"
  sudo apt-get install "$APP"
done

sudo -u vibia sh -c '$HOME/.dotfiles/linux/install-user-apps.zsh'

