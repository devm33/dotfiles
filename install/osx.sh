#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# OSX version
# v0 - totally untested

# before running ensure that there is a valid ssh key authorized for github

cd $HOME

git clone git@github.com:devm33/dotfiles.git .dotfiles

git clone git@github.com:robbyrussell/oh-my-zsh.git .oh-my-zsh

# Note: version encoded here will become stale!
curl -LO https://thoughtbot.github.io/rcm/dist/rcm-1.2.3.tar.gz && \
tar -xvf rcm-1.2.3.tar.gz && \
cd rcm-1.2.3 && \
./configure && \
make && \
sudo make install

cd $HOME
echo -n 'Enter w to use hostname work instead of default'
read host
if [ "$host" == "w" ]; then
    echo -n 'Enter m for gmac otherwise using goobuntu'
    read os
    if [ "$os" == "m" ]; then
        ln -s .dotfiles/host-gmac/rcrc .rcrc
    else
        ln -s .dotfiles/host-work/rcrc .rcrc
    fi
else
    ln -s .dotfiles/host-personal/rcrc .rcrc
fi
rcup -v

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install node
brew install cmake
