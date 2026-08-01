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
`~/.dotfiles.git`. It also links the personal skills in
`~/.local/share/dotfiles/skills` into Codex and OpenCode without replacing their
managed skill directories.

## Manage deployed files

```sh
alias dotfiles='git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME"'
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m 'chore: update zsh configuration'
```

Do not commit credentials, machine-specific tokens, or generated application
state. Keep personal skills only in `.local/share/dotfiles/skills`; they are
linked to both agent clients by `install.sh`.

## Verification

```sh
bash tests/install-skills-test.sh
bash -n install.sh
zsh -n .zprofile .zshenv .zshrc
```
