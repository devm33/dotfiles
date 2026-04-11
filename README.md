# Repo for dotfiles

Managed using [thoughtbot/rcm](https://github.com/thoughtbot/rcm)

## Quick Ref

-   run `lsrc` to see which files will be installed
-   run `rcup -v` to link files from `.dotfiles` repo

## Quick Install

-   Add a github authorized ssh key
-   Then run the script tailored to the environment

    -   For Ubuntu-like environments:

    ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/ubuntu.sh)"
    ```

    -   For OSX:

    ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/osx.sh)"
    ```

    -   For generic posix environment, where post-install of dependencies is
        done manually:

    ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/common.sh)"
    ```

    -  For a readonly install (no github authorized keys on the box) set this
       flag before running the install script:

    ```bash
    export installreadonly=1
    ```

## Detailed Installation

-   Clone repo to expected location

    ```
    git clone git@github.com:devm33/dotfiles.git .dotfiles
    ```

-   Also need to clone dependency [OhMyZsh]
    (https://github.com/robbyrussell/oh-my-zsh) to expected location

    ```
    git clone git@github.com:robbyrussell/oh-my-zsh.git .oh-my-zsh
    ```

-   Quick install for rcm (requires sha256, tar, make, should work anywhere
    though)

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

    Warning: version numbers may get out of date see here for latest
    https://github.com/thoughtbot/rcm#installation Note: can also be installed
    through brew formula

-   Link the right rcrc config file for the host, e.g.

    ```
    ln -s .dotfiles/host-personal/rcrc .rcrc
    ```

-   run `rcup -v` from `$HOME`

### Vim Specific Post-Install

Dependencies:

-   node
-   cmake
-   vim needs to be >7.4 (use brew on mac)

Install:

-   open vim and press enter to ignore warnings
-   the vim install script should do the rest:
    -   download and install bundles
    -   compile tern and ycm

[![ghit.me](https://ghit.me/badge.svg?repo=devm33/dotfiles)](https://ghit.me/repo/devm33/dotfiles)
