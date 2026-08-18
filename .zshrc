# 1. Base environment
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# 2. Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_AUTO_UPDATE="true"
plugins=(
  git
  history-substring-search
  vi-mode
  docker
  docker-compose
  nvm
  npm
  node
  bun
  uv
  macos
  zoxide
  fzf
)

export NVM_DIR="$HOME/.nvm"
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' silent-autoload yes

source "$ZSH/oh-my-zsh.sh"

# 3. History and completion
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'

# 4. Command feedback
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#586e75'
if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting must be loaded after other Zsh plugins.
if [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 5. Starship prompt
__set_starship_theme() {
  local config="$HOME/.config/starship.toml"

  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
    config="$HOME/.config/starship-dark.toml"
  fi

  export STARSHIP_CONFIG="$config"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __set_starship_theme
__set_starship_theme
eval "$(starship init zsh)"

# 6. Aliases and helpers
alias vim='nvim'
alias push='git push'
alias add='git add'
alias commit='git commit -m'
alias clone='git clone'
alias pull='git pull'
alias cls='clear'
alias ll='ls -lah'
alias la='ls -A'
alias timer='timr-tui'
alias ..='cd ..'
alias dotfiles='git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME"'
alias dots='dotfiles'

mkcd() {
  if [ $# -ne 1 ]; then
    echo 'uso: mkcd diretorio'
    return 2
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

force() {
  if [ $# -eq 0 ]; then
    echo 'uso: force "mensagem do commit"'
    return 2
  fi

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo 'force: nao esta dentro de um repositorio Git'
    return 1
  fi

  git add . && git commit -m "$*" && git push
}

vault_qmd() {
  (cd "$HOME/git/vault" && qmd "$@")
}
