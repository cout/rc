" fonts is a colon-separated list of fonts to toggle between
" (w: indicates a window-specific variable) 
let w:fonts = "fixed:vga:9x15"

" font_list stores a subset of fonts; fonts are removed from the list as
" they are selected, so that the first font in the list is always the
" next font to be selected.
let w:font_list = w:fonts

" Extract everything up to (but not including) the first colon in
" w:font_list and set guifont to that value.
function Change_Font()
  let &guifont = substitute(w:font_list, ":.*", "", "") 
endfunction 

" Change the current font and remove the first font in font_list.
function Next_Font()
  call Change_Font()
  let w:font_list = substitute(w:font_list, "[^:]*:*", "", "")
  if w:font_list == ""
    let w:font_list = w:fonts
  endif
endfunction

map <S-F1> :call Next_Font()<cr>
call Next_Font()

