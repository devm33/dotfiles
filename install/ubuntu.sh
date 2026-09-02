#!/bin/bash

set -euo pipefail

# Script to download, setup, and install deps for dotfiles
# Ubuntu version

# before running ensure that there is a valid ssh key authorized for github

# Ubuntu/Debian Specific install
sudo dpkg --configure -a || sudo apt-get install --fix-broken --yes
sudo dpkg --configure -a
sudo apt-get install --yes \
    build-essential \
    cmake \
    fzf \
    jq \
    libssl-dev \
    locales \
    neovim \
    nodejs \
    npm \
    pkg-config \
    python3 \
    ripgrep \
    silversearcher-ag \
    tmux \
    unzip \
    zip \
    zsh
sudo sed -i -E 's/^# *en_US\.UTF-8 +UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
if ! grep -Eq '^en_US\.UTF-8[[:space:]]+UTF-8' /etc/locale.gen; then
    echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen >/dev/null
fi
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8

# Bazelisk selects the Bazel version pinned by each repository.
if [ ! -x "$HOME/.local/bin/bazel" ]; then
    case "$(uname -m)" in
        x86_64) bazelisk_arch='amd64' ;;
        aarch64 | arm64) bazelisk_arch='arm64' ;;
        *)
            echo "Unsupported architecture for Bazelisk: $(uname -m)" >&2
            exit 1
            ;;
    esac

    bazelisk_version='v1.29.0'
    bazelisk_asset="bazelisk-linux-${bazelisk_arch}"
    bazelisk_url="https://github.com/bazelbuild/bazelisk/releases/download/${bazelisk_version}"
    bazelisk_tmp="$(mktemp)"
    bazelisk_checksum_tmp="$(mktemp)"
    trap 'rm -f -- "$bazelisk_tmp" "$bazelisk_checksum_tmp"' EXIT

    curl -fsSLo "$bazelisk_tmp" "$bazelisk_url/$bazelisk_asset"
    curl -fsSLo "$bazelisk_checksum_tmp" "$bazelisk_url/$bazelisk_asset.sha256"
    expected_checksum="$(tr -d '[:space:]' <"$bazelisk_checksum_tmp")"
    actual_checksum="$(sha256sum "$bazelisk_tmp" | awk '{print $1}')"
    if [[ ! "$expected_checksum" =~ ^[0-9a-fA-F]{64}$ ]] ||
        [ "$actual_checksum" != "$expected_checksum" ]; then
        echo "Checksum verification failed for $bazelisk_asset" >&2
        exit 1
    fi

    install -Dm0755 "$bazelisk_tmp" "$HOME/.local/bin/bazel"
    ln -sfn bazel "$HOME/.local/bin/bazelisk"
    rm -f -- "$bazelisk_tmp" "$bazelisk_checksum_tmp"
    trap - EXIT
fi

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

set +u
# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"
nvm install 24
nvm alias default 24
nvm use --delete-prefix default --silent
set -u
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

# Install common components
bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/common.sh)" || exit

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$current_shell" != "$zsh_path" ]; then
    sudo chsh -s "$zsh_path" "$USER"
fi
