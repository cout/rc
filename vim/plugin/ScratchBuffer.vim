" -*- vim -*-
" FILE: "/home/joze/.vim/autoload/ScratchBuffer.vim"
" LAST MODIFICATION: "Sun, 16 Sep 2001 17:17:32 +0200 (joze)"
" (C) 2001 by Johannes Zellner, <johannes@zellner.org>
" $Id$

if exists('g:ScratchBuffer_loaded') | finish | endif
let g:ScratchBuffer_loaded = 1

" PURPOSE:
"   create a Scratch Buffer, just a helper function for other plugins
"
" USAGE:
"   put this file in your ~/.vim/plugin
"
" LICENSE:
"   BSD type license: http://www.zellner.org/copyright.html
"   if you like this script type :help uganda<Enter>
"
" URL: http://www.zellner.org/vim/autoload/ScratchBuffer.vim
"
" TODO:
" - don't resize if only one window (the ScratchBuffer) is there

augroup ScratchBuffer
    au!
    " au BufUnload * call confirm('id('.expand("<abuf>").')='.getbufvar(expand("<abuf>"), 'scratchbuffer_id'), '&ok')
    au BufUnload * call <SID>ScratchBufferUnload(expand("<abuf>") + 0)
augroup END

" returns current window number wich must
" be passed to ScratchBufferFinish().
"
" PARAMETERS:
"
" id: unique "string" id
"
" split:
"     0 -- don't split
"     1 -- split horizontally
"     2 -- split vertically
"
" clear: if the buffer should be cleared, if it
"        already exists (usually set to 1)
"
fun! ScratchBuffer(id, split, clear)
    if '' == a:id
	echohl ErrorMsg | echo "ScratchBuffer: id must be non-empty" | echohl NONE
	return
    endif
    " save current window nr
    let current = winnr()
    " look for existing scratch buffer
    let winnr = -1
    exe 'let id = "w:'.a:id.'"'
    windo if exists(id) | let winnr = winnr() | endif

    if -1 == winnr
	" create new scratch buffer
	if 0 == a:split
	    enew
	elseif 1 == a:split
	    new
	else
	    vertical new
	endif

	exe 'let '.id.' = '.a:split
	let b:scratchbuffer_id = id
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal nobuflisted
	setlocal report=999999
	setlocal noswapfile
    else
	" use existing scratch buffer
	call ScratchBufferWritable()
	if 1 == a:clear
	    %d _ " delete old scratchbuffer
	endif
    endif
    return current
endfun

fun! ScratchBufferFinish(winnr, ...)
    setlocal nomodified
    setlocal nomodifiable
    setlocal readonly
    if 0 != a:0
	let min = 0
	let i = 1
	" parse options (currently only 'min')
	while i <= a:0
	    exe 'let opt = a:'.i
	    if 'min' == opt || 'minimize' == opt
		let min = 1
	    endif
	    let i = i + 1
	endwhile
	if 1 == min
	    " minimize window
	    let bufheight = line('$')
	    let winheight = winheight('.')
	    if bufheight < winheight
		exe 'resize '.bufheight
	    endif

	    " align at top
	    let line = line('.')
	    1
	    normal zt
	    exe line
	endif
    endif
    call <SID>ScratchBufferGotoWindow(a:winnr)
endfun

fun! ScratchBufferRegisterCallback(callback)
    let b:scratchbuffer_callback = a:callback
endfun

fun! ScratchBufferWritable()
    setlocal noreadonly
    setlocal modifiable
endfun

fun! <SID>ScratchBufferGotoWindow(winnr)
    if a:winnr > 0 && a:winnr != winnr()
	" go back to saved window (if we're not already in it)
	exe a:winnr.'wincmd W'
    endif
endfun

fun! <SID>ScratchBufferUnload(bufnr)
    " return
    " call confirm('(ScratchBufferUnload) bufnr='.a:bufnr, '&ok')
    " call confirm('(ScratchBufferUnload) bufname()='.bufname(a:bufnr), '&ok')
    " require a scratch buffer
    if '' == bufname(a:bufnr)
	let id = getbufvar(a:bufnr, 'scratchbuffer_id')
	" call confirm('(ScratchBufferUnload) id=|'.id.'|', '&ok')
	if '' != id
	    " call confirm('(ScratchBufferUnload) b:scratchbuffer_id='.id, '&ok')
	    let callback = getbufvar(a:bufnr, 'scratchbuffer_callback')
	    if '' != callback
		" call confirm('(ScratchBufferUnload) b:scratchbuffer_callback='.callback, '&ok')
		exe 'call '.callback
		call setbufvar(a:bufnr, 'scratchbuffer_callback', '')
	    endif
	    " call confirm('(ScratchBufferUnload) '.a:bufnr, '&ok')
	    call setbufvar(a:bufnr, 'scratchbuffer_id', '')

	    " remove 'id'. We've to cycle over all windows
	    " as we don't know in which window the id is defined.
	    let winnr = winnr() " save current window
	    exe 'windo if exists("'.id.'") | unlet '.id.' | endif'
	    call <SID>ScratchBufferGotoWindow(winnr) " restore window
	endif
    endif
endfun
