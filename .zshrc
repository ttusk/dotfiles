# 1. PATH base e Docker
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# 2. Starship Prompt
eval "$(starship init zsh)"

# 3. NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 4. Aliases
alias vim='nvim'
alias push='git push'
alias add='git add'
alias commit='git commit -m'
alias clone='git clone'
alias pull='git pull'
alias cls='clear'
alias timer='timr-tui'
alias ..='cd ..'
alias dotfiles='git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME'
alias dots='dotfiles'

# 5. PNPM
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# 6. Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# 7. Outros Envs (GHCup, etc)
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

vault_qmd() {
  (cd "$HOME/git/vault" && qmd "$@")
}

export PATH="$HOME/.opencode/bin:$PATH"
