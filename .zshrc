#!/usr/bin/env zsh

source "$HOME/zsh-config/.zsh_alias"
source "$HOME/zsh-config/.zsh_autocomplete"
source "$HOME/zsh-config/.zsh_keybindings"
source "$HOME/zsh-config/completion-for-pnpm.bash"

setopt MENU_COMPLETE

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/oh-my-posh/theme.json)"
fi

export LANG=en_US.UTF-8

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [[ "$HOST" == "Carl" ]]; then
    echo "$HOST: zsh config for MacBook Pro M1"
    source "$HOME/zsh-config/.zshrc_mbpm1"
fi

if [[ "$HOST" == "gmk" ]]; then
    echo "$HOST: zsh config for GMK"
    source "$HOME/zsh-config/.zshrc_gmk"
fi