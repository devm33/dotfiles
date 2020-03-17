if &compatible
  set nocompatible
end

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Let Vundle manage Vundle
Bundle "gmarik/vundle"

" General
Bundle "editorconfig/editorconfig-vim"
Bundle "flazz/vim-colorschemes"
Bundle "jeffkreeftmeijer/vim-numbertoggle"
Bundle "scrooloose/nerdtree"
Bundle "tpope/vim-surround"

filetype plugin indent on
