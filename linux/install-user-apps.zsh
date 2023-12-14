#!/usr/bin/env zsh

if [[ $(id -u) -eq 0 ]]; then
  echo -e "\nPlease run as a non root user." >&2;
  exit 1;
fi

local BASH_PROFILE="$HOME/.bash_profile"
if [ ! -f "$BASH_PROFILE" ]; then
  sudo -u vibia sh -c 'touch "$HOME/.bash_profile"'
  sudo -u vibia sh -c 'echo "export SHELL=/bin/zsh" >> "$HOME/.bash_profile"'
  sudo -u vibia sh -c 'echo "exec /bin/zsh -l" >> "$HOME/.bash_profile"'
fi

local BASH_RC="$HOME/.bashrc"
if [ -f "$BASH_RC" ]; then
  sudo -u vibia sh -c 'mv "$HOME/.bashrc" "$HOME/.bashrc"__temp'
fi

# Zsh plugins
echo -e "\n--Installing zsh plugin: autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

echo -e "\n--Installing zsh plugin: history-substring-search"
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-history-substring-search

echo -e "\n--Installing zsh plugin: syntax-highlighting"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

echo -e "\n--Installing zsh plugin: z"
git clone --depth=1 https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-z

# Zsh theme
echo -e "\n--Installing zsh theme: powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k

# Node Version Manager
echo -e "\n-- Installing nvm"
NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash

# Neovim Plug
echo -e "\n-- Installing Neovim Plug"
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Configure powerlevel10k
p10k configure

