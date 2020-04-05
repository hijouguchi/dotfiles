let s:save_cpo = &cpo
set cpo&vim

let e = packman#config#github#new('thinca/vim-template')

function! e.pre_load()
  autocmd User plugin-template-loaded
        \ silent %s/<%=\(.\{-}\)%>/\=eval(submatch(1))/ge
  autocmd User plugin-template-loaded
        \    if search('<+CURSOR+>')
        \  |   execute 'normal! "_da>'
        \  | endif
  autocmd User plugin-template-loaded setlocal nomodified
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
