#!/usr/bin/env zsh

if [[ $(id -u) -eq 0 ]]; then
  echo -e "\nPlease run as a non root user." >&2;
  exit 1;
fi

###############################################################################
# Install Rust                                                                #
###############################################################################

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

###############################################################################
# Install Cargo apps                                                          #
###############################################################################

declare -a CARGO_APPS=(
  'worktrunk'        # Git worktree manager: https://worktrunk.dev
  'worktrunk-sync'   # Rebase stacked worktree branches: https://github.com/pablospe/worktrunk-sync
)

for app in "${CARGO_APPS[@]}"; do
  cargo install "$app"
done

###############################################################################
# Install Go apps                                                             #
###############################################################################

declare -a GO_APPS=(
  'github.com/jesseduffield/lazygit@latest'                                    # Git TUI
  'github.com/satococoa/git-worktreeinclude/cmd/git-worktreeinclude@latest'   # Copy ignored files across worktrees: https://github.com/satococoa/git-worktreeinclude
)

for app in "${GO_APPS[@]}"; do
  go install "$app"
done

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

