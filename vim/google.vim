" Load google.vim plugins
filetype off
source /usr/share/vim/google/google.vim
filetype plugin indent on

Glug youcompleteme-google

Glug blaze plugin[mappings]='<leader>b'
Glug codefmt
Glug codefmt-google

" Wrap autocmds inside an augroup to protect against reloading this script.
" For more details, see:
" http://learnvimscriptthehardway.stevelosh.com/chapters/14.html
augroup autoformat
  autocmd!
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType proto AutoFormatBuffer clang-format
  autocmd FileType c,cpp AutoFormatBuffer clang-format
  " autocmd FileType python AutoFormatBuffer pyformat
  autocmd FileType markdown AutoFormatBuffer mdformat
augroup END

" Linting
" Glug syntastic-google checkers=`{'python': 'gpylint'}`
" disable import errors because gpylint fails with appengine imports
let g:syntastic_python_gpylint_args='--disable=import-errror'
let g:syntastic_python_checkers=['gpylint', 'flake8']

" Load the G4 plugin, which allows G4MoveFile, G4Edit, G4Pending, etc.
" Use :h g4 for more details about this plugin
Glug g4

" Enable the corpweb plugin, which allows us to open codesearch from vim
Glug corpweb
" search in critique for the word under the cursor
nnoremap <leader>csw :CorpWebCs <cword> <Cr>
" search in critique for the current file
nnoremap <leader>csf :CorpWebCsFile<CR>

" Load the Critique integration. Use :h critique for more details
Glug critique

" Edit this file
nnoremap <leader>vg :tabe ~/.dotfiles/vim/google.vim<CR>
