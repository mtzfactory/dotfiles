#!/usr/bin/env zsh

if [[ $(id -u) -eq 0 ]]; then
  echo -e "\nPlease run as a non root user." >&2;
  exit 1;
fi

##
# Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

##
# Lazygit
local ARCH=$(uname -m)
if [ $ARCH -eq "aarch64"]; then
  go install github.com/jesseduffield/lazygit@latest
else
  local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
fi

##
# LunarVim
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

##
# Node Version Manager
echo -e "\n-- Installing nvm"
NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash

##
# Neovim plug
if [ "$EDITOR" = "nvim" ]; then
  echo -e "\n-- Installing Neovim Plug"
  curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

