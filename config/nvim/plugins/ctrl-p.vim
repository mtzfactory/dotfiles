" Ctrl-P
" -------
if exists('g:plugs["ctrlp.vim"]')
  let g:ctrlp_map = '<C-p>'
  let g:ctrlp_show_hidden=1
  let g:ctrlp_custom_ignore= {
    \ 'dir' : '\v.(node_modules|public|build|coverage|dist|tmp|Pods|.gradle|.git$)',
    \ 'file' : '\v.(.DS_Store|.pyc)'
    \ }
endif
