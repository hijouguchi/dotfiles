if exists("g:loaded_highword")
  finish
endif
let g:loaded_highword = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> * :call highword#add()<CR>*zvzz
nnoremap <silent> # :call highword#delete()<CR>

command! HighWordClear  call highword#clear()
command! HighWordList   call highword#show_list()
command! -nargs=* -complete=customlist,highword#word_complete HighWordDelete call highword#delete(<f-args>)
command! -nargs=* HighWordAdd call highword#add(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
