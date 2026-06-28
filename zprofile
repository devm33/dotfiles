export TERM=xterm-256color
export CARGO_INCREMENTAL=0
# Only use sccache when it's actually installed; otherwise cargo fails with
# "RUSTC_WRAPPER=sccache" not found (e.g. in codespaces where it isn't set up).
if command -v sccache >/dev/null 2>&1; then
  export RUSTC_WRAPPER=sccache
  export SCCACHE_CACHE_SIZE=20G
fi
