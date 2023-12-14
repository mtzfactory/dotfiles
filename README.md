# Dotfiles

## Installation

Set `ZSH_THEME="powerlevel10k/powerlevel10k"` in your `~/.zshrc` file.

Add the following lines at the bottom of your `~/.zshrc` file.

```bash
# Custom ZSH
local DOTFILES="$HOME/{path-to}/dotfiles"

local CUSTOM_ZSH="$DOTFILES/{platform}/customize.zsh"
[[ ! -f $CUSTOM_ZSH ]] || source $CUSTOM_ZSH
```

## Generate a new SSH key

To generate a new SSSH key use this command:

```bash
$ ssh-keygen -t ed25519 -C "your-email-address@email.com"
```

Add the new generated SSH key to the SSH agent:

```bash
$ eval "$(ssh-agent -s)"

$ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Now you can test if you can connect to your repository provider:

```bash
ssh -T git@github.com

ssh -T git@bitbucket.org
```

You can read more about it [here][generating-a-new-ssh-key]

## Neovim

### Check dependencies

```bash
:checkhealth
```

[generating-a-new-ssh-key]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
