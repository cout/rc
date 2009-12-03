highlight CurrentLine guibg=darkgrey guifg=white ctermbg=darkgrey ctermfg=white
set ut=100

function HighlightCurrentLineOn()
  au! CursorHold * exe 'match CurrentLine /\%' . line('.') . 'l.*/'
endfunction

function HighlightCurrentLineOff()
  au! CursorHold
  match none
endfunction

map ,h :call HighlightCurrentLineOn()<cr>
map ,H :call HighlightCurrentLineOff()<cr>

