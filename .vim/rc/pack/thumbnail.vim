let s:save_cpo = &cpo
set cpo&vim


let e = packman#config#github#new('itchyny/thumbnail.vim')
call e.add_hook_commands('Thumbnail')

nnoremap <Space>b :Thumbnail -here<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

