" .vim/rc/bundle/lightline.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-11


let s:save_cpo = &cpo
set cpo&vim

NeoBundle 'itchyny/lightline.vim'

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
