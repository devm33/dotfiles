#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# OSX version

# before running ensure that there is a valid ssh key authorized for github

# ensure dev tools setup
sudo xcodebuild -license || exit

# OSX Specific install

# Install homebrew to home dir
cd ~
mkdir homebrew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew

# Temporarily add homebrew to path for install (permant add in zshenv)
export PATH=$HOME/homebrew/bin:$PATH

brew install node
brew install cmake
brew install ffmpeg
brew install vim
brew install tmux
brew install ag
brew install reattach-to-user-namespace

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/master/install/common.sh)" || exit
