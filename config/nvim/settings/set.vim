set number
set mouse=a
set numberwidth=1
set clipboard=unnamed
syntax enable
set showcmd
set ruler
set cursorline
set encoding=utf-8
set showmatch
set sw=2
set relativenumber
set laststatus=2
set noshowmode
"
" Enable persistent undo so that undo history persists across vim sessions
set undofile
set undodir=~/.vim/undo

" True colors 
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if (has('termguicolors'))
  set termguicolors
endif

" Folding
set foldmethod=syntax " Syntax highlighting items specify folds
set foldcolumn=1 " Defines 1 col at window left, to indicate folding
let javaScript_fold=1 " Activate folding by JS syntax
set foldlevelstart=99 " Start file with all folds opened
" How to use it:
  " zc — Close the fold (where your cursor is positioned)
  " zM — Close all folds on current buffer
  " zo — Open the fold (where your cursor is positioned)
  " zR — Open all folds on current buffer
  " zj — Cursor is moved to next fold
  " zk — Cursor is moved to previous fold

