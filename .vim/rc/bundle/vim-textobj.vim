" vim-textobj.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-11

NeoBundle 'kana/vim-textobj-user.git'
NeoBundle 'sgur/vim-textobj-parameter.git'

let s:save_cpo = &cpo
set cpo&vim



let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
