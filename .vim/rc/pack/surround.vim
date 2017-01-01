let s:save_cpo = &cpo
set cpo&vim



PackManAddLazy 'vim-scripts/surround.vim', {'keymaps': [
      \ '<Plug>Dsurround', '<Plug>Csurround',
      \ '<Plug>VSurround', '<Plug>VgSurround',
      \ ]}

" MEMO: plugin/surround.vim でここがマップされるので
"       あらかじめマップ (しておかないと起きない)
nmap ds  <Plug>Dsurround
nmap cs  <Plug>Csurround

xmap s  <Plug>VSurround
xmap gs <Plug>VgSurround

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
