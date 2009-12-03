" Description:	alignment at arbitrary pattern-delimiters
" Author:	Johannes Zellner <johannes@zellner.org>
" URL:		http://www.zellner.org/vim/plugin/align.vim
" Last Change:	Wed, 19 Sep 2001 23:22:11 +0200
" Requirements:	vim >= 6.0h, cpoptions must /not/ contain '<'
" $Id$

if exists('g:align_loaded') | finish | endif
let g:align_loaded = 1

let s:align_cpo_save = &cpo
set cpo&vim

fun! Align(pat, repl, fill, flag) range
    let report = &report
    set report=999999
    if 'l' == a:flag
	exe a:firstline.','.a:lastline.'s¬\(.*\S\|\s*\)\('.a:pat.'\)¬\1\¬\2\¬¬e'
	exe a:firstline.','.a:lastline.'s¬\¬'.a:pat.'\¬¬\¬'.a:repl.'\¬¬e'
    else
	exe a:firstline.','.a:lastline.'s¬'.a:pat.'¬\¬'.a:repl.'\¬¬'.a:flag.'e'
    endif
    while 1
	let max = AlignMaxIndent(a:firstline, a:lastline, '¬')
	if -1 == max
	    break
	endif
	exe a:firstline.','.a:lastline.'s¬\(^[^¬]*\)\¬\([^¬]*\)\¬¬\=AlignLine('.max.',"'.escape(a:fill,'"\\').'",'.strlen(a:fill).')¬e'
	"                                  (   1   ) ¬ (  2   ) ¬
	"                                  ( text  ) ¬ (delim ) ¬
    endwhile
    let &report=report
endfun

fun! AlignLine(max, fill, filllen)
    let text = submatch(1)
    let len = strlen(text)
    while len < a:max
	let text = text . a:fill
	let len = len + a:filllen
    endwhile
    let text = strpart(text, 0, a:max)
    return escape(text . submatch(2), '\')
endfun

fun! AlignMaxIndent(first, last, char)
    let max = -1
    let lnum = a:first
    while lnum <= a:last
	let tmp = stridx(getline(lnum), a:char)
	if tmp > max
	    let max = tmp
	endif
	let lnum = lnum + 1
    endwhile
    return max
endfun

let &cpo = s:align_cpo_save
unlet s:align_cpo_save

if exists('g:autoload') | finish | endif " {{{ used by the autoload generator

if !hasmapto('<Plug>AlignAll')
    vmap <unique> <Leader>a <Plug>AlignAll
endif

if !hasmapto('<Plug>AlignFirst')
    vmap <unique> <Leader>f <Plug>AlignFirst
endif

if !hasmapto('<Plug>AlignLast')
    vmap <unique> <Leader>l <Plug>AlignLast
endif

" INTERACTIVE USAGE
vnoremap <Plug>AlignFirst :call Align('\s*\('.input('delimiter? ').'\)\s*', ' \1 ', ' ', '')<cr>
vnoremap <Plug>AlignAll   :call Align('\s*\('.input('delimiter? ').'\)\s*', ' \1 ', ' ', 'g')<cr>
vnoremap <Plug>AlignLast  :call Align('\s*\('.input('delimiter? ').'\)', ' \1', ' ', 'l')<cr>

" EXAMPLES
" vnoremap \AlignAtAmpersand   :call Align('\s*\(&\)\s*', ' \1 ', ' ', 'g')<cr>
" vnoremap \AlignAtEqual       :call Align('\s*\(=\)\s*', ' \1 ', ' ', 'g')<cr>
" vnoremap \AlignAtBackslash   :call Align('\\\\', '&', ' ', 'l')<cr>

" }}}

