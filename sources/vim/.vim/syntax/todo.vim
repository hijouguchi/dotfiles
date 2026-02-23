" Vim syntax file
" Language:	todo.txt
" Maintainer:	hijouguchi

" quit when a syntax file was already loaded
if exists("b:current_syntax")
   finish
endif

" Completed Task. start from "x"
syn match todoDone '^\s*\<x\>.*$'

" Priority eg: (A)
syn match todoPriority "^\s*(\zs\u\ze)"

" Date eg: YYYY-MM-DD
syn match todoDate '\<\d\{4}-\d\{2}-\d\{2}\>'

"Context eg: @phone
syn match todoContext '\%(\s\+\|^\)\zs@\k\+\>'

"Project eg: +phone
syn match todoProject '\%(\s\+\|^\)\zs+\k\+\>'

" key:value
syn match todoKeyValue '\<\k\+\>:\<\k\+\>'

hi def link todoDone     Comment
hi def link todoPriority Type
hi def link todoDate     Number
hi def link todoContext  Constant
hi def link todoProject  Type
hi def link todoKeyValue Identifier

let b:current_syntax = "todo"
