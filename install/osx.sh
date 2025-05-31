#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# OSX version

# before running ensure that there is a valid ssh key authorized for github

# ensure dev tools setup
sudo xcodebuild -license || exit

# OSX Specific install

# Install homebrew
NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/main/install.sh)" || exit

# Manually add installed homebrew to path for installations below
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install homebrew packages
brew install node
brew install cmake
brew install ffmpeg
brew install vim
brew install neovim
brew install tmux
brew install ag
brew install imagemagick
brew install gnupg
brew install pinentry-mac
brew install --cask iglance
brew install fzf
brew install ripgrep
brew install fd

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/common.sh)" || exit
