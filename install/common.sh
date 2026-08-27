#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Common components

cd "$HOME" || exit 1


if [ -z "$installreadonly" ]; then
    repo='git@github.com:devm33/dotfiles.git'
else 
    repo='https://github.com/devm33/dotfiles.git'
fi

if [ -d "$HOME/.dotfiles/.git" ]; then
    echo "updating existing config repo"
    git -C "$HOME/.dotfiles" pull --ff-only || {
        echo "failed to update $HOME/.dotfiles" >&2
        exit 1
    }
elif [ -e "$HOME/.dotfiles" ]; then
    echo "$HOME/.dotfiles already exists but is not a git repository" >&2
    exit 1
elif git clone "$repo" "$HOME/.dotfiles"; then
    echo "successfully cloned config repo"
else
    cat <<-'EOF'
        Failed to clone config repo!
        Make sure you have a ssh key authorized on github
        Or run again after running:

        export installreadonly=1

        For a readonly install (no commit access to repo)
EOF
    exit 1
fi

if [ ! -d "$HOME/.oh-my-zsh/.git" ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
fi

# Note: version here will become stale!
RCMV='1.3.4'
if ! command -v rcup >/dev/null 2>&1; then
    curl -LO https://thoughtbot.github.io/rcm/dist/rcm-$RCMV.tar.gz && \
    tar -xvf rcm-$RCMV.tar.gz && \
    cd rcm-$RCMV && \
    ./configure && \
    make && \
    sudo make install
fi

cd "$HOME" || exit 1

host="${DOTFILES_HOST:-}"
if [ -z "$host" ] && [ -L "$HOME/.rcrc" ]; then
    host="$(readlink "$HOME/.rcrc" | sed -n 's|.*host-\([^/]*\)/rcrc$|\1|p')"
fi

if [ -z "$host" ]; then
    { for f in .dotfiles/host-*; do echo "$f"; done; } | cut -d- -f2
    echo -n 'Select the hostname to use (defaults to personal): '
    read -r host
fi

if [ ! -d ".dotfiles/host-$host" ]; then
    host='personal'
fi
ln -sfn ".dotfiles/host-$host/rcrc" .rcrc
rcup -v -f
