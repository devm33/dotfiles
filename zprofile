export TERM=xterm-256color
export CARGO_INCREMENTAL=0
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi
export COPILOT_DISABLE_KEYTAR=1
