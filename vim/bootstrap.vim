" Determines if this is the first time vimrc has been loaded and if so
" installs some dependencies.
" NOTE: Things will fail if missing:
" - homebrew
" - npm/node
" - python

fun! FirstRunOnEnter()
    PluginInstall
    source $MYVIMRC
    let oldpath = getcwd()
    execute "cd " . $HOME . "/.vim/bundle/YouCompleteMe"
    if s:uname == "Darwin"
      silent !xcode-select --install
      silent !brew install cmake
    else
      " assuming ubuntu/debian
      silent !sudo apt-get install cmake build-essential python-dev python3-dev
    endif
    silent !./install.py --go-completer --js-completer
    execute "cd " . oldpath
endf

let vdir = $HOME . '/.vim/bundle/vundle'

if !isdirectory(vdir)
    call system('mkdir -p ' . vdir)
    call system('git clone https://github.com/gmarik/Vundle.vim.git ' . vdir)
    autocmd VimEnter * :call FirstRunOnEnter()
endif
