# Carl's dotfiles

Carl's base dotfiles configuration repo. Uses GNU Stow to symlink dotfiles to be a bit organized.

## Requirements

### MacOS
  
```bash
# Command Line Tools for Xcode
xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# iTerm2
brew install --cask iterm2

# Git and GH cli
brew install git
brew install gh

# Oh My Posh
brew install jandedobbeleer/oh-my-posh/oh-my-posh

# GNU Stow
brew install stow
```

### Linux

```bash
sudo apt update -y
sudo apt upgrade -y

# ZSH
sudo apt install zsh
# Set as default shell
chsh -s $(which zsh)

# Git
sudo apt install git
# GH CLI https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Oh My Posh
sudo apt install unzip
curl -s https://ohmyposh.dev/install.sh | bash -s

# GNU Stow
sudo apt install stow 
```

## Installing dotfiles

```bash
# Clone this repo
gh auth login
git clone git@github.com:lindman-carl/dotfiles.git $HOME/dotfiles
cd $HOME/dotfiles

# First time use of stow:
stow .

# To 'restow':
stow -R .
```

## Optional

### Kinto, MacOS like keybindings for Linux (*This probably requires Ubuntu Desktop*)

In Ubuntu select XOrg instead of Wayland in the login screen settings. Requires a restart, logout is not sufficient.

```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
```
