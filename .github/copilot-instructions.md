# Copilot instructions for this repository

This is a personal **dotfiles** repo, not an application. It provisions shell
environments (zsh), editor configs (AstroNvim/Neovim/LunarVim), git tooling,
and a home-lab server (via Ansible + Terraform). There is no app build/test
suite — changes are validated by sourcing the shell or re-running the
relevant provisioning tool.

## Validating changes

There is no CI and no test runner. Validate changes like this instead:

- **Shell scripts** (`shell/**/*.zsh`): syntax-check with
  `zsh -n path/to/file.zsh`, then `source` it (or open a new shell) to
  confirm it loads without errors. `DOTFILES` must be exported first:
  `export DOTFILES="$(pwd)"`.
- **Neovim/AstroNvim config** (`config/astronvim/**`): open with
  `NVIM_CONFIG=astronvim nvim` and check `:checkhealth`. Lua is linted with
  `selene` (`config/astronvim/selene.toml`) and formatted with `stylua`
  (`config/astronvim/.stylua.toml`).
- **Ansible** (`ansible/**`): dry-run with
  `ansible-playbook -i inventory.ini main.yml -e @vars.yml --check` from
  `ansible/` (requires a real `inventory.ini`, copied from
  `inventory.ini.example`). Use `--tags <role>` to target one role, e.g.
  `--tags dotfiles`.
- **Terraform** (`terraform/`): `terraform fmt` / `terraform validate` /
  `terraform plan` from `terraform/`.

## Architecture

- **`shell/customize.zsh`** is the entry point sourced from `~/.zshrc` (via
  the `$DOTFILES` env var). It loads, in order: `env.zsh` → `alias.zsh` →
  `shared/wt-session.zsh` → the OS-specific `shell/$OS/customize-$OS.zsh`
  (`darwin` or `linux`, chosen by `uname`) → `create-symlinks.zsh`. When
  adding shell customization, decide whether it's OS-agnostic (`env.zsh`,
  `alias.zsh`, `shared/`) or OS-specific (`darwin/` or `linux/`), and keep
  both OS variants in sync for shared concepts.
- **`shell/create-symlinks.zsh`** idempotently symlinks `config/*` into
  `$XDG_CONFIG_HOME` and dotfiles into `$HOME` (git configs, ssh config,
  worktrunk, lazygit, pip, and the selected Neovim flavor). It backs up any
  pre-existing real directory to `*.bak` before symlinking. The Neovim flavor
  (`astronvim` | `nvim` | `lvim`) is selected by `$NVIM_CONFIG` (set in
  `env.zsh`, default `astronvim`); `lvim` manages its own config dir
  (`~/.config/lvim`) so it's excluded from the generic Neovim symlink step.
- **`shell/install-apps.zsh`** is the bootstrap entrypoint for a fresh
  machine: sources `env.zsh`, then runs the OS-specific
  `install-$OS-apps.zsh`, then `install-zsh-plugins.zsh`.
- **Git config layering**: `config/git/gitconfig` uses `includeIf "gitdir:"`
  to conditionally load `gitconfig-work`, `gitconfig-personal`, or
  `gitconfig-homelab` based on the repo's path — so identity/signing config
  is chosen by *directory location*, not manually switched. Custom git
  subcommands live as executables in `config/git/custom-git-commands/`
  (e.g. `git-stack`, `git-purge-branches`) and are exposed via `PATH` in
  `customize-darwin.zsh`.
- **Home-lab provisioning** is split across two tools with different scopes:
  Terraform (`terraform/main.tf`) declares the on-disk directory tree for
  self-hosted services on the server (`~/home-lab/services/<svc>`); Ansible
  (`ansible/main.yml`) provisions the server itself, running roles in a
  fixed order (`system` → `dotfiles` → `git` → `docker` → `security` →
  `backups`), each independently taggable. Ansible role comments/docs are
  written in Spanish — follow that convention within `ansible/`.
- **`worktrunk`** (`shell/shared/wt-session.zsh`, config in
  `config/worktrunk/`) wraps the `wt` git-worktree CLI: it force-adds
  `--foreground` to `wt remove` (see the comment block in that file for why),
  and `wts`/`wto` are custom wrappers that additionally sync a
  tmux session / herdr workspace to the worktree's branch. The
  `~/.local/bin/wt` PATH shim (symlinked from `config/worktrunk/wt`) exists
  specifically to make this wrapper apply to *every* caller, including
  non-interactive/agent shells, not just interactive zsh — don't remove it
  as "dead code".

## Conventions

- Shell scripts are zsh (`#!/usr/bin/env zsh`), not POSIX sh/bash — they use
  zsh-only features (`local`, `setopt extended_glob`, associative-array-style
  `${commands[x]}` checks, `(( $+functions[x] ))`).
- Idempotency matters: symlink/install scripts check `[ -f ... ]` / `[ -d ... ]`
  / `[ -L ... ]` before acting, since they're re-run on every new shell or
  re-provision.
- Non-trivial or non-obvious logic gets a `##`-delimited comment block above
  it explaining *why*, not just what (see `wt-session.zsh`, `create-symlinks.zsh`).
  Follow this style for new additions of similar complexity.
- Machine-specific/hardware assumptions are called out explicitly in comments
  (e.g. Apple Silicon paths hardcoded to `/opt/homebrew`) rather than
  detected dynamically, to avoid subprocess costs at shell startup.
- Secrets (GPG private keys, real `inventory.ini`, `terraform.tfvars`) are
  never committed — only `.example` templates are tracked
  (`ansible/inventory.ini.example`, `terraform/terraform.tfvars.example`).
