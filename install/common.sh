#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Common components

cd $HOME

if git clone git@github.com:devm33/dotfiles.git .dotfiles ; then
    echo "succesfully cloned config repo"
else
    echo "failed to clone config repo, make sure you have a ssh key authorized on github"
    exit 1
fi

git clone git@github.com:robbyrussell/oh-my-zsh.git .oh-my-zsh

# Note: version here will become stale!
RCMV='1.3.0'
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
