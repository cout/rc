" An interface to ri
function Ri(keyword)
  new
  exec ("%!ri '" . a:keyword . "'")
  w! /dev/null
endfunction

function RiCurrentWord()
  call Ri(expand("<cword>"))
endfunction

command -nargs=1 Ri :call Ri("<args>")
map <M-r> :call RiCurrentWord()<cr>
map <Esc>r :call RiCurrentWord()<cr>
map <Esc>R :call RiCurrentWord()<cr>

