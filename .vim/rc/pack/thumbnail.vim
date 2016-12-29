let s:save_cpo = &cpo
set cpo&vim


PackManAddLazy 'itchyny/thumbnail.vim', {'commands': ['Thumbnail']}

nnoremap <Space>b :Thumbnail -here<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

