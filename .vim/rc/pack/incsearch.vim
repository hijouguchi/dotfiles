let s:save_cpo = &cpo
set cpo&vim

PackManAddLazy 'haya14busa/incsearch.vim', {'keymaps': ['<Plug>(incsearch-forward)']}

map / <Plug>(incsearch-forward)


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

