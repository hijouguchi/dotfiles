let s:save_cpo = &cpo
set cpo&vim

let e = packman#config#github#new('rhysd/vim-clang-format')
call e.set_lazy(v:true)
call e.add_depends(
      \   packman#config#github#new('kana/vim-operator-user')
      \ )

function! e.pre_load()
  augroup MyClangFormat
    autocmd!
    autocmd FileType c,cpp KMapVMap =  <Plug>(operator-clang-format)
    autocmd FileType c,cpp KMapNMap == <Plug>(operator-clang-format)
  augroup END
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
