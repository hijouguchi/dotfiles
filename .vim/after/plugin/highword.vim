if exists("g:loaded_highword")
  finish
endif
let g:loaded_highword = 1

let s:save_cpo = &cpo
set cpo&vim

augroup Highlightword "{{{
  autocmd!
  autocmd BufWinEnter,ColorScheme * call highword#init#colorscheme()
  autocmd WinEnter                * call highword#init#match_pop()
  autocmd WinLeave                * call highword#init#match_push()
augroup END "}}}

nnoremap <silent> * :call highword#exec#add()<CR>*zvzz
nnoremap <silent> # :call highword#exec#del()<CR>

command! HighWordClear call highword#exec#clear()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
