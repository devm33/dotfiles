#vim:ft=bash
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi

export PATH="$HOME/bin:$PATH"

if [ -d $HOME/lib/node-v4.2.1-linux-x86/bin ]; then
    export PATH="$HOME/lib/node-v4.2.1-linux-x86/bin:$PATH"
fi

if [[ `uname` ==  'Linux' ]]
then
    export SSLKEYLOGFILE='/usr/local/google/home/devrajm/.sslkey.log'

    export STUDIO_VM_OPTIONS='/usr/local/google/home/devrajm/.studio64.vmoptions'
fi

export IBUS_ENABLE_SYNC_MODE=1
. "$HOME/.cargo/env"

export CARGO_INCREMENTAL=0
# Only use sccache when it's actually installed; otherwise cargo fails because
# RUSTC_WRAPPER points at a missing binary (e.g. in codespaces).
if command -v sccache >/dev/null 2>&1; then
  export RUSTC_WRAPPER=sccache
  export SCCACHE_CACHE_SIZE=20G
fi
