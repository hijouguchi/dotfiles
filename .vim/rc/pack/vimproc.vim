let s:save_cpo = &cpo
set cpo&vim

let e = packman#config#github#new('Shougo/vimproc.vim')

function! e.post_install_func()
  if !has('win32') && !has('win32unix')
    call system('cd '.self.dir.' && make')
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
