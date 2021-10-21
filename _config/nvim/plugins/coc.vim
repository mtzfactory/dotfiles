" Conquer Of Completion
" ----------------------
if exists('g:plugs["coc.nvim"]')
  let g:coc_global_extensions = [
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-tsserver',
  \ 'coc-solargraph'
  \ ]

  if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
    let g:coc_global_extensions += ['coc-prettier']
  endif

  if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
    let g:coc_global_extensions += ['coc-eslint']
  endif
endif
