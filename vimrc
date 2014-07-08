set nocompatible " vi improved

set mouse=a

" install vundle if it's not loaded
if !exists('vundle')
    let vdir = '~/.vim/bundle/vundle'
    call system('mkdir -p ' . vdir)
    call system('git clone https://github.com/gmarik/Vundle.vim.git ' . vdir)
endif

" include vundle config
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

" MAPPINGS

let mapleader=" "

nnoremap <leader>k :Vexplore<CR>
nnoremap <leader>l :e .<CR>
nnoremap <leader>t :%s/\s\+$//<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Trying to quickly open file
nnoremap <leader>o :e **/

" Quickly edit/reload the vimrc file
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>sv :so $MYVIMRC<CR>

inoremap jk <esc>
inoremap qq <esc>:q<CR>
inoremap ww <esc>:w<CR>
inoremap xx <esc>:x<CR>
inoremap <C-c> <esc>:x<CR>
nnoremap <C-c> :x<CR>

nnoremap ; :

command! Q q " Bind :Q to :q

nnoremap <F10> :set nonumber!<CR>
set pastetoggle=<F12>

" File writing
set nobackup
set nowritebackup
set noswapfile
set nofoldenable

" DISPLAY

syntax on
set number
set showcmd " show incomplete commands at bottom right
set showmatch
set ruler


" Color
colorscheme desertedocean


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
