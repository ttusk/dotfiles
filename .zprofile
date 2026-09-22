# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/luizgustavo/.docker/bin"
# End of Docker Desktop section.

# >>> coursier install directory >>>
export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<

# Added by OrbStack: command-line tools and integration
[ -f "$HOME/.orbstack/shell/init.zsh" ] && source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

# Added by Obsidian
[ -d "/Applications/Obsidian.app" ] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
