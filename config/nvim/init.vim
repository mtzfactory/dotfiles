" INSTALL PLUG IF NOT PRESENT
if has('nvim')
  if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif
 
" LOAD PLUGIN FIRST
source $HOME/.config/nvim/vim-plug.vim

" LOAD NVIM SETTINGS
source $HOME/.config/nvim/settings/set.vim
source $HOME/.config/nvim/settings/keybind.vim
source $HOME/.config/nvim/settings/filetype.vim

" LOAD PLUGIN SETTINGS
source $HOME/.config/nvim/plugins/all.vim

" LOAD NVIM THEME
source $HOME/.config/nvim/settings/theme.vim

" LOAD MIX SETTING
source $HOME/.config/nvim/settings/mix.vim

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
