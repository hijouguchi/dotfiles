let s:save_cpo = &cpo
set cpo&vim



call packman#config#github#new('vim-scripts/surround.vim')
      \ .add_hook_keymaps(
      \   '<Plug>Dsurround', '<Plug>Csurround',
      \   '<Plug>VSurround', '<Plug>VgSurround'
      \ )

" MEMO: plugin/surround.vim でここがマップされるので
"       あらかじめマップ (しておかないと起きない)
nmap ds  <Plug>Dsurround
nmap cs  <Plug>Csurround

xmap s  <Plug>VSurround
xmap gs <Plug>VgSurround

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
