#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly DEFAULT_REPO_URL="https://github.com/ttusk/dotfiles.git"
readonly MONACO_FONT_URL="https://github.com/thep0y/monaco-nerd-font/releases/latest/download/MonacoNerdFontMono.zip"

REPO_URL="${DOTFILES_REPO_URL:-$DEFAULT_REPO_URL}"
if [[ -n "${DOTFILES_GIT_DIR:-}" && "$DOTFILES_GIT_DIR" != "$HOME/.dotfiles.git" ]]; then
  printf 'error: DOTFILES_GIT_DIR must be %s\n' "$HOME/.dotfiles.git" >&2
  exit 1
fi
readonly DOTFILES_ROOT="$HOME"
readonly DOTFILES_GIT_DIR="$DOTFILES_ROOT/.dotfiles.git"
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
BREW=""
BREW_PREFIX=""
DRY_RUN=0
TEMP_DIRS=()

if [[ -t 1 ]]; then
  BLUE=$'\033[1;34m'
  YELLOW=$'\033[1;33m'
  RESET=$'\033[0m'
else
  BLUE=""
  YELLOW=""
  RESET=""
fi

log() {
  printf '%s==>%s %s\n' "$BLUE" "$RESET" "$*"
}

warn() {
  printf '%swarning:%s %s\n' "$YELLOW" "$RESET" "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  local dir

  for dir in "${TEMP_DIRS[@]-}"; do
    [[ -n "$dir" ]] && rm -rf -- "$dir"
  done
  return 0
}

trap cleanup EXIT

run() {
  if ((DRY_RUN)); then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Install the dotfiles repository and its macOS development dependencies.

Options:
  --dry-run              Print mutating commands without running them
  --repo-url URL         Dotfiles repository (default: $DEFAULT_REPO_URL)
  --backup-dir DIR       Collision backup path (default: timestamped in $HOME)
  -h, --help             Show this help

The bare repository is always installed at:
  $DOTFILES_GIT_DIR

Environment variables provide the repository and backup overrides:
  DOTFILES_REPO_URL, DOTFILES_BACKUP_DIR
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        ;;
      --repo-url)
        shift
        (($#)) || die "--repo-url requires a value"
        REPO_URL="$1"
        ;;
      --backup-dir)
        shift
        (($#)) || die "--backup-dir requires a value"
        BACKUP_DIR="$1"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1"
        ;;
    esac
    shift
  done
}

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "this installer currently supports macOS only"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    BREW="$(command -v brew)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    BREW=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW=/usr/local/bin/brew
  else
    die "Homebrew is required; install it from https://brew.sh and rerun this script"
  fi

  BREW_PREFIX="$($BREW --prefix)"
  export PATH="$BREW_PREFIX/bin:$PATH"
}

same_as_head() {
  local mode="$1"
  local rel="$2"
  local target="$3"
  local expected

  case "$mode" in
    120000)
      [[ -L "$target" ]] || return 1
      expected="$(git --git-dir="$DOTFILES_GIT_DIR" show "HEAD:$rel")"
      [[ "$(readlink "$target")" == "$expected" ]]
      ;;
    100644|100755)
      [[ -f "$target" && ! -L "$target" ]] || return 1
      git --git-dir="$DOTFILES_GIT_DIR" show "HEAD:$rel" | cmp -s - "$target"
      ;;
    *)
      return 1
      ;;
  esac
}

backup_collisions() {
  log "Checking for dotfile collisions"

  local made_backup=0
  local entry mode rel target backup_target

  while IFS= read -r -d '' entry; do
    mode="${entry%% *}"
    rel="${entry#*$'\t'}"
    target="$HOME/$rel"

    if [[ -e "$target" || -L "$target" ]]; then
      if same_as_head "$mode" "$rel" "$target"; then
        continue
      fi

      backup_target="$BACKUP_DIR/$rel"
      if ((DRY_RUN)); then
        printf '  would move %s -> %s\n' "$target" "$backup_target"
      else
        mkdir -p -- "$(dirname -- "$backup_target")"
        mv -- "$target" "$backup_target"
        printf '  moved %s -> %s\n' "$target" "$backup_target"
      fi
      made_backup=1
    fi
  done < <(git --git-dir="$DOTFILES_GIT_DIR" ls-tree -r -z HEAD)

  if [[ "$made_backup" -eq 0 ]]; then
    printf '  no conflicting files found\n'
  elif ((DRY_RUN)); then
    printf '  backup directory: %s\n' "$BACKUP_DIR"
  else
    printf '  backup directory: %s\n' "$BACKUP_DIR"
  fi
}

verify_bare_repo() {
  local is_bare

  is_bare="$(git --git-dir="$DOTFILES_GIT_DIR" rev-parse --is-bare-repository 2>/dev/null)" \
    || die "$DOTFILES_GIT_DIR exists but is not a Git repository"
  [[ "$is_bare" == "true" ]] || die "$DOTFILES_GIT_DIR must be a bare Git repository"
}

install_dotfiles() {
  log "Installing dotfiles as a bare repository"

  if [[ -e "$DOTFILES_GIT_DIR" ]]; then
    local dirty index_entries

    verify_bare_repo
    index_entries="$(git --git-dir="$DOTFILES_GIT_DIR" --work-tree="$HOME" ls-files --cached)"
    if [[ -n "$index_entries" ]]; then
      dirty="$(git --git-dir="$DOTFILES_GIT_DIR" --work-tree="$HOME" status --porcelain=v1 --untracked-files=no)"
      [[ -z "$dirty" ]] || die "existing dotfile worktree has local changes; commit or stash them before running the installer"
    fi

    printf '  using existing repository: %s\n' "$DOTFILES_GIT_DIR"
  else
    printf '  cloning %s\n' "$REPO_URL"
    run git clone --bare "$REPO_URL" "$DOTFILES_GIT_DIR"
    ((DRY_RUN)) && return
    verify_bare_repo
  fi

  backup_collisions

  if ((DRY_RUN)); then
    printf '  would check out dotfiles into %s\n' "$HOME"
    return
  fi

  git --git-dir="$DOTFILES_GIT_DIR" --work-tree="$HOME" checkout --force
  git --git-dir="$DOTFILES_GIT_DIR" config --local status.showUntrackedFiles no
}

ensure_brew_formulae() {
  log "Installing Homebrew formulae"

  local -a formulae=(
    starship
    neovim
    nvm
    pnpm
    bun
    ghcup
    rustup
    elixir
    elixir-ls
    uv
    zoxide
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
  local -a missing=()
  local formula

  for formula in "${formulae[@]}"; do
    if "$BREW" list --formula "$formula" >/dev/null 2>&1; then
      printf '  %s already installed\n' "$formula"
    else
      missing+=("$formula")
    fi
  done

  if ((${#missing[@]})); then
    run "$BREW" install "${missing[@]}"
  fi
}

ensure_ghostty() {
  log "Installing Ghostty"

  if [[ -d /Applications/Ghostty.app ]] || "$BREW" list --cask ghostty >/dev/null 2>&1; then
    printf '  Ghostty already installed\n'
  else
    run "$BREW" install --cask ghostty
  fi
}

ensure_oh_my_zsh() {
  log "Installing Oh My Zsh"

  local zsh_dir="$HOME/.oh-my-zsh"

  if [[ -f "$zsh_dir/oh-my-zsh.sh" ]]; then
    printf '  Oh My Zsh already installed\n'
    return
  fi

  [[ ! -e "$zsh_dir" ]] || die "$zsh_dir exists but is not a valid Oh My Zsh installation"
  run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
}

link_if_needed() {
  local source="$1"
  local target="$2"

  [[ -e "$source" ]] || die "expected source path not found: $source"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      return
    fi
    rm -- "$target"
  elif [[ -e "$target" ]]; then
    return
  fi

  ln -s "$source" "$target"
}

setup_nvm_node() {
  log "Configuring NVM and Node.js LTS"

  local nvm_prefix nvm_script nvm_completion
  nvm_prefix="$($BREW --prefix nvm)"
  nvm_script="$nvm_prefix/nvm.sh"
  nvm_completion="$nvm_prefix/etc/bash_completion.d/nvm"

  if ((DRY_RUN)); then
    printf '+ mkdir -p %q\n' "$HOME/.nvm"
    printf '+ ln -s %q %q\n' "$nvm_script" "$HOME/.nvm/nvm.sh"
    printf '+ nvm install --lts\n'
    printf '+ nvm alias default lts/*\n'
    return
  fi

  mkdir -p -- "$HOME/.nvm"
  if [[ -e "$nvm_completion" ]]; then
    link_if_needed "$nvm_completion" "$HOME/.nvm/bash_completion"
  fi

  if [[ -x "$nvm_prefix/nvm-exec" ]]; then
    link_if_needed "$nvm_prefix/nvm-exec" "$HOME/.nvm/nvm-exec"
  fi

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm install --lts
  nvm alias default "lts/*"
}

setup_bun() {
  log "Configuring Bun"

  local bun_bin
  bun_bin="$($BREW --prefix bun)/bin/bun"

  if ((DRY_RUN)); then
    printf '+ mkdir -p %q\n' "$HOME/.bun/bin"
    printf '+ ln -s %q %q\n' "$bun_bin" "$HOME/.bun/bin/bun"
    return
  fi

  mkdir -p -- "$HOME/.bun/bin"
  link_if_needed "$bun_bin" "$HOME/.bun/bin/bun"
}

ensure_cargo_env() {
  [[ -f "$HOME/.cargo/env" ]] && return

  mkdir -p -- "$HOME/.cargo"
  cat > "$HOME/.cargo/env" <<'EOF'
#!/bin/sh
case ":${PATH}:" in
  *":${HOME}/.cargo/bin:"*) ;;
  *) export PATH="${HOME}/.cargo/bin:${PATH}" ;;
esac
EOF
}

setup_rust() {
  log "Configuring Rust"

  local rustup_bin
  rustup_bin="$BREW_PREFIX/bin/rustup"
  [[ -x "$rustup_bin" ]] || rustup_bin="$(command -v rustup || true)"
  [[ -n "$rustup_bin" ]] || die "rustup was not installed correctly"

  if ((DRY_RUN)); then
    printf '+ rustup default stable\n'
    printf '+ rustup component add rust-analyzer\n'
    printf '+ create %q\n' "$HOME/.cargo/env"
    return
  fi

  "$rustup_bin" default stable
  "$rustup_bin" component add rust-analyzer
  ensure_cargo_env
  export PATH="$HOME/.cargo/bin:$PATH"
}

ensure_ghcup_env() {
  [[ -f "$HOME/.ghcup/env" ]] && return

  mkdir -p -- "$HOME/.ghcup"
  cat > "$HOME/.ghcup/env" <<'EOF'
#!/bin/sh
case ":${PATH}:" in
  *":${HOME}/.ghcup/bin:"*) ;;
  *) export PATH="${HOME}/.ghcup/bin:${PATH}" ;;
esac
EOF
}

setup_haskell() {
  log "Configuring Haskell with GHCup"

  local ghcup_bin
  ghcup_bin="$(command -v ghcup || true)"
  [[ -n "$ghcup_bin" ]] || die "ghcup was not installed correctly"

  if ((DRY_RUN)); then
    printf '+ ghcup install ghc recommended --set\n'
    printf '+ ghcup install cabal recommended --set\n'
    printf '+ ghcup install stack recommended --set\n'
    printf '+ ghcup install hls recommended --set\n'
    printf '+ create %q\n' "$HOME/.ghcup/env"
    return
  fi

  ensure_ghcup_env
  export PATH="$HOME/.ghcup/bin:$PATH"

  if [[ ! -x "$HOME/.ghcup/bin/ghc" ]]; then
    "$ghcup_bin" install ghc recommended --set
  fi
  if [[ ! -x "$HOME/.ghcup/bin/cabal" ]]; then
    "$ghcup_bin" install cabal recommended --set
  fi
  if [[ ! -x "$HOME/.ghcup/bin/stack" ]]; then
    "$ghcup_bin" install stack recommended --set
  fi
  if [[ ! -x "$HOME/.ghcup/bin/haskell-language-server-wrapper" ]]; then
    "$ghcup_bin" install hls recommended --set
  fi
}

install_timer() {
  log "Installing timr-tui"

  if command -v timr-tui >/dev/null 2>&1; then
    printf '  timr-tui already installed\n'
  elif ((DRY_RUN)); then
    printf '+ cargo install timr-tui\n'
  else
    cargo install timr-tui
  fi
}

install_monaco_nerd_font() {
  log "Installing Monaco Nerd Font Mono"

  local font_dir="$HOME/Library/Fonts"
  local -a weights=(Regular Italic Bold BoldItalic)
  local weight missing=0 tmp source

  for weight in "${weights[@]}"; do
    [[ -f "$font_dir/MonacoNerdFontMono-$weight.ttf" ]] || missing=1
  done

  if [[ "$missing" -eq 0 ]]; then
    printf '  Monaco Nerd Font Mono already installed\n'
    return
  fi

  if ((DRY_RUN)); then
    printf '+ download %s\n' "$MONACO_FONT_URL"
    printf '+ install fonts into %q\n' "$font_dir"
    return
  fi

  require_command curl
  require_command unzip

  tmp="$(mktemp -d -t dotfiles-font.XXXXXX)"
  TEMP_DIRS+=("$tmp")
  curl -fsSL "$MONACO_FONT_URL" -o "$tmp/MonacoNerdFontMono.zip"
  mkdir -p -- "$tmp/font"
  unzip -q -o "$tmp/MonacoNerdFontMono.zip" -d "$tmp/font"
  mkdir -p -- "$font_dir"

  for weight in "${weights[@]}"; do
    source="$tmp/font/MonacoNerdFontMono-$weight.ttf"
    [[ -f "$source" ]] || die "font archive is missing $(basename "$source")"
    cp -f "$source" "$font_dir/"
  done

  if command -v atsutil >/dev/null 2>&1; then
    atsutil databases -removeUser >/dev/null 2>&1 || warn "could not refresh the user font cache"
  fi
}

verify_install() {
  if ((DRY_RUN)); then
    log "Skipping verification in dry-run mode"
    return
  fi

  log "Verifying installed tools"

  TERM="${TERM:-xterm-256color}" zsh -lic '
    set -eu
    for command_name in \
      starship nvim node pnpm bun cargo rustup rust-analyzer timr-tui \
      elixir-ls \
      elixir uv ghcup ghc cabal stack haskell-language-server-wrapper; do
      if ! command -v "$command_name" >/dev/null 2>&1; then
        printf "missing command: %s\\n" "$command_name" >&2
        exit 1
      fi
      printf "  %s -> %s\\n" "$command_name" "$(command -v "$command_name")"
    done
  '
}

main() {
  parse_args "$@"
  require_macos
  require_command git
  require_command zsh
  find_brew

  install_dotfiles
  ensure_brew_formulae
  ensure_ghostty
  ensure_oh_my_zsh
  setup_nvm_node
  setup_bun
  setup_rust
  setup_haskell
  install_timer
  install_monaco_nerd_font
  verify_install

  log "Done"
}

main "$@"
