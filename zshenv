# Note path entries are not idempotent (TODO what did I mean by this?)
# Setting PATH and other vars in zshenv to ensure consistent in all environs

export PATH="/usr/local/bin:$PATH"

# for mac I sometimes store homebrew packages here
if [ -d "$HOME/homebrew/bin" ]; then
    export PATH="$HOME/homebrew/bin:$PATH"
    export LD_LIBRARY_PATH=$HOME/homebrew/lib:$LD_LIBRARY_PATH
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

# pip3 install location on mac
[ -d $HOME/Library/Python/3.6/bin ] && export PATH="$PATH:$HOME/Library/Python/3.6/bin"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'

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

# Add dart sdk bin
if [ -d /usr/local/opt/dart/libexec ]; then
  export PATH="$PATH:/usr/local/opt/dart/libexec"
fi

