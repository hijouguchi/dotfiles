if exists("g:loaded_subnums")
  finish
endif
let g:loaded_subnums = 1

let s:save_cpo = &cpo
set cpo&vim

command! -range -nargs=+ SubstituteInsertNums <line1>,<line2>call subnums#insertnums(<f-args>)
command! -range -nargs=* SubstituteNums       <line1>,<line2>call subnums#nums(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
