let s:save_cpo = &cpo
set cpo&vim


let g:submode_always_show_submode = 1

PackManAdd 'kana/vim-submode.git'

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


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
