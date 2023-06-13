let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:50,results:50'
let g:ctrlp_reuse_window = 'NERD_tree'
let g:ctrlp_max_files=0

" Use AG for CtrlP
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --nogroup --hidden -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
