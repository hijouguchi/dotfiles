let s:save_cpo = &cpo
set cpo&vim

set complete=.,w,b,u,t,k

inoremap <expr> <Tab>   <SID>InsertTabWrapper("\<C-N>", "\<Tab>")
inoremap <expr> <S-Tab> <SID>InsertTabWrapper("\<C-P>", "\<S-Tab>")
inoremap <expr> <CR>    <SID>InsertCRWrapper()

augroup MyInsertComplete "{{{
  autocmd!
  autocmd FileType * exec 'setlocal dictionary=~/.vim/dict/'.&l:filetype.'.dict'
augroup END "}}}

function! s:InsertTabWrapper(next, tab) "{{{
  if pumvisible()
    return a:next
  elseif getline('.')[col('.')-2] =~ '\k'
    return a:next
  else
    return a:tab
  endif
endfunction "}}}
function! s:InsertCRWrapper() "{{{
  if pumvisible()
    return "\<C-Y>"
  else
    return "\<CR>"
  endif
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
