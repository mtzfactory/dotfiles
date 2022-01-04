" Ale - Asynchronous Lint Engine
" ---------------------
if exists('g:plugs["ale"]')
  echom "-- Loading Ale configuration"

  let g:ale_fixers = {
    \   'typescript': ['prettier', 'eslint'],
    \}

  let g:ale_linters = {}
  let g:ale_linters.typescript = ['eslint', 'tsserver']

  let g:ale_typescript_prettier_use_local_config = 1

  let g:ale_fix_on_save = 1

  let g:ale_linters_explicit = 1
endif
