let s:save_cpo = &cpo
set cpo&vim



PackManAddLazy 'vim-scripts/surround.vim', {'keymaps': ['<Plug>VSurround', '<Plug>VgSurround']}

xmap s  <Plug>VSurround
xmap gs <Plug>VgSurround

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
