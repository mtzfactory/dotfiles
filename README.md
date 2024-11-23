# Dotfiles

## Installation

Add the following lines at the bottom of your `~/.zshrc` file.

```bash
# Custom ZSH
export DOTFILES="$HOME/{path-to}/dotfiles"

local CUSTOM_ZSH="$DOTFILES/os/customize.zsh"
[[ ! -f $CUSTOM_ZSH ]] || source $CUSTOM_ZSH
```

## Generate a new SSH key

To generate a new SSSH key use this command:

```bash
$ ssh-keygen -t [ed25519 | rsa] [-b 4096] -C "your-email-address@email.com" -f ~/.ssh/id_[ed25519 | rsa]
```

Add the new generated SSH key to the local SSH agent:

```bash
$ eval "$(ssh-agent -s)"

$ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

At this point, you can test if you can connect to your repository provider:

```bash
ssh -T git@[github.com | bitbucket.org | gitlab.com]
```

You can read more about it [here][generating-a-new-ssh-key]

Now, you can clone this repo using the new SSH key:

```bash
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa_w4p" git clone git@github.com:mtzfactory/dotfiles.git
```

## Vim

### LunarVim 

Fix [errors after an update][lvim-troubleshooting], run command:

```bash
:LvimCacheReset
```

#### Custom keys

- `F12`: toggles relative row number.
- `<C-t>`: jump back from _go to definition_.
- `]b`: go to next buffer.
- `[b`: go to previous buffer.
- `]d`: go to next diagnostic.
- `[d`: go to previous diagnostic.

### Neovim

#### Check dependencies

```bash
:checkhealth
```

<!-- Links -->
[generating-a-new-ssh-key]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[lvim-troubleshooting]: https://www.lunarvim.org/es/docs/troubleshooting#getting-errors-after-an-update
