" Determines if this is the first time vimrc has been loaded and if so
" sets up vundle and installs plugins.

fun! FirstRunOnEnter()
    PluginInstall
    source $MYVIMRC
endf

let vdir = $HOME . '/.vim/bundle/vundle'

if !isdirectory(vdir)
    call system('mkdir -p ' . vdir)
    call system('git clone https://github.com/gmarik/Vundle.vim.git ' . vdir)
    autocmd VimEnter * :call FirstRunOnEnter()
endif
