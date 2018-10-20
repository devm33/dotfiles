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

if [ -d "$HOME/code/bin" ]; then
    export PATH="$HOME/code/bin:$PATH"
fi

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
if [ -d "$HOME/lib/android/sdk" ]; then
    export ANDROID_HOME="$HOME/lib/android/sdk"
    export ANDROID_SDK_HOME="$HOME/lib/android/sdk"
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

# golang needs this
export GOPATH="$HOME/code/gocode"
if [ -d "$HOME/Code/gocode" ]; then
  export GOPATH="$HOME/Code/gocode"
fi
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# scala needs these
if [ -d '/usr/local/share/scala' ]; then
  export SCALA_HOME='/usr/local/share/scala' 
  export PATH="$PATH:$SCALA_HOME/bin"
fi

# Go for it, it's the 60's! (disable ctrl-s freeze)
stty -ixon

# Load the google cloud sdk
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/lib/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/lib/google-cloud-sdk/path.zsh.inc"
fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/lib/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/lib/google-cloud-sdk/completion.zsh.inc"
fi
# Also add the appengine go sdk to the path if found
if [ -d "$HOME/lib/go_appengine" ]; then
  export PATH="$PATH:$HOME/lib/go_appengine"
  export GOROOT="$HOME/lib/go_appengine/goroot"
fi

# added by travis gem
[ -f /Users/devrajm/.travis/travis.sh ] && source /Users/devrajm/.travis/travis.sh

# pip3 install location on mac
[ -d $HOME/Library/Python/3.6/bin ] && export PATH="$PATH:$HOME/Library/Python/3.6/bin"
