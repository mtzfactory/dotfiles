" Conquer Of Completion
" ----------------------
if exists('g:plugs["coc.nvim"]')
  let g:coc_global_extensions = [
  \ 'coc-css',
  \ 'coc-emmet',
  \ 'coc-html',
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-markdownlint',
  \ 'coc-python',
  \ 'coc-solargraph',
  \ 'coc-tsserver',
  \ 'coc-yaml'
  \ ]

  if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
    echom ">> The project has Prettier in node_modules"
    let g:coc_global_extensions += ['coc-prettier']
  else
    echom ">> The project doesn't has Prettier in node_modules"
  endif

  if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
    echom ">> The project has EsLint in node_modules"
    let g:coc_global_extensions += ['coc-eslint']
  else
    echom ">> The project doesn't has EsLint in node_modules"
  endif
endif
