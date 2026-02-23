" Return the mapping result based on cmdline type:
" search (/ or ?), substitute, or other command.
function! cmdline#enter_by_cmdtype(default, search, substitute) abort
  if getcmdtype() =~ '[/?]'
    return a:search
  elseif getcmdline() =~? '\<s\(ubstitute\)\?/'
    return a:substitute
  else
    return a:default
  endif
endfunction

" vim: ts=2 sw=2 sts=2 et fdm=marker
