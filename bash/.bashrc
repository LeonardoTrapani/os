source ~/.local/share/omarchy/default/bash/rc

eval "$(starship init bash)"

# Text editors
alias v='nvim'
alias vim='nvim'

# Version control
alias g='git'

# Package manager
alias npm='pnpm'

# Listing files with color
alias ls='ls --color'

# Tmux session loader
alias tls='tmuxp load'

# Clear terminal
alias c='clear'

# Create directory and parent directories if needed
alias mkdir='mkdir -p'

# Tmuxp layout directory
export TMUXP_CONFIGDIR="$HOME/.config/tmux/layouts"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

