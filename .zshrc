#!/usr/bin/env zsh
export LANG=en_US.UTF-8

source "$HOME/zsh-config/.zsh_alias"
source "$HOME/zsh-config/.zsh_autocomplete"
source "$HOME/zsh-config/.zsh_keybindings"
source "$HOME/zsh-config/completion-for-pnpm.bash"

setopt MENU_COMPLETE

# Load custom configurations based on the host
if [[ "$HOST" == "Carl" ]]; then
    echo "$HOST: zsh config for MacBook Pro M1"
    source "$HOME/zsh-config/.zshrc_mbpm1"
fi

if [[ "$HOST" == "gmk" ]]; then
    echo "$HOST: zsh config for GMK"
    source "$HOME/zsh-config/.zshrc_gmk"
fi

# Load Oh My Posh theme
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/oh-my-posh/uew.omp.json)"
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export OPENCODE_MODEL="github-copilot/claude-sonnet-4.6"
export OPENCODE_OPUS_MODEL="github-copilot/claude-opus-4.6"
export OPENCODE_HAIKU_MODEL="github-copilot/claude-haiku-4.5"

# Enable selection (region highlighting)
autoload -Uz select-word-style
zle_highlight+=(region:bg=blue)


# Shift + Left/Right
bindkey "^[[1;2D" backward-char
bindkey "^[[1;2C" forward-char