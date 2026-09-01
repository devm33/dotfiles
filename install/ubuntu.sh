#!/bin/bash

set -euo pipefail

# Script to download, setup, and install deps for dotfiles
# Ubuntu version

# before running ensure that there is a valid ssh key authorized for github

# Ubuntu/Debian Specific install
sudo dpkg --configure -a || sudo apt-get install --fix-broken --yes
sudo dpkg --configure -a
sudo apt-get install --yes cmake tmux silversearcher-ag nodejs npm neovim fzf ripgrep pkg-config libssl-dev unzip jq locales zsh
sudo sed -i -E 's/^# *en_US\.UTF-8 +UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
if ! grep -Eq '^en_US\.UTF-8[[:space:]]+UTF-8' /etc/locale.gen; then
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen >/dev/null
fi
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8

# NVM-managed global packages are user-owned; an npm prefix override conflicts
# with NVM and may have been left by an older version of this installer.
if [ -f "$HOME/.npmrc" ]; then
    sed -i -E '/^[[:space:]]*(prefix|globalconfig)[[:space:]]*=/d' "$HOME/.npmrc"
fi

NVM_VERSION='v0.40.7'
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" |
        PROFILE=/dev/null bash
fi

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"
nvm install 24
nvm alias default 24
nvm use --delete-prefix default --silent
if ! command -v pnpm >/dev/null 2>&1; then
    npm install --global pnpm
fi

# Install Rust and Cargo
if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# Install the Rust compiler cache without requiring it to already exist
if ! command -v sccache >/dev/null 2>&1; then
    RUSTC_WRAPPER='' cargo install sccache --locked
fi

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/common.sh)" || exit

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$current_shell" != "$zsh_path" ]; then
    sudo chsh -s "$zsh_path" "$USER"
fi
