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

# Go for it, it's the 60's! (disable ctrl-s freeze)
stty -ixon
