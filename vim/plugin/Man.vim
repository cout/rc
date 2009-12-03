" -*- vim -*-
" FILE: "/home/joze/.vim/autoload/Man.vim"
" LAST MODIFICATION: "Sun, 16 Sep 2001 17:17:32 +0200 (joze)"
" (C) 1999 - 2001 by Johannes Zellner, <johannes@zellner.org>
" $Id$


" PURPOSE:
"   - view UNIX man pages in a split buffer
"   - includes syntax highlighting
"   - works also in gui (checked in gtk-gui)
"
" USAGE:
"   put this file in your ~/.vim/plugin
"
" NORMAL MODE:
"   place the cursor on a keyword, e.g. `sprintf' and
"   hit <Leader>k. The window will get split and the man page
"   for sprintf will be displayed in the new window.
"   The <Leader>k can be preceeded by a `count', e.g. typing
"   2<Leader>k while the cursor is on the keyword `open' would
"   take you to `man 2 open'.
"
" COMMAND MODE:
"   The usage is like if you type it in your shell
"   (except, you've to use a capital `M').
"
"   :Man sprintf
"   :Man 2 open
"
" REQUIREMENTS:
"   man, col, vim version >= 600
"   `col' is used to remove control characters from the `man' output.
"   if `col' is not present on your system, you can set a global variable
"       let g:man_vim_only = 1
"   in your ~/.vimrc. If this variable is present vim filters away the
"   control characters from the man page itself.
"
" GLOBAL VARIABLES:
"   g:man_tmp_file         : name of the temporary file, which is used to
"                            display the man pages.
"   g:man_vim_only         : if present, `col' is not used
"   g:man_section_argument : string which preceedes the section number.
"                            This defaults to `-s' on solaris.
"   g:man_split            : 0: don't split
"                            1: split horizontally
"                            2: split vertically
"
" CREDITS:
"   Adrian Nagle
"   John Spetz
"   Bram Moolenaar
"   Rajesh Kallingal
"   Antonio Colombo
"   Michael Sharpe
"
" LICENSE:
"   BSD type license: http://www.zellner.org/copyright.html
"   if you like this script type :help uganda<Enter>
"
" URL: http://www.zellner.org/vim/autoload/Man.vim

" NOTE: if you're on solaris but don't want "-s" == g:man_section_argument
"       you should set g:man_section_argument to an empty value (or whatever
"       you need) before sourcing this file.
if $OSTYPE == "solaris" && !exists("g:man_section_argument")
    let g:man_section_argument="-s"
endif


if !exists("g:man_split")
    " split vertically by default for version >= 600, use
    "     :let g:man_split = 0
    " if you don't like this
    let g:man_split = 2
endif


" au VimLeave * if filereadable('/_man.tmp') | call delete('/_man.tmp') | endif

fun! Man(cnt, mode, ...)
    if 'map' == a:mode
	if a:cnt == 0
	    if exists('w:manpage_window')
		let save_iskeyword = &iskeyword
		set iskeyword+=(,)
	    endif
	    let page_section = expand("<cword>")
	    if exists('w:manpage_window')
		let &iskeyword = save_iskeyword
	    endif
	    let page = substitute(page_section, '\(\k\+\).*', '\1', '')
	    let section = substitute(page_section, '\(\k\+\)(\([^()]*\)).*', '\2', '')
	    if -1 == match(section, '^[0-9 ]\+$')
		let section = ""
	    endif
	    if section == page
		let section = ""
	    endif
	else
	    let section = a:cnt
	    let page = expand("<cword>")
	endif
    else " cmdln == mode
	if a:0 >= 2
	    let section = a:1
	    let page = a:2
	elseif a:0 >= 1
	    let section = ""
	    let page = a:1
	else
	    return
	endif
	if "" == page
	    return
	endif
    endif
    call <SID>ManPrep(section, page)
endfun

fun! <SID>ManPrep(section, page)
    if 0 == a:section || "" == a:section
	let section = ""
    elseif 9 == a:section
	let section = 0
    else
	let section = a:section
    endif

    " why can't we open /dev/null ?
    "let tmp = "/dev/null"

    let current = ScratchBuffer('manpage_window', g:man_split, 1)

    " Some platforms require an argument to specify the section number
    if exists("g:man_section_argument") && section != ""
	let section = g:man_section_argument.' '.section
    endif

    if exists("g:man_vim_only")
	0put=system('man '.section.' '.a:page)
	" col is not present. So we let vim filter away
	" the control characters. hope this works on
	" all systems.
	exe "%s/_\<c-h>\\(.\\)/\\1/ge"
	exe "%s/\\(.\\)\<c-h>\\(.\\)/\\1/ge"
    else
	" do we really need to redirect stderr ?
	" exe 'read !man '.section.' '.a:page.' | col -b 2>/dev/null'
	0put=system('man '.section.' '.a:page.' \| col -b')
    endif

    " go to start of manpage
    0
    " strip the blank lines from the top of the page
    " suggested by Michael Sharpe <msharpe@bmc.com>
    let firstLine = getline(1)
    while firstLine == ""
	:delete _
	let firstLine = getline(1)
    endwhile

    setlocal ft=man
    if 2 == g:man_split
	call ScratchBufferFinish(current)
    else
	call ScratchBufferFinish(current, 'min')
    endif
endfun

if exists('g:autoload') | finish | endif " used by the autoload generator

nnoremap <silent> <Plug>ManPage :<c-u>call Man(v:count, 'map')<cr>
if !hasmapto('<Plug>ManPage', 'n')
    map <unique> <Leader>k <Plug>ManPage
endif

command! -nargs=* Man call Man(0, 'cmdln', <f-args>)

