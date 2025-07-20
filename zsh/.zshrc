# Zsh configuration for dotfiles

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Aliases
alias ls="eza -l --no-user"
alias ll="eza -la --no-user"
alias la="eza -a --no-user"

# fnm (Fast Node Manager) setup
if command -v fnm >/dev/null 2>&1; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# uv (Python package manager) setup
if [ -f "$HOME/.local/bin/uv" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Go setup
if command -v go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
fi

# Claude Code completion (if available)
if command -v claude-code >/dev/null 2>&1; then
    eval "$(claude-code completion zsh)"
fi