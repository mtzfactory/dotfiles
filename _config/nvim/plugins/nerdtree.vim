" NERDTree 
" ---------
if exists('g:plugs["nerdtree"]')
  let NERDTreeWinSize=40
  let NERDTreeShowHidden=1
  let NERDTreeQuitOnOpen=1
  let NERDTreeMinimalUI=1
  let g:NERDTreeWinPos='right'
  "  Toggle NERDTree on the right side by C-e
  noremap <C-e> :NERDTreeToggle<CR>
endif
