let s:save_cpo = &cpo
set cpo&vim

let elm = {}

function! elm.pre_load()
  autocmd User plugin-template-loaded
        \ silent %s/<%=\(.\{-}\)%>/\=eval(submatch(1))/ge
  autocmd User plugin-template-loaded
        \    if search('<+CURSOR+>')
        \  |   execute 'normal! "_da>'
        \  | endif
  autocmd User plugin-template-loaded setlocal nomodified
endfunction

PackManAddLazy 'thinca/vim-template', elm

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
