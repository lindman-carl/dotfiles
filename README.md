# Carl's dottyfiles

This directory contains the dottyfiles for my system

## Requirements

### Mac

#### Command Line Tools for Xcode
  
```bash
xcode-select --install
```

#### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### iTerm2

```bash
brew install --cask iterm2
```

### Linux

#### Kinto

In Ubuntu select XOrg instead of Wayland in the login screen settings. Requires a restart, logout is not sufficient.

```bash
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
```

### Common

#### Git

```bash
# Linux
sudo apt install git
# Install GH Cli and authenticate
# TODO: Install command GH Cli
gh auth login

# Mac
brew install git
```

#### Zsh

```bash
# Linux
sudo apt install zsh

# Mac
brew install zsh
```

#### Stow

```bash
# Linux
sudo apt install stow

# Mac
brew install stow
```

#### Oh-my-posh

```bash
# Linux
curl -s https://ohmyposh.dev/install.sh | bash -s

# Mac
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

## Installation

Clone this repository

```bash
git clone git@github.com:lindman-carl/dotfiles.git

cd dotfiles
```

Install the dotfiles with stow

```bash
stow .
```
