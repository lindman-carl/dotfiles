# Carl's dottyfiles

This directory contains the dorfiles for my system

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

### Common

#### Git

```bash
# Linux
sudo apt install git

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

## Installation

Clone this repository

```bash
git clone git@https://github.com/lindman-carl/dotfiles

cd dotfiles
```

Install the dotfiles with stow

```bash
stow .
```

