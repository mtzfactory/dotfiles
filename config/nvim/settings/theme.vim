" Theme
" ------
" -- Dark
set background=dark
"   - palenight
"let g:palenight_terminal_italics=1
"colorscheme palenight
"   - one
"let g:one_allow_italics = 1
"colorscheme one 
"   - dogrun
colorscheme dogrun

" -- Light
"set background=light
"colorscheme PaperColor

" Airline
" --------
"let g:airline_theme="palenight"
"let g:airline_theme="one"
let g:airline_theme="fruit_punch"  " best fit for 'dogrun' theme
"let g:airline_theme="papercolor"

" Clap
" -----
let g:clap_theme = 'dogrun'

" Cursor
highlight Cursor guifg=white guibg=#ff00ff
highlight iCursor guifg=white guibg=#ff00ff
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver100-iCursor
set guicursor+=n-v-c:blinkon0
set guicursor+=i:blinkwait10

" Custom function to set the theme
function s:setTheme(theme)
  if (a:theme == "dark")
    set background=dark
    colorscheme dogrun
    let g:airline_theme="fruit_punch"
    let g:clap_theme = "dogrun"
    return
  endif
  if (a:theme == "light")
    set background=light
    colorscheme PaperColor
    let g:airline_theme="papercolor"
    return
  endif
  echo "Only Dark or Light mode available"
endfunction

command -nargs=1 Theme call s:setTheme(<f-args>)
command Light call s:setTheme('light')
command Dark call s:setTheme('dark')

