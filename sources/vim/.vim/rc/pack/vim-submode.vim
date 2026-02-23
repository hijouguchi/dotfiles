let s:save_cpo = &cpo
set cpo&vim


let g:submode_always_show_submode = 1

let e = packman#config#github#new('kana/vim-submode.git')

function! e.post_load() abort
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

  call submode#enter_with('QuickFix', 'n', '', '<Space>qj', ':<C-U>cn<CR>')
  call submode#enter_with('QuickFix', 'n', '', '<Space>qk', ':<C-U>cp<CR>')
  call submode#map('QuickFix', 'n', '', 'j', ':<C-U>cn<CR>')
  call submode#map('QuickFix', 'n', '', 'k', ':<C-U>cp<CR>')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
