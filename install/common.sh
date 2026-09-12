#!/bin/bash

set -euo pipefail

# Script to download, setup, and install deps for dotfiles
# Common components

cd "$HOME" || exit 1

log() {
    printf '\n==> %s\n' "$*"
}

install_latest_gh() {
    local os arch tag version asset tmp expected actual install_dir

    os="$(uname -s)"
    if [ "$os" = 'Darwin' ] && command -v brew >/dev/null 2>&1; then
        log 'Installing the latest GitHub CLI'
        brew update
        if brew list --versions gh >/dev/null 2>&1; then
            brew upgrade gh
        else
            brew install gh
        fi
        return
    fi

    if [ "$os" != 'Linux' ]; then
        echo "Unsupported operating system for GitHub CLI install: $os" >&2
        exit 1
    fi

    case "$(uname -m)" in
        x86_64 | amd64) arch='amd64' ;;
        aarch64 | arm64) arch='arm64' ;;
        *)
            echo "Unsupported architecture for GitHub CLI: $(uname -m)" >&2
            exit 1
            ;;
    esac

    tag="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest |
        sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)"
    if [ -z "$tag" ]; then
        echo 'Unable to determine the latest GitHub CLI release' >&2
        exit 1
    fi
    version="${tag#v}"

    if command -v gh >/dev/null 2>&1 &&
        [ "$(gh --version | awk 'NR == 1 {print $3}')" = "$version" ]; then
        log "GitHub CLI $version already installed"
        return
    fi

    asset="gh_${version}_linux_${arch}.tar.gz"
    tmp="$(mktemp -d)"
    trap 'rm -rf -- "$tmp"' RETURN

    log "Installing GitHub CLI $version"
    curl -fsSLo "$tmp/$asset" "https://github.com/cli/cli/releases/download/$tag/$asset"
    curl -fsSLo "$tmp/gh_checksums.txt" "https://github.com/cli/cli/releases/download/$tag/gh_${version}_checksums.txt"
    expected="$(awk -v asset="$asset" '$2 == asset {print $1}' "$tmp/gh_checksums.txt")"
    actual="$(sha256sum "$tmp/$asset" | awk '{print $1}')"
    if [ -z "$expected" ] || [ "$actual" != "$expected" ]; then
        echo "Checksum verification failed for $asset" >&2
        exit 1
    fi

    tar -C "$tmp" -xf "$tmp/$asset"
    if [ -w /usr/local/bin ]; then
        install_dir='/usr/local/bin'
        install -m 0755 "$tmp/gh_${version}_linux_${arch}/bin/gh" "$install_dir/gh"
    elif command -v sudo >/dev/null 2>&1; then
        install_dir='/usr/local/bin'
        sudo install -m 0755 "$tmp/gh_${version}_linux_${arch}/bin/gh" "$install_dir/gh"
    else
        install_dir="$HOME/.local/bin"
        mkdir -p "$install_dir"
        install -m 0755 "$tmp/gh_${version}_linux_${arch}/bin/gh" "$install_dir/gh"
        export PATH="$install_dir:$PATH"
    fi

    rm -rf -- "$tmp"
    trap - RETURN
}

ensure_github_auth() {
    local scopes='write:public_key,write:ssh_signing_key'
    local active_scopes

    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        log 'Authenticate GitHub CLI'
        gh auth login --hostname github.com --git-protocol ssh --web \
            --skip-ssh-key --scopes "$scopes"
    fi

    active_scopes="$(gh auth status --hostname github.com --json hosts \
        --jq '.hosts["github.com"][] | select(.active).scopes' |
        tr -d ' ')"
    if ! printf ',%s,' "$active_scopes" |
        grep -Eq ',(write|admin):public_key,' ||
        ! printf ',%s,' "$active_scopes" |
            grep -Eq ',(write|admin):ssh_signing_key,'; then
        if [ -n "${GH_TOKEN:-}${GITHUB_TOKEN:-}" ]; then
            echo 'GH_TOKEN/GITHUB_TOKEN needs write:public_key and write:ssh_signing_key permissions' >&2
            exit 1
        fi
        log 'Authorize GitHub CLI to manage SSH authentication and signing keys'
        gh auth refresh --hostname github.com --scopes "$scopes"
    fi

    gh config set git_protocol ssh --host github.com
    gh auth setup-git --hostname github.com
}

ensure_github_ssh_keys() {
    local key_file="$HOME/.ssh/id_ed25519"
    local public_key="$key_file.pub"
    local key_blob box_hostname github_login

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [ ! -f "$key_file" ]; then
        github_login="$(gh api user --jq .login)"
        box_hostname="$(hostname -s)"
        log "Generating SSH key for $box_hostname"
        ssh-keygen -q -t ed25519 -N '' -C "$github_login@$box_hostname" -f "$key_file"
    elif [ ! -f "$public_key" ]; then
        ssh-keygen -y -f "$key_file" >"$public_key"
    fi
    chmod 600 "$key_file"
    chmod 644 "$public_key"

    key_blob="$(awk 'NR == 1 {print $2}' "$public_key")"
    box_hostname="$(hostname -s)"

    if ! gh api --paginate user/keys --jq '.[].key' |
        awk '{print NF == 1 ? $1 : $2}' | grep -Fxq "$key_blob"; then
        log "Adding $box_hostname as a GitHub SSH authentication key"
        gh ssh-key add "$public_key" --title "$box_hostname" --type authentication
    else
        log 'SSH authentication key already registered with GitHub'
    fi

    if ! gh api --paginate user/ssh_signing_keys --jq '.[].key' |
        awk '{print NF == 1 ? $1 : $2}' | grep -Fxq "$key_blob"; then
        log "Adding $box_hostname as a GitHub SSH signing key"
        gh ssh-key add "$public_key" --title "$box_hostname" --type signing
    else
        log 'SSH signing key already registered with GitHub'
    fi
}

ensure_github_org_ssh_access() {
    local output sso_url

    if output="$(GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new' \
        git ls-remote git@github.com:github/copilot-agent-runtime.git HEAD 2>&1)"; then
        log 'SSH key is authorized for the github organization'
        return
    fi

    sso_url="$(printf '%s\n' "$output" |
        sed -n 's|.*\(https://github\.com/orgs/github/sso[^[:space:]]*\).*|\1|p' |
        head -n1)"
    if [ -z "$sso_url" ]; then
        printf '%s\n' "$output" >&2
        echo 'Unable to verify SSH access to the github organization' >&2
        exit 1
    fi

    cat >&2 <<EOF
GitHub requires browser confirmation to authorize this SSH key for the github
organization. Open this URL:

    $sso_url
EOF
    if [ ! -t 0 ]; then
        echo 'Re-run the installer interactively after authorizing the key.' >&2
        exit 1
    fi

    printf 'Press Enter after authorizing the key... ' >&2
    read -r _
    if ! GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=yes' \
        git ls-remote git@github.com:github/copilot-agent-runtime.git HEAD >/dev/null; then
        echo 'SSH key is still not authorized for the github organization' >&2
        exit 1
    fi
}

install_latest_gh


if [ -z "${installreadonly:-}" ]; then
    repo='git@github.com:devm33/dotfiles.git'
    ensure_github_auth
    ensure_github_ssh_keys
else 
    repo='https://github.com/devm33/dotfiles.git'
fi

if [ -d "$HOME/.dotfiles/.git" ]; then
    echo "resetting existing config repo to its upstream"
    git -C "$HOME/.dotfiles" fetch --prune
    git -C "$HOME/.dotfiles" reset --hard '@{upstream}'
    git -C "$HOME/.dotfiles" clean -fd
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

if [ "$host" = 'github' ]; then
    ensure_github_org_ssh_access
    mkdir -p "$HOME/code"
    if [ -d "$HOME/code/dotfiles-work/.git" ]; then
        echo "$HOME/code/dotfiles-work already cloned"
    elif [ -e "$HOME/code/dotfiles-work" ]; then
        echo "$HOME/code/dotfiles-work already exists but is not a git repository" >&2
        exit 1
    else
        gh repo clone devm33/dotfiles-work "$HOME/code/dotfiles-work"
    fi
fi

ln -sfn ".dotfiles/host-$host/rcrc" .rcrc
rcup -v -f
