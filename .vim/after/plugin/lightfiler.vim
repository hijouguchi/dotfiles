" plugin/lightfiler.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-26

" if exists("g:loaded_lightfiler")
"   finish
" endif
" let g:loaded_lightfiler = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -complete=file LightFiler :call lightfiler#setup(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
