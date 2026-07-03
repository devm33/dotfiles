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

# Make world-writable dirs (drwxrwxrwx, common in Codespaces) legible. oh-my-zsh
# / dircolors highlight them with a background color -- ow (other-writable) on
# yellow, tw (+sticky) on green -- which is unreadable on dark themes. Append
# overrides after oh-my-zsh so they win, rendering them like normal dirs.
export LS_COLORS="${LS_COLORS:+$LS_COLORS:}ow=1;36:tw=1;36"
export LSCOLORS="GxfxcxdxbxegedabagGxGx" # BSD/macOS ls: render ow/tw like normal dirs

# override oh-my-zsh git plugin aliases that conflict with our functions
unalias gcam gcpc gpr grh grhh 2>/dev/null
alias gcam=git_commit_all_message
alias gcpc=git_copy_commit
alias gpr='git remote prune origin'
alias grh=git_reset_head
alias grhh=git_reset_head_hard

# prompt config
source $HOME/.zsh/prompt

# Use bash completion scripts
autoload -U bashcompinit && bashcompinit
autoload -U compinit && compinit

# aliases were sourced from .zshenv (before compinit), so their compdef calls
# hit the no-op stub. Re-source now that the real compdef is available so
# completions like `wt` get registered.
if [ -f $HOME/.zsh/aliases ]; then
    source $HOME/.zsh/aliases
fi

# Completions for the worktree / code-review commands. Sourced after compinit
# so the real compdef is available (the commands live in bin/ scripts or as
# functions in zsh/aliases).
if [ -f $HOME/.zsh/completions ]; then
    source $HOME/.zsh/completions
fi

# Save a ton of history
HISTSIZE=20000
HISTFILE=$HOME/.zsh_history
SAVEHIST=20000

# aliases sourced in .zshenv for availability in non-interactive shells

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # This loads nvm without auto-using
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# rbenv
#eval "$(rbenv init - zsh)"

# ngrok
# if command -v ngrok &>/dev/null; then
#     eval "$(ngrok completion)"
# fi


export PATH="/home/devraj/.local/bin:$PATH"

# vscode
export VSCODE_VERBOSE_LOGGING="true"

