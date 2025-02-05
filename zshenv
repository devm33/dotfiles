# Note path entries are not idempotent (TODO what did I mean by this?)
# Setting PATH and other vars in zshenv to ensure consistent in all environs

export PATH="/usr/local/bin:/usr/sbin:$PATH"

# for mac homebrew should be installed here
if [ -d "/opt/homebrew" ]; then
    export HOMEBREW_PREFIX="/opt/homebrew";
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
    export HOMEBREW_REPOSITORY="/opt/homebrew";
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
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

# homebrew python3 symlinks
[ -d /opt/homebrew/opt/python@3.11/libexec/bin ] && export PATH="$PATH:/opt/homebrew/opt/python@3.11/libexec/bin"

# pip packages
[ -d $HOME/Library/Python/3.11/bin ] && export PATH="$PATH:$HOME/Library/Python/3.11/bin"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'

# golang needs this
export GOPATH="$HOME/code/gocode"
if [ -d "$HOME/Code/gocode" ]; then
  export GOPATH="$HOME/Code/gocode"
fi
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# golang goproxy
export GOPROXY='https://goproxy.githubapp.com/mod,https://proxy.golang.org/,direct'
export GOPRIVATE=''
export GONOPROXY=''
export GONOSUMDB='github.com/github/*'

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

# blaze tab completion
if [ -d /google/data ]; then
   fpath=(/google/src/files/head/depot/google3/devtools/blaze/scripts/zsh_completion $fpath)
fi

# depot_tools
export PATH="$PATH:$HOME/code/depot_tools"

# git cache
export GIT_CACHE_PATH="${HOME}/.git_cache"

# github token
export GH_COPILOT_TOKEN="" # silence some log noise
# if [ -f ~/.github_token ]; then
#   export GITHUB_TOKEN=`cat ~/.github_token`
# fi

# copilot
# export COPILOT_AGENT_VERBOSE='true'

# rust
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# node
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@18/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@18/include"

# less
export LESS="-FRX"

# ssl
# export SSLKEYLOGFILE='/private/tmp/ssl-key.log'

# local node_modules (only works from project root)
export PATH="./node_modules/.bin:$PATH"
