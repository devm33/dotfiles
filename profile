if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi

export PATH="$HOME/bin:$PATH"

export SSLKEYLOGFILE='/usr/local/google/home/devrajm/.sslkey.log'
