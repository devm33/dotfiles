set nocompatible " vi improved

set mouse=a

" install vundle if it's not loaded
let vdir = $HOME . '/.vim/bundle/vundle'
if !isdirectory(vdir)
    call system('mkdir -p ' . vdir)
    call system('git clone https://github.com/gmarik/Vundle.vim.git ' . vdir)
    autocmd VimEnter * PluginInstall
endif

" include vundle config
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on


" MAPPINGS

nnoremap ; :
command! Q q " Bind :Q to :q

let mapleader=" "

" White space
nnoremap <leader>t :%s/\s\+$//<CR>
nnoremap <leader><tab> :retab<CR>

" Window mgmt
nnoremap <leader>v :vs<CR>
nnoremap <leader>h :sp<CR>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" File nav
nnoremap <leader>k :e .<CR>
nnoremap <leader>l :e %:p:h<CR>
nnoremap <leader>o :e **/*
nnoremap <leader>O :tabe **/*

" Quickly edit/reload the vimrc file
nnoremap <leader>ev :tabe $MYVIMRC<CR>
nnoremap <leader>sv :so $MYVIMRC<CR>

inoremap jk <esc>

inoremap <C-z> <esc>:w<CR>
inoremap <C-c> <esc>:x<CR>

nnoremap <C-c> :x<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader><esc> :qall<CR>

" Function key functions
nnoremap <F3> :set hlsearch!<CR>
nnoremap <F10> :set nonumber!<CR>
set pastetoggle=<F12>

" File writing
set nobackup
set nowritebackup
set noswapfile
set nofoldenable

" Display
syntax on
set number
set showcmd " show incomplete commands at bottom right
set showmatch
set ruler

" Color
if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

colorscheme desertedocean
highlight OverLength ctermbg=darkgray guibg=#F9D9D9
autocmd BufWinEnter * match OverLength /\%81v.\+/

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


" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" View trailing white space
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
