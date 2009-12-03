" TODO: Handle "this is a string with the word for in it" 
let b:match_ignorecase=0 | let b:match_words =
      \ '\%(^\|[;=]\)\s*\%('.
        \ 'if.*then\>\|'.
        \ 'if\>\|'.
        \ '\%(while\|until\)\>.\{-}\<do\>\|'.
        \ '\%(while\|until\)\>\|'.
        \ '\<for\>.\{-}in.\{-}\<do\>\|'.
        \ '\<for\>.\{-}in.\{-}\|'.
        \ '\<def\>\|'.
        \ '\<module\>\|'.
        \ '\<class\>\|'.
        \ '\<begin\>\|'.
        \ '\<case\>'.
      \ '\)\|'.
      \ '\<do\>'.
      \ ',\<\%(else\|elsif\|ensure\|rescue\)\>'.
      \ ',\<end\>'

