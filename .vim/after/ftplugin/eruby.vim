" .vim/after/ftplugin/eruby.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

let s:save_cpo = &cpo
set cpo&vim

let s:fts = split(&l:filetype, '\.')
let s:targ = len(s:fts) == 1 ? 'quickrun' : s:fts[1]

let b:quickrun_config = {
      \   'command'                   : 'erb',
      \   'cmdopt'                    : '-T -',
      \   'outputter/buffer/filetype' : s:targ
      \ }


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
