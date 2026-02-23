let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_gitui')
  finish
endif
let g:loaded_gitui = 1

augroup GitUI
  autocmd!
  autocmd FileType gitstatus call gitui#status#setup_buffer() | call gitui#status#setup_syntax()
  autocmd BufEnter * if &l:filetype ==# 'gitstatus' | call gitui#status#refresh(line('.')) | endif
augroup END

command! GitStatus     call gitui#status#open()
command! GitDiff       call gitui#diff#current(0)
command! GitDiffCached call gitui#diff#current(1)
command! GitAdd        call gitui#diff#add_current()
command! GitRestore    call gitui#diff#restore_current()
command! GitBlame      call gitui#diff#blame_current()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
