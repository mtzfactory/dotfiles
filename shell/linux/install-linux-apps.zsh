#!/usr/bin/env zsh

if [[ $(id -u) -ne 0 ]]; then
  echo -e "\nPlease run as root." >&2;
  exit 1;
fi

# Set user-specific configuration directory
export XDG_CONFIG_HOME="$HOME/.config"
[ ! -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"

##
# python
if [ ! -x $(command -v python) ]; then
  if [ -x $(command -v python3)]; then
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    sudo apt -y install python3-pip
  fi
fi

##
# Install with apt
declare -a APT_APPS=(
  "batcat"
  "build-essentials"
  "curl"
  "git"
  "git-delta"
  "git-extras"
  "golang-go"
  "make"
  "neovim"
  "python3-neovim"
  "ripgrep"
  "tree"
  "wget"
  "zsh"
)

local APT
for APT in "${APT_APPS[@]}"; do
  echo -e "\n-- Installing $APT"
  sudo apt-get -y install "$APT"
done

##
# Install with npm
declare -a NPM_APPS=(
  "hunkdiff"
)

local NPM
for NPM in "${NPM_APPS[@]}"; do
  echo -e "\n-- Installing $NPM"
  npm i -g "$NPM"
done

# Change shell to Zsh
chsh -s $(which zsh)

# Install user apps
sudo -u $USER sh -c '$HOME/.dotfiles/linux/install-user-apps.zsh'

