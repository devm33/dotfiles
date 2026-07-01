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
        zsh tmux fzf ripgrep silversearcher-ag \
        build-essential curl ca-certificates \
        libevent-dev libncurses-dev bison pkg-config || true
fi

# 2b. Install a recent Neovim. Codespaces' apt neovim is too old (< 0.8) for
#     lazy.nvim, so grab the official prebuilt binary and drop it in
#     /usr/local (ahead of apt's /usr/bin on PATH). Best effort and idempotent:
#     skip if already on the target version, fall back to a pinned version if
#     the GitHub API is unreachable.
NVIM_FALLBACK='v0.11.2'
install_nvim() {
    local want arch asset tmp
    want="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
    [ -n "$want" ] || want="$NVIM_FALLBACK"

    if command -v nvim >/dev/null 2>&1 && [ "$(nvim --version | sed -n '1s/^NVIM //p')" = "$want" ]; then
        log "Neovim $want already installed"
        return 0
    fi

    case "$(uname -m)" in
        x86_64|amd64) arch='x86_64' ;;
        aarch64|arm64) arch='arm64' ;;
        *) log "Unsupported arch $(uname -m) for prebuilt Neovim; keeping system nvim"; return 1 ;;
    esac
    asset="nvim-linux-$arch.tar.gz"

    log "Installing Neovim $want ($asset)"
    tmp="$(mktemp -d)"
    (
        cd "$tmp"
        # Newer releases ship nvim-linux-<arch>.tar.gz; older ones only
        # nvim-linux64.tar.gz. Try the arch-specific name first, then fall back.
        if ! curl -fsSLO "https://github.com/neovim/neovim/releases/download/$want/$asset"; then
            asset='nvim-linux64.tar.gz'
            curl -fsSLO "https://github.com/neovim/neovim/releases/download/$want/$asset"
        fi
        tar -xf "$asset"
        local dir="${asset%.tar.gz}"
        maybe_sudo cp -a "$dir/bin/." /usr/local/bin/
        maybe_sudo cp -a "$dir/lib/." /usr/local/lib/ 2>/dev/null || true
        maybe_sudo cp -a "$dir/share/." /usr/local/share/
    )
    rm -rf "$tmp"
}
install_nvim || log "Neovim install failed; keeping system nvim"

# 3. Build the latest stable tmux from source. Codespaces ship an old tmux
#    (Debian's 3.3a) whose format parser mis-renders the status line (commas in
#    `#[fg=cyan,bold]` inside conditionals leak as literal "bold]"), so replace
#    it with the current release. Best effort and idempotent: skip if already on
#    the target version, and fall back to a pinned version if the API is
#    unreachable. make install lands tmux in /usr/local/bin, ahead of apt's.
TMUX_FALLBACK='3.7'
build_tmux() {
    local want tmp
    want="$(curl -fsSL https://api.github.com/repos/tmux/tmux/releases/latest 2>/dev/null \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
    [ -n "$want" ] || want="$TMUX_FALLBACK"

    if command -v tmux >/dev/null 2>&1 && [ "$(tmux -V | sed 's/^tmux //')" = "$want" ]; then
        log "tmux $want already installed"
        return 0
    fi

    log "Building tmux $want from source"
    tmp="$(mktemp -d)"
    (
        cd "$tmp"
        curl -fsSLO "https://github.com/tmux/tmux/releases/download/$want/tmux-$want.tar.gz"
        tar -xf "tmux-$want.tar.gz"
        cd "tmux-$want"
        ./configure
        make
        maybe_sudo make install
    )
    rm -rf "$tmp"
}
build_tmux || log "tmux build failed; keeping system tmux"

# 4. oh-my-zsh (zshrc sources $HOME/.oh-my-zsh).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Cloning oh-my-zsh"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    log "oh-my-zsh already present"
fi

# 5. rcm (provides rcup, used to symlink the dotfiles).
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
        # Some base images set a default ACL on /usr/local that strips the
        # traverse bit for "other", so root's `make install` can leave
        # /usr/local/share/rcm without o+x. rcup runs as the non-root user and
        # then can't read rcm.sh ("Permission denied", exit 127), aborting the
        # whole install. Normalize perms so any user can read/traverse rcm.
        maybe_sudo chmod -R a+rX /usr/local/share/rcm 2>/dev/null || true
    )
    rm -rf "$tmp"
else
    log "rcm already installed"
fi

# 6. Link the codespace rcrc and run rcup. The codespace host deliberately omits
#    a gitconfig so Codespaces keeps managing git identity and commit signing.
log "Linking ~/.rcrc -> host-codespace/rcrc"
ln -sfn "$HOME/.dotfiles/host-codespace/rcrc" "$HOME/.rcrc"

log "Running rcup"
rcup -v -f

# 7. Make zsh the default shell when possible (non-fatal).
if command -v zsh >/dev/null 2>&1; then
    zsh_path="$(command -v zsh)"
    if [ "${SHELL:-}" != "$zsh_path" ]; then
        log "Setting default shell to zsh"
        maybe_sudo chsh -s "$zsh_path" "$(id -un)" || \
            log "Could not change default shell automatically; run: chsh -s $zsh_path"
    fi
fi

log "Dotfiles install complete"
