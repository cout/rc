" -*- vim -*-
" vim:sts=2:sw=2:
" URL:  http://sites.netscape.net/BBenjiF/vim/matchit.vim
" FILE: "D:\vim\matchit.vim"
" UPLOAD: URL="ftp://siteftp.netscape.net/benjif/vim/matchit.vim"
" UPLOAD: USER="benjif"
" LAST MODIFICATION: "Thu, 28 Dec 2000 09:48:11 Eastern Standard Time ()"
" (C) 2000 by Benji Fisher, <benji@member.AMS.org>
" $Id$

" TODO:  for vim 6.0, I can use s: variables instead of wrapping the
" definition of b:match_words in a function.  I should also look into the new
" search() function and think about multi-line patterns for b:match_words.

" I think the echo in the map clears the command line!
nmap% :<C-U>call Match_wrapper('', 1) \| echo '' <CR>
vmap% <Esc>%m'gv``
nmap g% :call Match_wrapper('', 0) \| echo '' <CR>
vmap g% <Esc>g%m'gv``

" Highlight group for error messages.  The user may choose to set this
" to be invisible.
hi link MatchError WarningMsg

function! Match_wrapper(word, forward) range
  if v:count
    exe "normal! " . v:count . "%"
    return
  elseif !exists("b:match_words") || b:match_words == ""
    normal! %
    return
  end
  if &ic
    let restore_options = "set ignorecase "
  else
    let restore_options = "set noignorecase "
  endif
  if exists("b:match_ignorecase")
    let &ignorecase = b:match_ignorecase
  endif
  " BR always means 'with back references.'
  " The first step is to create a search pattern with the BR's resolved.
  let patBR = substitute(b:match_words.":", '[,:]*:[,:]*', ':', "g")
  let patBR = substitute(patBR, ',\{2,}', ',', "g")
  if patBR !~ '\\\d'
    let do_BR = 0
    let pat = patBR
  else
    let do_BR = 1
    let pat = ""
    let maxlen = strlen(patBR)
    while patBR =~ '[^,:]'
      let i = match(patBR, ':') + 1
      let currentBR = strpart(patBR, 0, i-1) . ","
      let patBR = strpart(patBR, i, maxlen)
      let i = match(currentBR, ',') + 1
      let iniBR = strpart(currentBR, 0, i-1)
      let currentBR = strpart(currentBR, i, maxlen)
      let pat = pat . iniBR
      let i = match(currentBR, ',') + 1
      while i
	" In 'if,then,else', ini='if' and tail='then' and then tail='else'.
	let tailBR = strpart(currentBR, 0, i-1)
	let currentBR = strpart(currentBR, i, maxlen)
	let pat = pat . "," . Match_resolve(iniBR, tailBR, "word")
	let i = match(currentBR, ',') + 1
      endwhile " Now, currentBR has been used up.
      let pat = pat . ":"
    endwhile " patBR =~ '[^,:]'
  endif " patBR !~ '\\\d'
  if exists("b:match_debug")
    let b:match_pat = pat
  endif

  " Second step:  set match to the bit of text that matches one of the
  " patterns.  Require match to end on or after the cursor and prefer it to
  " start on or before the cursor.  The next several lines were here before
  " BF started messing with this script.
  " quote the special chars in 'matchpairs', replace [,:] with \| and then
  " append the builtin pairs (/*, */, #if, #ifdef, #else, #elif, #endif)
  let default = substitute(escape(&mps, '[$^.*~\\/?]'), '[,:]\+',
    \ '\\|', 'g').'\|\/\*\|\*\/\|#if\>\|#ifdef\>\|#else\>\|#elif\>\|#endif\>'
  " all = pattern with all the keywords
  let all = '\(' . substitute(pat, '[,:]\+', '\\|', 'g') . default . '\)'
  if a:word != ''
    " word given
    if a:word !~ all
      echohl MatchError|echo 'Missing rule for word:"'.a:word.'"'|echohl NONE
      return
    endif
    let match = a:word
    let matchline = match
    let prefix = '^\('
    let suffix = '\)$'
  " Now the case when "word" is not given
  elseif matchend(getline("."), '.*' . all) < col(".")
    " there is no special word in this line || it is before the cursor
    echohl MatchError | echo "No matching rule applies here" | echohl NONE
    return
  else	" Find the match that ends on or after the cursor and position the
	" cursor at the start of this match.
    let matchline = getline(".")
    let linelen = strlen(matchline)
    let curcol = col(".") " column of the cursor in match
    if curcol > 1
      let prefix = '^\(.\{,' . (curcol-1) . '}\)'
    else
      let prefix = '^\(\)'
    endif
    if curcol < linelen
      let suffix = '.\{,' . (linelen-curcol) . '}$'
    else
      let suffix = '$'
    endif
    " If there is no match including the cusor position, allow a match
    " that starts and ends after the cursor.
    if matchline !~ prefix.all.suffix
      " It might be better to have alternative "let curcol" and "let match"
      " lines here...
      let prefix = '^\(.\{-}\)'
    endif
    let curcol = strlen(substitute(matchline, prefix.all.suffix, '\1', ""))
    let match = substitute(matchline, prefix.all.suffix, '\2', "")
    if curcol
      let prefix = '^.\{' . curcol . '}\('
    else
      let prefix = '^\('
    endif
    if curcol + strlen(match) < linelen
      let suffix = '\).\{' . (linelen - curcol - strlen(match)) . '}$'
    else
      let suffix = '\)$'
    endif
    " Remove the trailing colon and replace '[,:]' with '\|':
    if matchline !~ prefix . substitute(strpart(pat, 0, strlen(pat)-1),
    \ '[,:]\+', '\\|', 'g') . suffix
      norm! %
      return
    endif
  endif
  if exists("b:match_debug")
    let b:match_match = match
    let b:match_col = curcol+1
  endif

  " Third step:  Find the group and single word that match, and the original
  " (backref) versions of these.  Then, resolve the backrefs.
  " Reconstruct the version with unresolved backrefs.
  let patBR = substitute(b:match_words.":", '[,:]*:[,:]*', ':', "g")
  let patBR = substitute(patBR, ',\{2,}', ',', "g")
  " Now, set current and currentBR to the matching group: 'if,endif' or
  " 'while,endwhile' or whatever.
  let patlen = strlen(pat)
  let i = match(pat, ":") + 1
  let current = strpart(pat, 0, i-1)
  while matchline !~ prefix . substitute(current, ",", '\\|', "g") . suffix
    let patBR = substitute(patBR, '[^:]*:', "", "")
    let pat = strpart(pat, i, patlen)
    let i = match(pat, ":") + 1
    let current = strpart(pat, 0, i-1)
  endwhile
  let pat = current
  if do_BR  " Do the hard part:  resolve those backrefs!
    " Similar to above:  extract the matching word.
    let current = current . ","
    let currentBR = matchstr(patBR, '[^:]*') . ","
    let i = match(currentBR, ',') + 1
    let iniBR = strpart(currentBR, 0, i-1)
    if exists("b:match_debug")
      let b:match_iniBR = iniBR
      let b:match_wholeBR = currentBR
    endif
    " Strip off the trailing comma:
    let tailBR = strpart(currentBR, i, strlen(currentBR)-(i+1))
    let i = match(current, ',') + 1
    let word = strpart(current, 0, i-1)
    while matchline !~ prefix . word . suffix
      let current = strpart(current, i, patlen)
      let i = match(current, ',') + 1
      let word = strpart(current, 0, i-1)
      let currentBR = substitute(currentBR, '[^,]*,', "", "")
    endwhile
    let wordBR = matchstr(currentBR, '[^,]*')
    " Now, match =~ word and wordBR is the version with backrefs.
    if wordBR == iniBR
      let table = ""
      let d = 0
      while d < 10
	if tailBR =~ '\\' . d
	  let table = table . d
	else
	  let table = table . "-"
	endif
	let d = d + 1
      endwhile
    else
      let table = Match_resolve(iniBR, wordBR, "table")
    endif
    let d = 9
    while d
      if table[d] != "-"
	let backref = substitute(match, word, '\'.table[d], "")
	let backref = escape(backref, '*')
	let tailBR = substitute(tailBR, '\\'.d, escape(backref, '\'), "g")
	execute Match_ref(iniBR, d, "start", "len")
	let iniBR = strpart(iniBR, 0, start) . backref
	\ . strpart(iniBR, start+len, strlen(iniBR))
      endif
      let d = d-1
    endwhile
    let pat = iniBR . "," . tailBR
  endif " do_BR
  let i = match(pat, ",")
  let ini = strpart(pat, 0, i)
  let fin = substitute(pat, '.*,', '', '')
  let tail = strpart(pat, i+1, strlen(pat))
  let tail = substitute(tail, ',', '\\|', 'g')
  let bwtail = substitute(pat, ',[^,]*$', "", "")
  let bwtail = substitute(bwtail, ',', '\\|', 'g')
  if exists("b:match_debug")
    let b:match_ini = ini
    let b:match_tail = tail
    if do_BR
      let b:match_table = table
      let b:match_word = word
    else
      let b:match_table = ""
      let b:match_word = ""
    endif
  endif

  " Fourth step:  actually start moving the cursor and call Match_Busca().
  " This minimizes screen jumps and avoids using a global mark.
  let restore_cursor = line(".") . "normal!" . virtcol(".") . "|"
  normal! H
  let restore_screen = line(".")
  execute restore_cursor
  " Later, :execute restore_screen to get to the original screen.
  let restore_screen = restore_screen . "normal!zt"
  if &ws
    let restore_options = restore_options . "wrapscan "
  else
    let restore_options = restore_options . "nowrapscan "
  endif
  set nows
  normal! 0
  if curcol
    execute "normal!" . curcol . "l"
  endif
  let errmsg = ''
  if a:forward && match =~ '^\(' . fin . '\)$'
    let errmsg = Match_Busca("?", fin, ini, ini)
  elseif a:forward
    let errmsg = Match_Busca("/", ini, fin, tail)
  elseif match =~ '^\(' . ini . '\)$'
    let errmsg = Match_Busca("/", ini, fin, fin)
  else
    let errmsg = Match_Busca("?", fin, ini, bwtail)
  endif
  " a hack to deal with "if...end if" situations
  if getline(".")[col(".")-1] =~ '\s'
    normal! w
  endif
  " Mark the final position.
  let mark = line(".") . "normal!" . virtcol(".") . "|"
  " Restore options and original screen.
  execute restore_options
  execute restore_screen
  execute restore_cursor
  normal!m'
  if errmsg != -1 
    " Now, go to the final position.
    execute mark
  endif
endfun

" dir: is either "/" or "?", defines the direction of the search
" ini: pattern for words that indicate the start of a group
" fin: pattern for words that indicate the end of a group
" tail: pattern for special words that are not the beginning of a nested group
"       for example: Match_Busca('/', '\<if\>', '\<end',
"		\ '\<elseif\>\|\<else\>\|\<end')
"       for example: Match_Busca('?', '\<end', '\<if\>', '\<if\>')
" note that if U R moving backwards ini='\<end', and fin='\<if\>'
function! Match_Busca(dir, ini, fin, tail) abort
  let ini = escape(a:ini, '/?')
  let fin = escape(a:fin, '/?')
  let tail = escape(a:tail, '/?')
  let pattern =  '\(' . ini . '\|' . tail . '\)'
  if a:dir == "?"
    let prefix = '.*'
  else
    let prefix = ''
  endif
  let string = getline(".")
  let start = col(".") - 1
  if start
    let end = matchend(string, '^.\{'.start.'}' . pattern)
  else
    let end = matchend(string, pattern)
  endif
  if exists("b:match_comment")
    let iscomment = 'strpart(string, 0, end) =~ b:match_comment'
    if exists("b:match_strings_like_comments")
      let iscomment = iscomment .
	\ '||synIDattr(synID(line("."),end,1),"name") =~? "string"'
    endif
  elseif has("syntax") && exists("g:syntax_on")
    let iscomment = 'synIDattr(synID(line("."),end,1),"name") =~? "comment"'
    if exists("b:match_strings_like_comments")
      let iscomment = substitute(iscomment, "ment", 'ment\\\\|string', "")
    endif
  else
    let iscomment = "0"
  endif
  execute 'let comment =' . iscomment
  if comment
    let iscomment = "0"
  endif
  let depth = 1 " nesting depth

  while depth
    if a:dir == "/"
      let end = matchend(string, '.\{' . end . '}' . pattern)
    else
      let start = match(strpart(string, 0, end), pattern . "$")
      let end = matchend(strpart(string, 0, start), '.*' . pattern)
    endif
    if end == -1
      execute a:dir . pattern
      let string = getline(".")
      let end = matchend(string, prefix . pattern)
    endif
    execute 'let comment =' . iscomment
    if comment
	continue  " Comment:  no change to depth.
    endif
    " Maybe I should make sure to match '^' . ini . '$' .
    if  strpart(string, 0, end) =~ a:ini . "$"  " found ini
      let depth = depth + 1
      if depth == 2
	let pattern =  '\(' . ini . '\|' . fin . '\)'
      endif
    else  " found fin or depth == 1 and found tail
      let depth = depth - 1
      if depth == 1
	let pattern =  '\(' . ini . '\|' . tail . '\)'
      endif
    endif
  endwhile

  normal! 0
  let start = match(strpart(string, 0, end), pattern . "$")
  if start
    execute "normal!" . start . "l"
  endif
endfunction

" No extra arguments:  Match_ref(string, d) will
" find the d'th occurrence of '\(' and return it, along with everything up
" to and including the matching '\)'.
" One argument:  Match_ref(string, d, "start") returns the index of the start
" of the d'th '\(' and any other argument returns the length of the group.
" Two arguments:  Match_ref(string, d, "foo", "bar") returns a string to be
" executed, having the effect of
"   :let foo = Match_ref(string, d, "start")
"   :let bar = Match_ref(string, d, "len")
fun! Match_ref(string, d, ...)
  let len = strlen(a:string)
  if a:d == 0
    let start = 0
  else
    let start = matchend(a:string, '\(.\{-}\\(\)\{' . a:d . '}')
    if start == -1
      return ""
    elseif a:0 == 1 && a:1 == "start"
      return start - 2
    endif
    let match = strpart(a:string, start, len)
    let cnt = 1
    while cnt
      let index = match(match, '\\(\|\\)') + 1
      if index == -1
	return ""
      endif
      let cnt = match('0(', match[index]) + cnt
      " Increment if an open, decrement if a ')'.
      let match = strpart(match, index+1, len)
    endwhile
    let start = start - 2
    let len = len - start - strlen(match)
  endif
  if a:0 == 1
    return len
  elseif a:0 == 2
    return "let " . a:1 . "=" . start . "| let " . a:2 . "=" . len
  else
    return strpart(a:string, start, len)
  endif
endfun

" Count the number of disjoint copies of pattern in string.
" If the pattern is a literal string and contains no '0' or '1' characters
" then Match_count(string, pattern, '0', '1') should be faster than
" Match_count(string, pattern).
fun! Match_count(string, pattern, ...)
  let pat = escape(a:pattern, '\')
  if a:0 > 1
    let foo = substitute(a:string, '[^'.a:pattern.']', "a:1", "g")
    let foo = substitute(a:string, pat, a:2, "g")
    let foo = substitute(foo, '[^'.a:2.']', "", "g")
    return strlen(foo)
  endif
  let result = 0
  let foo = a:string
  let maxlen = strlen(foo)
  let index = matchend(foo, pat)
  while index != -1
    let result = result + 1
    let foo = strpart(foo, index, maxlen)
    let index = matchend(foo, pat)
  endwhile
  return result
endfun

" Match_resolve('\(a\)\(b\)', '\(c\)\2\1\1\2') should return table.word, where
" word = '\(c\)\(b\)\(a\)\3\2' and table = ' 32        '.  That is, the first
" '\1' in target is replaced by '\(a\)' in word, table[1] = 3, and this
" indicates that all other instances of '\1' in target are to be replaced
" by '\3'.  The hard part is dealing with nesting...
" Note that ":" is an illegal character for source and target.
fun! Match_resolve(source, target, output)
  let word = a:target
  let i = match(word, '\\\d') + 1
  let table = "----------"
  while i " There are back references to be replaced.
    let d = word[i]
    let backref = Match_ref(a:source, d)
    " The idea is to replace '\d' with backref.  Before we do this,
    " replace any \(\) groups in backref with :1, :2, ... if they
    " correspond to the first, second, ... group already inserted
    " into backref.  Later, replace :1 with \1 and so on.  The group
    " number w+b within backref corresponds to the group number
    " s within a:source.
    " w = number of '\(' in word before the current one
    let w = Match_count(strpart(word, 0, i-1), '\(', '1')
    let b = 1 " number of the current '\(' in backref
    let s = d " number of the current '\(' in a:source
    while b <= Match_count(backref, '\(', '1') && s < 10
      if table[s] == "-"
	if w + b < 10
	  let table = strpart(table, 0, s) . (w+b) . strpart(table, s+1, 10)
	endif
	let b = b + 1
	let s = s + 1
      else
	execute Match_ref(backref, b, "start", "len")
	let ref = strpart(backref, start, len)
	let backref = strpart(backref, 0, start) . ":". table[s]
	\ . strpart(backref, start+len, 1000000)
	let s = s + Match_count(ref, '\(', '1')
      endif
    endwhile
    let word = strpart(word, 0, i-1) . backref . strpart(word, i+1, 1000000)
    let i = match(word, '\\\d') + 1
  endwhile
  let word = substitute(word, ':', '\\', "g")
  if a:output == "table"
    return table
  elseif a:output == "word"
    return word
  else
    return table . word
  endif
endfun

" Call this function to turn on debugging information.  Every time the main
" script is run, buffer variables will be saved.  These can be used directly
" or viewed using the menu items below.
command! -nargs=0 MatchDebug call Match_debug()
fun! Match_debug()
  let b:match_debug = 1	" Save debugging information.
  " pat = all of b:match_words with backrefs parsed
  amenu &Matchit.&pat	:echo b:match_pat<CR>
  " match = bit of text that is recognized as a match
  amenu &Matchit.&match	:echo b:match_match<CR>
  " curcol = cursor column of the start of the matching text
  amenu &Matchit.&curcol	:echo b:match_col<CR>
  " wholeBR = matching group, original version
  amenu &Matchit.wh&oleBR	:echo b:match_wholeBR<CR>
  " iniBR = 'if' piece, original version
  amenu &Matchit.ini&BR	:echo b:match_iniBR<CR>
  " ini = 'if' piece, with all backrefs resolved from match
  amenu &Matchit.&ini	:echo b:match_ini<CR>
  " tail = 'else\|endif' piece, with all backrefs resolved from match
  amenu &Matchit.&tail	:echo b:match_tail<CR>
  " fin = 'endif' piece, with all backrefs resolved from match
  amenu &Matchit.&word	:echo b:match_word<CR>
  " '\'.d in ini refers to the same thing as '\'.table[d] in word.
  amenu &Matchit.t&able	:echo '0:' . b:match_table . ':9'<CR>
endfun

" The following autocommands are wrapped in a function, to be used once when
" this file is sourced, in order to allow the use of local variables.  The
" function is called and then deleted after it is defined.
fun Match_autocommands()
  aug Matchit
    au!
    " Ada:  thanks to Neil Bird.
    let notend = '\(^\s*\|[^d\t ]\s\+\)'
    execute "au FileType ada let b:match_words='" .
    \ notend . '\<if\>,\<elsif\>,\<else\>,\<end\>\s\+\<if\>:' .
    \ notend . '\<case\>,\<when\>,\<end\>\s\+\<case\>:' .
    \ '\(\<while\>.*\|\<for\>.*\|'.notend.'\)\<loop\>,\<end\>\s\+\<loop\>:' .
    \ '\(\<do\>\|\<begin\>\),\<exception\>,\<end\>\s*\($\|[;A-Z]\):' .
    \ notend . '\<record\>,\<end\>\s\+\<record\>' .
    \ "'"
    " Csh:  thanks to Johannes Zellner
    " - Both foreach and end must appear alone on separate lines.
    " - The words else and endif must appear at the beginning of input lines;
    "   the if must appear alone on its input line or after an else.
    " - Each case label and the default label must appear at the start of a
    "   line.
    " - while and end must appear alone on their input lines.
    au FileType csh,tcsh let b:match_words =
	\ '^\s*\<if\>.*(.*).*\<then\>,'.
	\   '^\s*\<else\>\s\+\<if\>.*(.*).*\<then\>,^\s*\<else\>,'.
	\   '^\s*\<endif\>:'.
	\ '\(^\s*\<foreach\>\s\+\S\+\|^s*\<while\>\).*(.*),'.
	\   '\<break\>,\<continue\>,^\s*\<end\>:'.
	\ '^\s*\<switch\>.*(.*),^\s*\<case\>\s\+,^\s*\<default\>,^\s*\<endsw\>'
    " DTD:  thanks to Johannes Zellner
    " - match <!--, --> style comments.
    " - match <! with >
    " - TODO:  why does '--,--:'. not work ?
    au! FileType dtd let b:match_words =
      \ '<!--,-->:'.
      \ '<!,>'
    " Entity:  see XML.
    " Essbase:
    au BufNewFile,BufRead *.csc let b:match_words=
    \ '\<fix\>,\<endfix\>:' .
    \ '\<if\>,\<else\(if\)\=\>,\<endif\>:' .
    \ '\<!loopondimensions\>\|\<!looponselected\>,\<!endloop\>'
    " Fortran:  thanks to Johannes Zellner
    au FileType fortran let b:match_words =
      \ 'do\s\+\([0-9]\+\),^\s*\1\s:'.
      \ '^[0-9 \t]\+\<if.*then\>,\<else\s*\(if.*then\)\=\>,\<endif\>'
    " HTML:  thanks to Johannes Zellner.
    " TODO:  Add '<,>:' when '&' is implemented.
    au FileType html let b:match_ignorecase = 1 |
      \ let b:match_words =
      \ '<[ou]l[^>]*\(>\|$\),<li>,</[ou]l>:' .
      \ '<\([^/][^ \t>]*\)[^>]*\(>\|$\),</\1>'
    " LaTeX:
    au FileType tex let b:match_ignorecase = 0
      \ | let b:match_comment = '\(^\|[^\\]\)\(\\\\\)*%'
      \ | let b:match_words = '(,):\[,]:{,}:\\\[,\\]:' .
      \ '\\begin\s*\({\a\+\*\=}\),\\end\s*\1'
    " Pascal:
    au FileType pascal let b:match_words='\<begin\>,\<end\>'
    " SGML:  see XML
    " Shell:  thanks to Johannes Zellner
    au FileType sh,config let b:match_words =
	\ '^\s*\<if\>\|;\s*\<if\>,'.
	\   '^\s*\<elif\>\|;\s*\<elif\>,^\s*\<else\>\|;\s*\<else\>,'.
	\   '^\s*\<fi\>\|;\s*\<fi\>:'.
	\ '^\s*\<for\>\|;\s*\<for\>\|^\s*\<while\>\|;\s*\<while\>,'.
	\   '^\s*\<done\>\|;\s*\<done\>:'.
	\ '^\s*\<case\>\|;\s*\<case\>,^\s*\<esac\>\|;\s*\<esac\>'
    " Tcsh:  see Csh
    " TeX:  see LaTeX; I do not think plain TeX needs this.
    " Verilog:  thanks to Mark Collett
    au FileType verilog let b:match_ignorecase = 0
	\ | let b:match_words = 
	\ '\<begin\>,\<end\>:'.
	\ '\<case\>\|\<casex\>\|\<casez\>,\<endcase\>:'.
	\ '\<module\>,\<endmodule\>:'.
	\ '\<function\>,\<endfunction\>:'.
	\ '`ifdef\>,`else\>,`endif\>'
    " Vim:
    au FileType vim let b:match_ignorecase=0 | let b:match_words=
    \ '\<fun\(c\=\|cti\=\|ction\=\)\>,\<retu\(rn\=\)\>\=,' .
    \   '\<endf\(u\=\|unc\=\|uncti\=\|unction\=\)\>:' .
    \ '\<while\>,\<break\>,\<con\k*\>,' .
    \   '\<endw\k*\>:' .
    \ '\<if\>,\<el\(s\=\|sei\=\|seif\)\>,\<en\(d\=\|dif\=\)\>:' .
    \ '\<aug\k*\s\+\([^E]\|E[^N]\|EN[^D]\),' .
    \   '\<aug\k*\s\+END\>'
    " XML:  thanks to Johannes Zellner and Akbar Ibrahim
    " - case sensitive
    " - don't match empty tags <fred/>
    " - match <!--, --> style comments (but not --, --)
    " - match <!, > inlined dtd's. This is not perfect, as it
    "   gets confused for example by
    "       <!ENTITY gt ">">
    " - TODO: add <:> if cursor correct positioning is implemented
    au! FileType xml,sgml,entity let b:match_ignorecase=0 | let b:match_words =
      \ '<!\[CDATA\[,]]>:'.
      \ '<!--,-->:'.
      \ '<?\k\+,?>:'.
      \ '<\([^ \t>/]\+\)\(\s\+[^>]*\([^/]>\|$\)\|>\|$\),</\1>:'.
      \ '<\([^ \t>/]\+\)\(\s\+[^/>]*\|$\),/>'

  aug END
endfun

call Match_autocommands()
delfunction Match_autocommands
