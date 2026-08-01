#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_GIT_DIR="${DOTFILES_GIT_DIR:-$HOME/.dotfiles.git}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
BREW=""

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'This installer is currently macOS-only.\n' >&2
    exit 1
  fi
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    BREW="$(command -v brew)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    BREW=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW=/usr/local/bin/brew
  else
    printf 'Homebrew is required. Install it from https://brew.sh and rerun this script.\n' >&2
    exit 1
  fi
}

backup_collisions() {
  log "Backing up existing dotfile collisions"

  local made_backup=0
  local rel target backup_target

  while IFS= read -r rel; do
    target="$HOME/$rel"

    if [[ -e "$target" || -L "$target" ]]; then
      if cmp -s "$DOTFILES_DIR/$rel" "$target"; then
        continue
      fi

      backup_target="$BACKUP_DIR/$rel"
      mkdir -p "$(dirname "$backup_target")"
      mv "$target" "$backup_target"
      made_backup=1
      printf '  moved %s -> %s\n' "$target" "$backup_target"
    fi
  done < <(git -C "$DOTFILES_DIR" ls-files)

  if [[ "$made_backup" -eq 0 ]]; then
    printf '  no conflicting files found\n'
  else
    printf '  backup directory: %s\n' "$BACKUP_DIR"
  fi
}

install_dotfiles() {
  log "Installing dotfiles as a bare repository"

  backup_collisions

  if [[ ! -d "$DOTFILES_GIT_DIR" ]]; then
    git clone --bare "$DOTFILES_DIR" "$DOTFILES_GIT_DIR"
  fi

  git --git-dir="$DOTFILES_GIT_DIR" --work-tree="$HOME" checkout -f
  git --git-dir="$DOTFILES_GIT_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
}

install_skills() {
  log "Linking personal agent skills"

  local skills_dir="$DOTFILES_DIR/.local/share/dotfiles/skills"
  local client_dir skill target

  [[ -d "$skills_dir" ]] || return

  for client_dir in "$HOME/.codex/skills" "$HOME/.config/opencode/skills"; do
    mkdir -p "$client_dir"

    for skill in "$skills_dir"/*; do
      [[ -d "$skill" ]] || continue
      target="$client_dir/$(basename "$skill")"

      if [[ -e "$target" && ! -L "$target" ]]; then
        warn "Skipping existing skill directory: $target"
        continue
      fi

      ln -sfn "$skill" "$target"
    done
  done
}

brew_install_formulae() {
  log "Installing Homebrew formulae"

  local formulae=(
    starship
    neovim
    nvm
    pnpm
    bun
    ghcup
    rustup
    elixir
    uv
  )

  "$BREW" install "${formulae[@]}"
}

brew_install_casks() {
  log "Installing Homebrew casks"

  local casks=()

  if [[ ! -d "/Applications/Ghostty.app" ]]; then
    casks+=(ghostty)
  fi

  if ((${#casks[@]})); then
    "$BREW" install --cask "${casks[@]}"
  else
    printf '  all casks already installed\n'
  fi
}

link_brew_tools() {
  log "Linking Homebrew tools into ~/.local/bin"

  mkdir -p "$HOME/.local/bin"

  local cmd
  for cmd in starship nvim pnpm bun ghcup elixir elixirc mix iex erl uv uvx; do
    if [[ -x "$("$BREW" --prefix)/bin/$cmd" ]]; then
      ln -sfn "$("$BREW" --prefix)/bin/$cmd" "$HOME/.local/bin/$cmd"
    fi
  done

  if [[ -x "$("$BREW" --prefix rustup)/bin/rustup" ]]; then
    ln -sfn "$("$BREW" --prefix rustup)/bin/rustup" "$HOME/.local/bin/rustup"
  fi
}

setup_nvm_node() {
  log "Configuring NVM and Node.js LTS"

  local nvm_prefix
  nvm_prefix="$("$BREW" --prefix nvm)"

  mkdir -p "$HOME/.nvm"
  ln -sfn "$nvm_prefix/nvm.sh" "$HOME/.nvm/nvm.sh"
  ln -sfn "$nvm_prefix/etc/bash_completion.d/nvm" "$HOME/.nvm/bash_completion"

  if [[ -x "$nvm_prefix/nvm-exec" ]]; then
    ln -sfn "$nvm_prefix/nvm-exec" "$HOME/.nvm/nvm-exec"
  fi

  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm install --lts
  nvm alias default "lts/*"
}

setup_pnpm() {
  log "Configuring pnpm"

  mkdir -p "$HOME/Library/pnpm"
}

setup_bun() {
  log "Configuring Bun"

  mkdir -p "$HOME/.bun/bin"

  local bun_bin
  bun_bin="$("$BREW" --prefix bun)/bin/bun"

  if [[ -x "$bun_bin" ]]; then
    ln -sfn "$bun_bin" "$HOME/.bun/bin/bun"
  fi
}

setup_rust() {
  log "Configuring Rust"

  local rustup_bin toolchain_bin cmd
  rustup_bin="$("$BREW" --prefix rustup)/bin/rustup"

  mkdir -p "$HOME/.cargo/bin"
  "$rustup_bin" default stable

  cat > "$HOME/.cargo/env" <<'EOF'
#!/bin/sh
case ":${PATH}:" in
  *":${HOME}/.cargo/bin:"*) ;;
  *) export PATH="${HOME}/.cargo/bin:${PATH}" ;;
esac
EOF

  toolchain_bin="$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin"
  if [[ ! -d "$toolchain_bin" ]]; then
    toolchain_bin="$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/bin"
  fi

  for cmd in cargo cargo-clippy cargo-fmt clippy-driver rustc rustdoc rustfmt; do
    if [[ -x "$toolchain_bin/$cmd" ]]; then
      ln -sfn "$toolchain_bin/$cmd" "$HOME/.cargo/bin/$cmd"
    fi
  done

  ln -sfn "$rustup_bin" "$HOME/.cargo/bin/rustup"
}

setup_haskell() {
  log "Configuring Haskell with GHCup"

  "$HOME/.local/bin/ghcup" install ghc recommended
  "$HOME/.local/bin/ghcup" set ghc recommended
  "$HOME/.local/bin/ghcup" install cabal recommended
  "$HOME/.local/bin/ghcup" set cabal recommended
  "$HOME/.local/bin/ghcup" install stack recommended
  "$HOME/.local/bin/ghcup" set stack recommended
  "$HOME/.local/bin/ghcup" install hls recommended
  "$HOME/.local/bin/ghcup" set hls recommended

  mkdir -p "$HOME/.ghcup"
  cat > "$HOME/.ghcup/env" <<'EOF'
#!/bin/sh
case ":${PATH}:" in
  *":${HOME}/.ghcup/bin:"*) ;;
  *) export PATH="${HOME}/.ghcup/bin:${PATH}" ;;
esac
EOF
}

install_timer() {
  log "Installing timr-tui"

  "$HOME/.cargo/bin/cargo" install timr-tui
}

install_monaco_nerd_font() {
  log "Installing Monaco Nerd Font Mono"

  local tmp zip
  tmp="$(mktemp -d)"
  zip="$tmp/MonacoNerdFontMono.zip"

  curl -fL \
    https://github.com/thep0y/monaco-nerd-font/releases/latest/download/MonacoNerdFontMono.zip \
    -o "$zip"

  unzip -q -o "$zip" -d "$tmp/font"
  mkdir -p "$HOME/Library/Fonts"
  cp -f "$tmp"/font/*.ttf "$HOME/Library/Fonts/"

  if command -v atsutil >/dev/null 2>&1; then
    atsutil databases -removeUser >/dev/null 2>&1 || warn "Could not refresh user font cache"
  fi
}

verify_install() {
  log "Verifying installed tools"

  zsh -ic '
    set -e
    command -v starship
    command -v nvim
    command -v node
    command -v pnpm
    command -v bun
    command -v cargo
    command -v timr-tui
    command -v elixir
    command -v uv
    command -v ghc
    command -v cabal
    command -v stack
    command -v haskell-language-server-wrapper
  '
}

main() {
  require_macos
  find_brew

  install_dotfiles
  install_skills
  brew_install_formulae
  brew_install_casks
  link_brew_tools
  setup_nvm_node
  setup_pnpm
  setup_bun
  setup_rust
  install_timer
  setup_haskell
  install_monaco_nerd_font
  verify_install

  log "Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
