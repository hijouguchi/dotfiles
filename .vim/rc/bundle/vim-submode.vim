" .vim/rc/bundle/vim-submode.vim
" Last Change: 2015 Apr 05
" Maintainer:  hijouguchi <taka13.mac+vim@gmail.com>

let s:save_cpo = &cpo
set cpo&vim

" NeoBundle 'kana/vim-submode.git'

NeoBundleLazy 'kana/vim-submode.git', {'mappings' : '<C-W>'}

let s:bundle = neobundle#get('vim-submode')
function! s:bundle.hooks.on_source(bundle)
  call submode#enter_with('Window', 'n', '', '<C-W>+')
  call submode#enter_with('Window', 'n', '', '<C-W>-')
  call submode#enter_with('Window', 'n', '', '<C-W>>')
  call submode#enter_with('Window', 'n', '', '<C-W><')
  call submode#leave_with('Window', 'n', '', '<Esc>')
  call submode#map('Window', 'n', '', '-', '<C-W>-')
  call submode#map('Window', 'n', '', '=', '<C-W>+')
  call submode#map('Window', 'n', '', '+', '<C-W>+')
  call submode#map('Window', 'n', '', '<', '<C-W><')
  call submode#map('Window', 'n', '', '>', '<C-W>>')
endfunction
unlet s:bundle

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
