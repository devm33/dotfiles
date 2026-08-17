#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Ubuntu version

# before running ensure that there is a valid ssh key authorized for github

# Ubuntu/Debian Specific install
sudo apt-get install --yes cmake tmux silversearcher-ag nodejs npm neovim fzf ripgrep unzip
sudo npm i -g npm

# Install Rust and Cargo
if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/common.sh)" || exit
