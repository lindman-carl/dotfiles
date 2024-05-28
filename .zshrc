# ZSH auto-completion / Carl
source "$HOME/zsh-scripts/.zsh_autocomplete"

# Bindings for moving cursor one word left/right / Carl
source "$HOME/zsh-scripts/.zsh_keybindings"

# Custom aliases / Carl
source "$HOME/zsh-scripts/.zsh_alias"

# Don't know /Carl
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Flutter
export PATH=~/development/flutter/bin:$PATH

# Created by Carl, custom script for installing tailwindcss in a NPM-project
alias tailwind='npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p'

# For grouping directories first with ls /Carl
# alias ls='gls --group-directories-first'
alias ls='gls --color -h --group-directories-first'

# PNPM alias /Carl
alias pn='pnpm'

export LANG=en_US.UTF-8

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Created by `pipx` on 2023-09-18 21:14:42
export PATH="$PATH:/Users/carllindman/Library/Python/3.11/bin"

# Created by `pipx` on 2023-09-18 21:14:42
export PATH="$PATH:/Users/carllindman/.local/bin"

# Created by Carl for az cli completions
autoload -U +X compinit && compinit
autoload bashcompinit && bashcompinit source /opt/homebrew/etc/bash_completion.d/az

# Carls private script collection /Carl
export PATH="$PATH:/Users/carllindman/zsh-scripts"
# pnpm
export PNPM_HOME="/Users/carllindman/Library/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm endexport PATH="/opt/homebrew/opt/node@20/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

