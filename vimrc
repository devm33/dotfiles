set nocompatible " vi improved

set mouse=a

" include vundle config
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

" MAPPINGS

let mapleader=" "

map <leader>k :E<CR>

inoremap jk <esc>
inoremap <C-z> <esc>:w<CR>
inoremap <C-x> <esc>:x<CR>
nnoremap <C-z> :w<CR>
nnoremap <C-x> :x<CR>
command! Q q " Bind :Q to :q

nnoremap <F11> :set nonumber!<CR>
set pastetoggle=<F12>

" File writing
set nobackup
set nowritebackup
set noswapfile
set nofoldenable

" DISPLAY

syntax on
set ruler
set number
set colorcolumn=80

" Color
" not working? colorscheme monokai
highlight ColorColumn ctermbg=235 guibg=#2c2d27


" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
set wildmenu
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>

" WINDOWS

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" WHITE SPACE

set list listchars=tab:»·,trail:· " show trailing

" Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set shiftround
set softtabstop=4

" MISC

set backspace=2 " help cygwin out with backspace
