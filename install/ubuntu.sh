#!/bin/bash

# Script to download, setup, and install deps for dotfiles
# Ubuntu version
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
    ln -s .dotfiles/host-work/rcrc .rcrc
else
    ln -s .dotfiles/host-personal/rcrc .rcrc
fi
rcup -v


sudo apt-get install --yes nodejs npm cmake
sudo ln -s /usr/bin/nodejs /usr/bin/node


