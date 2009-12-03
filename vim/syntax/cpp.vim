source $VIMRUNTIME/syntax/cpp.vim
" runtime syntax/cpp.vim

syn match cppOperator "\(||\|&&\)"

" TODO: this doesn't work?
" syn keyword aceTodo contained @@todo
" syn keyword aceTodo @@todo
" hi def link aceTodo Todo

syn keyword     cTodo           contained TODO FIXME XXX @@todo

