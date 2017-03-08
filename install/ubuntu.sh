#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Ubuntu version

# before running ensure that there is a valid ssh key authorized for github

# Install common components

bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/master/install/common.sh)"

# Ubuntu Specific post install

sudo apt-get install --yes nodejs npm cmake tmux
sudo ln -s /usr/bin/nodejs /usr/bin/node


