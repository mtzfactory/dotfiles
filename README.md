# Dotfiles

Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc`.

Add this lines to the bottom of your `~/.zshrc` file.

```bash
# Custom ZSH
source DOTFILES="$HOME/path-to/dotfiles"

local CUSTOM_ZSH="$DOTFILES/custom-zsh/custom.zsh"
[[ ! -f $CUSTOM_ZSH ]] || source $CUSTOM_ZSH
```

## Generating a new SSH key and adding it to the ssh-agent

```bash
$ ssh-keygen -t ed25519 -C "your-email-address@email.com"

$ eval "$(ssh-agent -s)"

$ ssh-add --apple-use-keychain ~/.ssh/id_ed25519

ssh -T git@github.com
```

You can read more about it [here][generating-a-new-ssh-key]

[generating-a-new-ssh-key]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
