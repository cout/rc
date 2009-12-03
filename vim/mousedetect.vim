" This will detect the terminal type and set ttymouse appropriately.  If the
" mouse is not enabled, then 
"
"
let mousedetected=0
if has("mouse")
  " Detect which terminal type we are using and set the mouse type accordingly.
  if !match($COLORTERM, "Eterm.*")
    let mousedetected=1
    set ttymouse=xterm
  elseif !match($TERM, "xterm.*")
    let mousedetected=1
    " if !has("termresponse")
      " If we can't detect xterm type, then we'll assume a newer xterm.
      set ttymouse=xterm2
    " endif 
  elseif !match($TERM, "linux.*")
    if has("mouse_gpm")
      " TODO: Is this right?
      let mousedetected=1
      set ttymouse=dec
    end
  else
    if has("mouse_netterm")
      let mousedetected=1
      set ttymouse=netterm
    end
  endif
endif

