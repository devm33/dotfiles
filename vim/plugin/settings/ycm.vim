" YouCompleteMe mappings
nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gi :YcmCompleter FixIt<CR>

if !exists("g:ycm_semantic_triggers")
   let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

let g:ycm_autoclose_preview_window_after_completion = 1
