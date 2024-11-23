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

local APP
for APP in "${APT_APPS[@]}"; do
  echo -e "\n-- Installing $APP"
  sudo apt-get install "$APP"
done

# Change shell to Zsh
chsh -s $(which zsh)

# Install user apps
sudo -u $USER sh -c '$HOME/.dotfiles/linux/install-user-apps.zsh'

