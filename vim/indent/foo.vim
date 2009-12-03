if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetVimIndent()
setlocal indentkeys+==end,=else,0\\

" Only define the function once.
if exists("*GetVimIndent")
  finish
endif

function GetVimIndent()
  " Find a non-blank line above the current line.
  let lnum = v:lnum - 1

  " At the start of the file use zero indent.
  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)

  " Handle bullets
  let mx = '^\s*[-\*\+]\(\s\+\)'
  let line = getline(lnum)
  if line =~ mx
    let l = substitute(line, mx, '\1', '')
    let ind = ind + strlen(l)
  endif
    
  return ind
endfunction

" vim:sw=2
