set nocompatible " vi improved

" install vundle if it's not loaded
if !exists("*FirstRunOnEnter")
    " have to be careful about defining this while in use
    function FirstRunOnEnter()
        PluginInstall
        source $MYVIMRC
        let oldpath = getcwd()
        execute "cd " . $HOME . "/.vim/bundle/YouCompleteMe"
        " NOTE this need cmake to be installed
        execute "./install.sh"
        execute "cd ../tern_for_vim"
        execute "npm install"
        execute "cd " . oldpath
    endfunction
endif
let vdir = $HOME . '/.vim/bundle/vundle'
if !isdirectory(vdir)
    call system('mkdir -p ' . vdir)
    call system('git clone https://github.com/gmarik/Vundle.vim.git ' . vdir)
    autocmd VimEnter * :call FirstRunOnEnter()
endif

" include vundle config
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

filetype plugin indent on

" Filetypes
autocmd BufRead,BufNewFile *.es6 setfiletype javascript

" MAPPINGS

nnoremap ; :
command! Q q " Bind :Q to :q

" Change bracket notation to dot notation
nnoremap cd f]xhxF[xr.

let mapleader=" "

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

" File nav
nnoremap <leader>f :NERDTreeToggle<CR>
nnoremap <leader>F :NERDTreeFind<CR>
nnoremap <leader>d :e %:p:h<CR>
nnoremap <leader>D :e .<CR>
nnoremap <leader>o :e **/*
nnoremap <leader>O :tabe **/*

" File search
set grepprg=ag
nnoremap <leader>gc :Ag <c-r>=expand('<cword>'><cr>
" using rking/ag.vim
nnoremap <leader>gg :Ag 
nnoremap <leader>gh :Ag --html 
nnoremap <leader>gj :Ag --js 
nnoremap <leader>gp :Ag --python 
nnoremap <leader>gr :Ag --ruby 
nnoremap <leader>gs :Ag --sass 

" Replace all
nnoremap <leader>r :%s/<c-r>=expand("<cword>")<cr>/
vnoremap <leader>r "sy:%s/<c-r>s/

" Replace in line
nnoremap <leader>lr :s/<c-r>=expand("<cword>")<cr>/

" Using fugitive
nnoremap <leader>cf :Gwrite<cr>:Gcommit<cr>
nnoremap <leader>cp :Gpush<cr>

" vimdiff for git mergetool
if &diff
    nnoremap <leader>1 :diffget LOCAL<cr>
    nnoremap <leader>2 :diffget BASE<cr>
    nnoremap <leader>3 :diffget REMOTE<cr>
endif

" Registers
nnoremap <leader>p "+
vnoremap <leader>p "+

" Open file in browser
nnoremap <leader>co :!google-chrome '%'<CR>
nnoremap <leader>mo :!open '%'<CR>

" Edit/reload the vimrc file
nnoremap <leader>va :tabe ~/.dotfiles/vimrc<CR>:vsp ~/.dotfiles/vimrc.bundles<CR><c-w>h
nnoremap <leader>ve :tabe ~/.dotfiles/vimrc<CR>
nnoremap <leader>vb :tabe ~/.dotfiles/vimrc.bundles<CR>
nnoremap <leader>vs :so $MYVIMRC<CR>
nnoremap <leader>vw :w<CR>:so $MYVIMRC<CR>

" Using vundle
nnoremap <leader>vi :PluginClean<CR>:PluginInstall<CR>


" Work
if filereadable(expand("~/.vimrc.work"))
  source ~/.vimrc.work
endif

" Saving and Exiting
inoremap jk <esc>
inoremap kj <esc>:w<cr>

inoremap <C-d> <esc>:w<CR>:e %:p:h<CR>
inoremap <C-z> <esc>:w<CR>
inoremap <C-c> <esc>:x<CR>

nnoremap <C-c> :x<CR>
nnoremap <C-d> :w<CR>:e %:p:h<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader><esc> :qall<CR>

nnoremap <leader>c :ccl <bar> lcl<cr>

" Reload file
nnoremap <F5> :e %<CR>

" Function key functions
nnoremap <F3> :set hlsearch!<CR>
nnoremap <F7> :set spell!<CR>
nnoremap <F10> :set nonumber!<CR>
set pastetoggle=<F12>

" File writing
set nobackup
set nowritebackup
set noswapfile
set nofoldenable
set autoread
set autowriteall

" Take autowrite a step further (write on lost focus)
autocmd FocusLost * silent! wa

" Display
syntax on
set number
set relativenumber
set showcmd " show incomplete commands at bottom right
set showmatch
set ruler

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
" autocmd! BufEnter,BufNew *.txt :call TxtMode() " need to find workaround for
" this executing in vim help files
command! English call TxtMode()


" View trailing white space
set list listchars=tab:»·,trail:· " show trailing

" Color
" if $COLORTERM == 'gnome-terminal'
" problematic on mac... unsure of best practice here
set t_Co=256
" endif

syntax enable
set background=dark
colorscheme hybrid
" colorscheme Tomorrow " light scheme

set colorcolumn=80
set cursorline

" NERDTree settings
let NERDTreeShowLineNumbers=1
let NERDTreeMinimalUI=1
let NERDTreeIgnore=['\.pyc$']

" Syntastic settings
let g:syntastic_check_on_open = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_python_checkers=['flake8', 'pyflakes']
let g:syntastic_python_flake8_exec = 'python2.7'
let g:syntastic_python_flake8_args='--ignore=E501,E401,E302,E261,E128,E265'
let g:syntastic_python_python_exec = 'python2.7'
let g:syntastic_html_checkers=[]

" Python-mode settings
let g:pymode_lint=1
let g:pymode_lint_checkers=['pep8']
let g:pymode_lint_ignore='E501,E401,E302,E261,E128,E265'
let g:pymode_indent=1
let g:pymode_run_bind = '<leader>gpr'
let g:pymode_rope = 1 " too slow and buggy

" Jedi.vim settings
let g:jedi#goto_command = "<leader>jd"
let g:jedi#goto_assignments_command = "<leader>jg"
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>jn"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#rename_command = "<leader>jr"

" YouCompleteMe
let g:ycm_key_list_select_completion=['<tab>', '<Down>']
let g:ycm_key_list_previous_completion=['<s-tab>', '<Up>']

" Utisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" Activate rainbow parens for lisps
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END

set wildmode=list:longest,list:full
set wildmenu

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Set window width to 80 cols + columns needed for linenumbers
function! EightyColumns()
    let numberwidth = float2nr(log10(line("$"))) + 2
    let &l:columns = numberwidth + 80
endfunction
nnoremap <leader>8 :call EightyColumns()<cr>

" Text wrap at 80
au BufRead,BufNewFile *.md setlocal textwidth=80

" Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set shiftround
set softtabstop=4

nnoremap <leader><Tab>2 :set shiftwidth=2<cr>:set softtabstop=2<cr>:set tabstop=2<cr>
nnoremap <leader><Tab>4 :set shiftwidth=4<cr>:set softtabstop=4<cr>:set tabstop=4<cr>

" MISC
set formatoptions-=or " turn off auto-comment prefix on o/O
set backspace=2 " help cygwin out with backspace
set mouse=a

set exrc            " enable per-directory .vimrc files
set secure          " disable unsafe commands in local .vimrc files

" Per project setting overrides
if filereadable(expand("~/.vimrc.projects"))
  source ~/.vimrc.projects
endif
