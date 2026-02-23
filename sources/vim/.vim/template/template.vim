" <%= expand('%') %>
"
" Maintainer: XXX <XXX>
" Last Change: 2015 Apr 05

if exists("g:loaded_<%= substitute(expand('%:r'), '/', '#', 'g') %>")
  finish
endif
let g:loaded_<%= substitute(expand('%:r'), '/', '#', 'g') %> = 1

let s:save_cpo = &cpo
set cpo&vim

<+CURSOR+>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
