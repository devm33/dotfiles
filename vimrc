set nocompatible

" Set leader to spacebar, needs to be set before any mappings
let mapleader=" "

" Load plugins
if filereadable(expand('~/.vim/plugins.vim'))
  source ~/.vim/plugins.vim
endif

" Load google-specific config on goob
if filereadable(expand('~/.vim/google.vim'))
  source ~/.vim/google.vim
endif

" Colors
set t_Co=256 " always use 256 colors
let g:solarized_termcolors=256 " im serious about this
set background=dark
colorscheme hybrid " set color scheme (depends on flazz/vim-colorschemes)

" UI Config
set number " line numbers on
set relativenumber " note using plugin jeffkreeftmeijer/vim-numbertoggle
set showcmd " show incomplete commands at bottom right
set showmatch " briefly highlight matched bracket when pair completed
set ruler " display line and col numbers in bottom right
set wildmenu " tab complete in command line
set wildmode=list:longest,list:full
set lazyredraw " save some cycles: dont redraw during macros
set list listchars=tab:»·,trail:· " show trailing whitespace and tabs
set cursorline " highlight the line we are currently on
set colorcolumn=80 " draw line at 80 cols

if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Whitespace
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab
set expandtab
set autoindent

" Windows
set splitright " Open new split panes to right
set splitbelow " and bottom, which feels more natural

" File writing
command! W w
set nowritebackup
set backupdir=/tmp//
set backupcopy=yes
set noswapfile
set autoread
set autowriteall
augroup autosave
  " autowriteall doesn't capture tab changing, write all on lost focus
  autocmd!
  autocmd BufLeave * silent! wa
  autocmd FocusLost * silent! wa
  autocmd TabLeave * silent! wa
augroup END
augroup autoread
  autocmd!
  au FocusGained,BufEnter * :checktime
augroup END

" Undo
set undofile
set undolevels=1000 " max changes
set undoreload=10000 " max lines saved on buffer reload
set undodir=~/.vim/undodir
if empty(glob(&undodir))
    call system('mkdir ' . &undodir)
endif

" Searching
set incsearch " Find the next match as we type the search
set ignorecase " Ignore case when searching...
set smartcase " ...unless we type a capital

" Other settings
set mouse=a " use the mouse
set exrc " enable per-directory .vimrc files
set secure " disable unsafe commands in local .vimrc files
set formatoptions+=j " remove comment prefixes when joining lines
set formatoptions-=o " dont add comment prefix on o/O

" Non-leader mappings
nnoremap ; :
inoremap <C-c> <esc>:x<CR>
nnoremap <C-c> :x<CR>

" Use <C-\> to clear the highlighting of :set hlsearch.
nnoremap <silent> <C-\> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" Leader mappings (use :map <leader> to see all mappings in alphabetical order)

" Whitespace
nnoremap <leader>S :%s/\s\+$//<CR>

" Organizing
vnoremap <leader>s :sort<CR>
nnoremap <leader>s {jV}k:sort<CR>

" Window mgmt
nnoremap <leader>t :tabe<CR>
nnoremap <leader>sv :vs<CR>
nnoremap <leader>sh :sp<CR>
nnoremap <leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l
" or with control keys
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Tab mgmt
nnoremap <leader>[ :tabN<CR>
nnoremap <leader>] :tabn<CR>
nnoremap <leader>{ :tabm -1<CR>
nnoremap <leader>} :tabm +1<CR>
nnoremap <leader>T :tabc<CR>

" File nav
nnoremap <leader>o :CtrlP<CR>
nnoremap <leader>bo :CtrlPBuffer<CR>
nnoremap <leader>d :e %:p:h<CR>

" Replace all
nnoremap <leader>r :%s/<c-r>=expand("<cword>")<cr>/<c-r>=expand("<cword>")<cr>
vnoremap <leader>r "sy:%s/<c-r>s/<c-r>s

" Replace in line
nnoremap <leader>lr :s/<c-r>=expand("<cword>")<cr>/

" For vimdiff
nnoremap <leader>1 :diffget LOCAL<cr>
nnoremap <leader>2 :diffget BASE<cr>
nnoremap <leader>3 :diffget REMOTE<cr>

" Copy/pasting from system registers
nnoremap <leader>p "+
vnoremap <leader>p "+
nnoremap <C-v> "+p

" Copy/pasting over ssh to osx
function! PropagatePasteBufferToOSX()
    let @n=getreg('"')
    call system('pbcopy-remote', @n)
    echo "done"
endfunction
function! PopulatePasteBufferFromOSX()
    let @" = system('pbpaste-remote')
    echo "done"
endfunction
nnoremap <leader>bp :call PopulatePasteBufferFromOSX()<cr>
nnoremap <leader>bc :call PropagatePasteBufferToOSX()<cr>
vnoremap <leader>bc y:call PropagatePasteBufferToOSX()<cr>

" Edit/reload the vimrc file
nnoremap <leader>ve :e ~/.vimrc<CR>
nnoremap <leader>vs :so $MYVIMRC<CR>
augroup sourcereload
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
  autocmd BufWritePost vimrc source $MYVIMRC
  autocmd BufWritePost *.vim source $MYVIMRC
  autocmd BufWritePost .tmux.conf :!tmux source-file ~/.tmux.conf
augroup END

" Using plug
nnoremap <leader>vi :so $MYVIMRC<CR>:PlugClean!<CR>:PlugInstall<CR>
nnoremap <leader>vp :e ~/.vim/plugins.vim<CR>
nnoremap <leader>vu :so $MYVIMRC<CR>:PlugClean!<CR>:PlugUpgrade<CR>:PlugUpdate<CR>

" Saving and Exiting
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader><esc> :qall<CR>
command! Q q

" Enable syntax highlighting
syntax enable
syntax on

" Turn plugins back on (needs to be last line)
filetype plugin indent on
