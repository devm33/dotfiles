# oh-my-zsh config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="" # using zsh/prompt instead
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
if [[ "$(uname -s)" == Darwin ]]; then
    plugins=(git vagrant npm node pip django bundler docker)
else
    plugins=(git vagrant debian npm node pip django bundler docker)
fi
source $ZSH/oh-my-zsh.sh

# prompt config
source $HOME/.zsh/prompt

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

# "cross-os" support
if [[ "$(uname -s)" == Darwin ]]; then
    alias xdg-open=open
fi

# use gsort on macos if available
if command -v gsort >/dev/null 2>&1 ; then
    alias sort=gsort
fi

# tmux unsets this and then xclip gets confused
if [ -n "$DISPLAY" ]; then
    export DISPLAY=:0
fi

# Go for it, it's the 60's! (disable ctrl-s freeze)
stty -ixon

# added by travis gem
[ -f /Users/devrajm/.travis/travis.sh ] && source /Users/devrajm/.travis/travis.sh

