" Mundo - A Vim plugin to visualizes the Vim undo tree.
" ----------------------
if exists('g:plugs["mundo"]')
  nnoremap <F5> :MundoToggle<CR>

  let g:mundo_width = 60
  let g:mundo_preview_height = 40
  let g:mundo_right = 1
endif
