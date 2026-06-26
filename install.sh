#!/usr/bin/env bash

# Entry point used by GitHub Codespaces dotfiles personalization.
#
# When a codespace is created, GitHub clones this repo to a temporary location
# and runs the first install script it finds (install.sh is checked first). The
# repo is NOT cloned to ~/.dotfiles, so this script symlinks it there to satisfy
# rcm's DOTFILES_DIRS and the various "~/.dotfiles/..." references, installs the
# few dependencies the dotfiles expect (rcm, oh-my-zsh), then links everything.
#
# It is intentionally idempotent so it can be re-run safely.
#
# Docs: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\n==> %s\n' "$*"; }

# Run a command with sudo when available and not already root.
maybe_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
}

# 1. Make the clone available at ~/.dotfiles (where rcm/configs expect it).
if [ "$DOTFILES_DIR" != "$HOME/.dotfiles" ]; then
    if [ -e "$HOME/.dotfiles" ] && [ ! -L "$HOME/.dotfiles" ]; then
        log "$HOME/.dotfiles already exists and is not a symlink; leaving it in place"
    else
        log "Linking $DOTFILES_DIR -> $HOME/.dotfiles"
        ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
    fi
fi

# 2. Install packages the dotfiles expect. Best effort: don't abort the whole
#    setup if a package manager hiccups, the important part is linking dotfiles.
if command -v apt-get >/dev/null 2>&1; then
    log "Installing packages with apt-get"
    maybe_sudo apt-get update -y || true
    maybe_sudo apt-get install -y --no-install-recommends \
        zsh tmux fzf ripgrep silversearcher-ag neovim \
        build-essential curl ca-certificates || true
fi

# 3. oh-my-zsh (zshrc sources $HOME/.oh-my-zsh).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Cloning oh-my-zsh"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    log "oh-my-zsh already present"
fi

# 4. rcm (provides rcup, used to symlink the dotfiles).
if ! command -v rcup >/dev/null 2>&1; then
    log "Installing rcm from source"
    RCMV='1.3.4'
    tmp="$(mktemp -d)"
    (
        cd "$tmp"
        curl -fsSLO "https://thoughtbot.github.io/rcm/dist/rcm-$RCMV.tar.gz"
        tar -xf "rcm-$RCMV.tar.gz"
        cd "rcm-$RCMV"
        ./configure
        make
        maybe_sudo make install
    )
    rm -rf "$tmp"
else
    log "rcm already installed"
fi

# 5. Link the codespace rcrc and run rcup. The codespace host deliberately omits
#    a gitconfig so Codespaces keeps managing git identity and commit signing.
log "Linking ~/.rcrc -> host-codespace/rcrc"
ln -sfn "$HOME/.dotfiles/host-codespace/rcrc" "$HOME/.rcrc"

log "Running rcup"
rcup -v -f

# 6. Make zsh the default shell when possible (non-fatal).
if command -v zsh >/dev/null 2>&1; then
    zsh_path="$(command -v zsh)"
    if [ "${SHELL:-}" != "$zsh_path" ]; then
        log "Setting default shell to zsh"
        maybe_sudo chsh -s "$zsh_path" "$(id -un)" || \
            log "Could not change default shell automatically; run: chsh -s $zsh_path"
    fi
fi

log "Dotfiles install complete"
