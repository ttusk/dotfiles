# dotfiles

Personal macOS configuration for Zsh, Ghostty, Neovim, Starship, and agent skills.

## Install

```sh
git clone https://github.com/ttusk/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
./install.sh
```

The installer backs up conflicting tracked files, installs the declared Homebrew
packages, and checks out this repository as the `$HOME` worktree of
`~/.dotfiles.git`. Personal Codex skills live directly in `.codex/skills` and
are restored with the rest of the repository.

## Manage deployed files

```sh
alias dotfiles='git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME"'
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m 'chore: update zsh configuration'
```

Do not commit credentials, machine-specific tokens, or generated application
state. Keep personal skills under `.codex/skills`.

## Verification

```sh
bash -n install.sh
zsh -n .zprofile .zshenv .zshrc
```
