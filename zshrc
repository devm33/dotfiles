# oh-my-zsh config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="" # using zsh/prompt instead
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
if [[ "$(uname -s)" == Darwin ]]; then
    plugins=(git npm node docker)
else
    plugins=(git vagrant debian npm node pip bundler docker)
fi
source $ZSH/oh-my-zsh.sh

# prompt config
source $HOME/.zsh/prompt

# Use bash completion scripts
autoload -U bashcompinit && bashcompinit
autoload -U compinit && compinit

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

# fzf
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# rbenv
#eval "$(rbenv init - zsh)"

# ngrok
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# vscode
export VSCODE_VERBOSE_LOGGING="true"
