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