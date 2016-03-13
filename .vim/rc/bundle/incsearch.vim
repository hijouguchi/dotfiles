" .vim/rc/bundle/incsearch.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>


let s:save_cpo = &cpo
set cpo&vim

NeoBundleLazy 'haya14busa/incsearch.vim', {
  \   'autoload' : {
  \     'mappings' : "<Plug>(incsearch-"
  \   }
  \ }

map / <Plug>(incsearch-forward)


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
