
" Auto-install plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug "flazz/vim-colorschemes"
Plug "jeffkreeftmeijer/vim-numbertoggle"
Plug "tpope/vim-surround"
"Plug "vim-syntastic/syntastic"
"Plug "HerringtonDarkholme/yats.vim"
call plug#end()
