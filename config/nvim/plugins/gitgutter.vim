" Git Gutter
" ----------------------
if exists('g:plugs["vim-gitgutter"]')
  " To turn on line highlighting by default
  let g:gitgutter_highlight_lines = 1
  " To turn on line number highlighting by default
  let g:gitgutter_highlight_linenrs = 1
"  nmap ghp <Plug>(GitGutterPreviewHunk)
"  nmap ghs <Plug>(GitGutterStageHunk)
"  nmap ghu <Plug>(GitGutterUndoHunk)

  function! GitStatus()
    let [a,m,r] = GitGutterGetHunkSummary()
    return printf('+%d ~%d -%d', a, m, r)
  endfunction

  set statusline+=%{GitStatus()}
endif

" You can jump between hunks:
" - jump to next hunk (change): ]c
" - jump to previous hunk (change): [c
"
" You can preview, stage, and undo hunks with:
" - preview: <leader>hp
" - stage: <leader>hs
" - undo: <leader>hu
