" vim: ts=2 sw=2 sts=2 et fdm=marker
source ~/.vim/rc/common/keymap.vim

function! s:MyCmdLineWrapper(...) abort "{{{
  if getcmdtype() =~ '[/?]'
    return a:2
  elseif getcmdline() =~? '\<s\(ubstitute\)\?/'
    return a:3
  else
    return a:1
  endif
endfunction "}}}
cnoremap <expr> <CR> <SID>MyCmdLineWrapper("\<CR>", "\<CR>zvzz", "\<CR>")

tnoremap <C-W>p    <C-W>:call term_sendkeys(bufnr('%'), getreg())<CR>

