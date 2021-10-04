" LOAD PLUGIN FIRST
source $HOME/.config/nvim/vim-plug.vim

" LOAD NVIM SETTING
source $HOME/.config/nvim/settings/set.vim
source $HOME/.config/nvim/settings/keybind.vim

" LOAD PLUGIN SETTINGS
source $HOME/.config/nvim/plugins/all.vim

" LOAD NVIM THEME
source $HOME/.config/nvim/settings/theme.vim

" Save the session, save modified files, and exit
command! Xs :mks! | :xa

" Script exectuted when Vim ends
function Suspend()
  if filereadable(expand("Session.vim"))
    :mks! 
  endif
endfunction

" Script exectuted when Vim starts
function! StartUp()
  if 0 == argc()
    if filereadable(expand("Session.vim"))
      source Session.vim
    else
      "Clap files
      NERDTree
    endif
  endif
endfunction

autocmd VimEnter * call StartUp()
"autocmd VimLeave * call Suspend()
