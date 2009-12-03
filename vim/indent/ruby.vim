" Vim indent file
" Language:	Ruby
" Maintainer:	Gavin Sinclair <gsinclair@soyabean.com.au>
" Last Change:	$Date$
" Revision:     $Revision$
" URL: www.soyabean.com.au/gavin/vim/index.html
" Changes: (since vim 6.1)
"  - indentation after a line ending in comma, etc, (even in a comment) was
"    broken, now fixed (2002/08/14)
"  - regexes changed to 'very magic' for clarity (2002/08/17)
"  - further readability (2002/08/17)
"
" Todo:
"  - don't try to indent contents of here-documents
"  - indent continuation lines by 2 * shiftwidth (then back to normal
"    afterwards)

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetRubyIndent()
setlocal nolisp
setlocal nosmartindent
setlocal autoindent
setlocal indentkeys+==end,=else,=elsif,=when,=ensure,=rescue

" Only define the function once.
if exists("*GetRubyIndent")
  finish
endif

function GetRubyIndent()
  " Find a non-blank line above the current line.
  let lnum = prevnonblank(v:lnum - 1)
  let line = getline(lnum)
  let ind  = indent(lnum)
  let flag = 0

  " At the start of the file use zero indent.
  if lnum == 0
    return 0
  endif

  " If the line trailed with [*+,.(] - but not in a comment - trust the user
  if line =~ '\v([^#].*)?(\*|\.|+|,|\()(\s*#.*)?$'
    return -1
  endif

  " Add a 'shiftwidth' after lines beginning with module, class, def, ...
  " or ending in {, do (with optional |...| and comment).
  let begin_words = '(module|class|def|if|for|while|until|else|elsif|case|when|unless|begin|ensure|rescue)>'
  if line =~ '\v^\s*' . begin_words  ||  line =~ '\v(\{|<do>)\s*(\|[^|]*\|)?(\s*#.*)?$'
    let ind = ind + &sw
    let flag = 1
  endif

  " Subtract a 'shiftwidth' after lines ending with
  " "end" when they begin with while, if, for, until
  if flag == 1 && line =~ '\v<end>(\s*#.*)?$'
    let ind = ind - &sw
  endif

  " Subtract a 'shiftwidth' on end, else, elsif, when, }, ensure, rescue
  " (CURRENT line)
  if getline(v:lnum) =~ '\v^\s*((end|else|elsif|when|ensure|rescue)>|\})'
    let ind = ind - &sw
  endif

  return ind
endfunction

" vim:sw=2

