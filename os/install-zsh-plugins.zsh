#!/usr/bin/env zsh

##
# zsh plugins
#
if [ "$SHELL" = "/bin/zsh" ]; then
  ##
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  if [ -x "$(command -v omz)" ]; then
    ##
    # Plugin customization
    declare -A ZSH_INSTALL_PLUGINS

    ZSH_INSTALL_PLUGINS[zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ZSH_INSTALL_PLUGINS[zsh-bat]="https://github.com/fdellwing/zsh-bat.git"
    ZSH_INSTALL_PLUGINS[zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
    ZSH_INSTALL_PLUGINS[zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git "
    ZSH_INSTALL_PLUGINS[zsh-z]="https://github.com/agkozak/zsh-z.git"

    local ZSH_INSTALL_PLUGIN
    for ZSH_INSTALL_PLUGIN in "${!ZSH_INSTALL_PLUGINS[@]}"; do
      git clone --depth=1 "${ZSH_INSTALL_PLUGINS[$ZSH_INSTALL_PLUGIN]}" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$ZSH_INSTALL_PLUGIN"
      omz plugin enable "$ZSH_INSTALL_PLUGIN"
    done

    declare -a ZSH_ENALBE_PLUGINS=(
      encode64
      transfer
    )

    local ZSH_ENABLE_PLUGIN
    for ZSH_ENABLE_PLUGIN in "${!ZSH_ENALBE_PLUGINS[@]}"; do
      omz plugin enable "$ZSH_ENABLE_PLUGIN"
    done

    declare -a ZSH_APP_PLUGINS=(
      eza
    )

    local ZSH_APP_PLUGIN
    for ZSH_APP_PLUGIN in "${!ZSH_APP_PLUGINS[@]}"; do
      [ -x "$(command -v $ZSH_APP_PLUGIN)" ] && omz plugin enable "$ZSH_APP_PLUGIN"
    done

    ##
    # Theme customization
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    omz theme set "powerlevel10k/powerlevel10k"
    p10k configure
  fi
fi

