call plug#begin('~/.vim/plugged')
" Themes
  "Plug 'drewtempelmeyer/palenight.vim'
  "Plug 'rakr/vim-one'
  Plug 'wadackel/vim-dogrun'

" Themes - light
  Plug 'NLKNguyen/papercolor-theme'

" Git
  Plug 'tpope/vim-fugitive'
  Plug 'sodapopcan/vim-twiggy'
  Plug 'airblade/vim-gitgutter'
  Plug 'rhysd/conflict-marker.vim'
  Plug 'xuyuanp/nerdtree-git-plugin'
  
" Browse files
  Plug 'scrooloose/nerdtree'
  Plug 'unkiwii/vim-nerdtree-sync'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'universal-ctags/ctags'
  Plug 'majutsushi/tagbar'
  Plug 'ryanoasis/vim-devicons'
  "Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

  " Interactive finder and dispatcher
  Plug 'liuchengxu/vim-clap', { 'do': { -> clap#installer#force_download() } }
  " Treesitter-based highlighting
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 

" Search and replace
  Plug 'dkprice/vim-easygrep'

" Status bar
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

" Code format
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Code highlight
  Plug 'herringtondarkholme/yats.vim'
  Plug 'jparise/vim-graphql'

" Others
  Plug 'jiangmiao/auto-pairs'
  Plug 'ap/vim-css-color'

  " For Facts, Ruby functions, and custom providers
  Plug 'vim-ruby/vim-ruby'

  " Visualizes the Vim undo tree.
  Plug 'simnalamburt/vim-mundo'

call plug#end()
