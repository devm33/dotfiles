# oh-my-zsh config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="bureau"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git vagrant jira git-extras yum node npm pip django)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="$HOME/bin/:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

# work stuff
if [ -f $HOME/.zsh.work ]; then
    source $HOME/.zsh.work
fi

# Save a ton of history
HISTSIZE=20000
HISTFILE=$HOME/.zsh_history
SAVEHIST=20000

# include aliases file
if [ -f $HOME/.zsh.aliases ]; then
    source $HOME/.zsh.aliases;
fi

# if on cygwin include crutches
if [[  "$(uname -s)" == CYGWIN* ]]; then
    if [ -f $HOME/.zsh.cygwin ]; then
        source $HOME/.zsh.cygwin;
    fi
fi

# Configure color term
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi

