#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Common components

cd $HOME


if [ -z "$installreadonly" ]; then
    repo='git@github.com:devm33/dotfiles.git'
else 
    repo='https://github.com/devm33/dotfiles.git'
fi

if git clone $repo .dotfiles ; then
    echo "succesfully cloned config repo"
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

git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh

# Note: version here will become stale!
RCMV='1.3.1'
curl -LO https://thoughtbot.github.io/rcm/dist/rcm-$RCMV.tar.gz && \
tar -xvf rcm-$RCMV.tar.gz && \
cd rcm-$RCMV && \
./configure && \
make && \
sudo make install

cd $HOME

{ for f in .dotfiles/host-*; do echo $f; done } | cut -d- -f2
echo -n 'Select the hostname to use (defaults to personal): '
read host

if [ ! -d ".dotfiles/host-$host" ]; then
    host='personal'
fi
ln -s ".dotfiles/host-$host/rcrc" .rcrc
rcup -v

ln -s .vim .config/nvim
ln -s .vimrc .config/nvim/init.vim
