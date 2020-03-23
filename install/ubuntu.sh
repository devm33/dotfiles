#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Ubuntu version

# before running ensure that there is a valid ssh key authorized for github

# Ubuntu/Debian Specific install
sudo apt-get install --yes cmake tmux silversearcher-ag nodejs npm
sudo npm i -g npm

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/master/install/common.sh)" || exit
