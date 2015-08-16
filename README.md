# Repo for dotfiles

Managed using [thoughtbot/rcm](https://github.com/thoughtbot/rcm)

- run `lsrc` to see which files will be installed
- run `rcup -v` to link files from `.dotfiles` repo

## Detailed Installation

- Clone repo to expected location

  ```
  git clone git@github.com:devm33/dotfiles.git .dotfiles
  ```
  
- Also need to clone dependency [OhMyZsh](https://github.com/robbyrussell/oh-my-zsh) to expected location

  ```
  git clone git@github.com:robbyrussell/oh-my-zsh.git .oh-my-zsh
  ```

- Quick install for rcm (requires sha256, tar, make, should work anywhere though)

  ```
  curl -LO https://thoughtbot.github.io/rcm/dist/rcm-1.2.3.tar.gz && \
  sha=$(sha256 rcm-1.2.3.tar.gz | cut -f1 -d' ') && \
  [ "$sha" = "502fd44e567ed0cfd00fb89ccc257dac8d6eb5d003f121299b5294c01665973f" ] && \
  tar -xvf rcm-1.2.3.tar.gz && \
  cd rcm-1.2.3 && \
  ./configure && \
  make && \
  sudo make install
  ```
  Warning: version numbers may get out of date see here for latest https://github.com/thoughtbot/rcm#installation
  Note: can also be installed through brew formula

- run `rcup -v` from $HOME


### Vim Specific Post-Install

Dependencies:

- expects node/npm to be install
- vim needs to be >7.4 (use brew on mac)
- TODO
