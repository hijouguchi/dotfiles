" .vim/rc/bundle/vcscommand.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>

NeoBundle 'vcscommand.vim'

let s:save_cpo = &cpo
set cpo&vim



let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
