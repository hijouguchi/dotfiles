let s:save_cpo = &cpo
set cpo&vim

let elm = {'keymaps': ['<C-W>'] }

function! elm.post_func()
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


PackManAddLazy 'kana/vim-submode.git', elm


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
