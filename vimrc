set nocompatible " vi improved

" Set leader, needs to be set before any mappings
let mapleader=" "

" Bootstrap this vimrc
source ~/.vim/bootstrap.vim

" Load vundle plugins
source ~/.vim/bundles.vim

" Load google plugins on goobuntu
if filereadable('/usr/share/vim/google/google.vim')
    source ~/.vim/google.vim
endif

" Colors
syntax enable " source system syntax file
syntax on " use background setting for highlight
set t_Co=256 " always use 256 colors
set term=screen-256color " really force it
let g:solarized_termcolors=256
fun! ToggleColor()
    if &background == "dark"
        set background=light
        colorscheme Tomorrow
    else
        set background=dark
        colorscheme hybrid
    endif
endf
call ToggleColor() " set default to dark

" UI Config
set number " line numbers on
set relativenumber " note using plugin jeffkreeftmeijer/vim-numbertoggle
set showcmd " show incomplete commands at bottom right
set showmatch " briefly highlight matched bracket when pair completed
set ruler " display line and col numbers in bottom right
set wildmenu " tab complete in command line
set wildmode=list:longest,list:full
set lazyredraw " save some cycles: dont redraw during macros
set list listchars=tab:»·,trail:· " show trailing whitespace
set nofoldenable " dont like code folding
set colorcolumn=80 " draw line at 80 cols
set cursorline " highlight the line we are currently on

" Whitespace (should normally be overriden by local editorconfig)
set autoindent
set expandtab
set shiftround
set tabstop=4
set shiftwidth=4
set softtabstop=4
fun! ToggleTab()
    if &shiftwidth == '2'
        set tabstop=4
        set shiftwidth=4
        set softtabstop=4
    else
        set tabstop=2
        set shiftwidth=2
        set softtabstop=2
    endif
endf
nnoremap <leader>c<tab> :call ToggleTab()<cr>

" Windows
set splitright " Open new split panes to right
set splitbelow " and bottom, which feels more natural

" File writing
set nobackup
set nowritebackup
set noswapfile
set autoread
set autowriteall
augroup autosave
  " autowriteall doesn't capture tab changing, write all on lost focus
  autocmd!
  autocmd FocusLost * silent! wa
  autocmd TabLeave * silent! wa
  autocmd WinLeave * silent! wa
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
set backspace=2 " help cygwin out with backspace
set formatoptions+=j " remove comment prefixes when joining lines
set formatoptions-=o " dont add comment prefix on o/O
set formatoptions-=r " dont add comment prefix on <cr>

" Non-leader mappings
nnoremap ; :
nnoremap q; q: " much easier to hit
command! Q q
nnoremap <F5> :e %<CR> " reload file
set pastetoggle=<F12>
" find selection in visual mode
vnoremap // y/<C-R>"<CR>

" Saving and Exiting
inoremap jk <esc>
" note maybe remove kj
inoremap kj <esc>:w<cr>
inoremap <C-d> <esc>:w<CR>:e %:p:h<CR>
inoremap <C-c> <esc>:x<CR>
nnoremap <C-c> :x<CR>
nnoremap <C-d> :w<CR>:e %:p:h<CR>

" Leader mappings (use :map <leader> to see all mappings in order)

" White space
nnoremap <leader>S :%s/\s\+$//<CR>
nnoremap <leader><tab> :retab<CR>

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
nnoremap <leader>f :NERDTreeToggle<CR>
nnoremap <leader>F :NERDTreeFind<CR>
nnoremap <leader>d :e %:p:h<CR>
nnoremap <leader>D :e .<CR>
nnoremap <leader>o :e **/*
nnoremap <leader>O :tabe **/*

" File search
set grepprg=ag " note using rking/ag.vim
nnoremap <leader>gc :Ag <c-r>=expand('<cword>'><cr>
nnoremap <leader>gg :Ag 
nnoremap <leader>ag :Ag 
nnoremap <leader>gh :Ag --html 
nnoremap <leader>gj :Ag --js 
nnoremap <leader>gp :Ag --python 
nnoremap <leader>gr :Ag --ruby 
nnoremap <leader>gs :Ag --scala 

" Replace all
nnoremap <leader>r :%s/<c-r>=expand("<cword>")<cr>/<c-r>=expand("<cword>")<cr>
vnoremap <leader>r "sy:%s/<c-r>s/<c-r>s

" Replace in line
nnoremap <leader>lr :s/<c-r>=expand("<cword>")<cr>/

" Using fugitive
nnoremap <leader>cf :Gwrite<cr>:Gcommit<cr>
nnoremap <leader>cp :Gpush<cr>

" For vimdiff
nnoremap <leader>1 :diffget LOCAL<cr>
nnoremap <leader>2 :diffget BASE<cr>
nnoremap <leader>3 :diffget REMOTE<cr>

" Copy/pasting from system registers
noremap <leader>p "+

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

" Open file in browser
nnoremap <leader>co :!google-chrome '%'<CR>
" on macosx
nnoremap <leader>mo :!open '%'<CR>

" Edit/reload the vimrc file
nnoremap <leader>va :tabe ~/.dotfiles/vimrc<CR>:vsp ~/.dotfiles/vim/bundles.vim<CR><c-w>h
nnoremap <leader>ve :tabe ~/.dotfiles/vimrc<CR>
nnoremap <leader>vb :tabe ~/.dotfiles/vim/bundles.vim<CR>
nnoremap <leader>vs :so $MYVIMRC<CR>
nnoremap <leader>vw :w<CR>:so $MYVIMRC<CR>
nnoremap <leader>vt :w<CR>:!tmux source-file ~/.tmux.conf<CR>
augroup sourcereload
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
  autocmd BufWritePost *.vim source $MYVIMRC
  autocmd BufWritePost .tmux.conf :!tmux source-file ~/.tmux.conf
augroup END

" Using vundle
nnoremap <leader>vi :w<CR>:so $MYVIMRC<CR>:PluginClean<CR>:PluginInstall<CR>

" Saving and Exiting
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader><esc> :qall<CR>
nnoremap <leader>qa :qall<CR>
noremap <leader><leader>q :q!<CR>

" Close the quickfix list and loc list
nnoremap <leader>c :ccl <bar> lcl<cr>

" Run current file
nnoremap <leader>x :!./%<cr>

" Word wrapping
function! ToggleWrap()
    if &list
        setlocal wrap linebreak nolist
        noremap <buffer> <silent> j gj
        noremap <buffer> <silent> k gk
    else
        setlocal list
        silent! nunmap <buffer> j
        silent! nunmap <buffer> k
    endif
endfunction
noremap <F6> :call ToggleWrap()<cr>

" Writing txt files
function! TxtMode()
    call ToggleWrap()
    setlocal nonumber norelativenumber
    setlocal spell
endfunction
command! English call TxtMode()
