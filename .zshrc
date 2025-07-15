source "$HOME/dotfiles/.zsh_alias"
source "$HOME/dotfiles/.zsh_keybindings"
source "$HOME/dotfiles/.zsh_autocomplete"
source "$HOME/dotfiles/completion-for-pnpm.bash"

setopt MENU_COMPLETE

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/oh-my-posh-theme/theme.json)"
fi

export LANG=en_US.UTF-8
export PATH="$PATH:$HOME/dotfiles/"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [[ "$HOST" == "Carl" ]]; then
    source "$HOME/dotfiles/.zshrc_mbpm1"
fi

if [[ "$HOST" == "gmk" ]]; then
    source "$HOME/dotfiles/.zshrc_gmk"
fi