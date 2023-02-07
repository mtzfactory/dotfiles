# Dotfiles

Add this lines to the bottom of your `.zshrc` file.

```bash
# Custom ZSH
source DOTFILES="$HOME/path-to/dotfiles"

local CUSTOM_ZSH="$DOTFILES/custom-zsh/custom.zsh"
[[ ! -f $CUSTOM_ZSH ]] || source $CUSTOM_ZSH
```

