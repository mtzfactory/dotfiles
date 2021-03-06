noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Key mappings
let mapleader="\<Space>"

" Plugins management
nmap <leader>pi :PlugInstall<CR>
nmap <leader>pu :PlugUpdate<CR>

" This unsets the 'last search pattern' register by hitting return
nnoremap <CR> :noh<CR>

" Clear search highlights.
map <leader><space> :let @/=''<CR>

" Buffer access
"  Reload all buffers
nnoremap <leader>bl :ls<CR>
"  Go to previous buffer
nmap <leader>rr :checktime<CR>
"  Go to next buffer
nmap <leader>bp :bp<CR>
"  Go to previous buffer in use
nmap <leader>bn :bn<CR>
"  Close current buffer
nmap <leader>bg :e#<CR>
"  Close all buffers
nmap <leader>br :bd<CR>
nmap <leader>ba :bufdo bd<CR>

" Move 1 more lines up or down in normal and visual selection modes.
nnoremap K :m .-2<CR>==
nnoremap J :m .+1<CR>==
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

" Reload Vim config
nnoremap <silent> <leader><leader> :source $MYVIMRC<CR>

" Edit Vim config
nnoremap <silent> <leader>v :e $MYVIMRC<CR>

