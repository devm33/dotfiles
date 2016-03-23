# oh-my-zsh config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="" # using zsh/prompt instead
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(git vagrant debian npm node pip django bundler brew)
source $ZSH/oh-my-zsh.sh

# prompt config
source $HOME/.zsh/prompt

# TODO path entries are not idempotent, maybe should move to zshenv
# ensure /usr/local/bin on $PATH
export PATH="/usr/local/bin:$PATH"

# for mac I sometimes store homebrew packages here
if [ -d "$HOME/homebrew/bin" ]; then
    export PATH="$HOME/homebrew/bin:$PATH"
fi

# prepend my bin to path so it's checked first because I'm important
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

# gems on path
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$HOME/.gem"
if [ -d "$HOME/.gem/ruby/1.8/bin" ]; then
    export PATH="$PATH:$HOME/.gem/ruby/1.8/bin"
fi
if [ -d "$HOME/.gem/bin" ]; then
    export PATH="$PATH:$HOME/.gem/bin"
fi

# android sdk
if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
fi

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Use bash completion scripts
autoload -U bashcompinit && bashcompinit
autoload -U compinit && compinit

# Configure color term
export TERM="xterm-256color"

# Save a ton of history
HISTSIZE=20000
HISTFILE=$HOME/.zsh_history
SAVEHIST=20000

# include aliases file
if [ -f $HOME/.zsh/aliases ]; then
    source $HOME/.zsh/aliases;
fi

# include work stuff
if [ -f $HOME/.zsh/work ]; then
    source $HOME/.zsh/work
fi

# if on cygwin include crutches
if [[  "$(uname -s)" == CYGWIN* ]]; then
    if [ -f $HOME/.zsh/cygwin ]; then
        source $HOME/.zsh/cygwin;
    fi
fi

# tmux unsets this and then xclip gets confused
if [ -n "$DISPLAY" ]; then
    export DISPLAY=:0
fi

# golang needs this
if [ -d "$HOME/Code/gocode" ]; then
  export GOPATH="$HOME/Code/gocode"
  export GOBIN="$GOPATH/bin"
  export PATH="$PATH:$GOBIN"
fi

# Go for it, it's the 60's! (disable ctrl-s freeze)
stty -ixon
