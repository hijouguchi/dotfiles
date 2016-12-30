if exists("g:loaded_highword")
  finish
endif
let g:loaded_highword = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> * :call highword#add()<CR>*zvzz
nnoremap <silent> # :call highword#del()<CR>

command! HighWordClear call highword#clear()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
