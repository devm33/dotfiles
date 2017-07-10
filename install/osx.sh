#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# OSX version

# before running ensure that there is a valid ssh key authorized for github

# ensure dev tools setup
sudo xcodebuild -license

# Install common components

bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/master/install/common.sh)" || exit

# OSX Specific post install

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install node
brew install cmake
brew install ffmpeg
brew install vim
brew install tmux
