let s:save_cpo = &cpo
set cpo&vim

set complete=.,w,b,u,t,k

inoremap <expr> <Tab>   <SID>InsertTabWrapper("\<C-N>", "\<Tab>")
inoremap <expr> <S-Tab> <SID>InsertTabWrapper("\<C-P>", "\<S-Tab>")
inoremap <expr> <CR>    <SID>InsertCRWrapper()
nnoremap <expr> <C-K>   <SID>RegisterWordToDictionary()

augroup MyInsertComplete "{{{
  autocmd!
  autocmd FileType * exec 'setlocal dictionary=~/.vim/dict/'.&l:filetype.'.dict'
augroup END "}}}

function! s:RegisterWordToDictionary() "{{{
  let word = expand('<cword>')
  let dict = &l:dictionary

  if !filereadable(dict)
    echo dict . ' is not exist...'
    return
  endif

  " 既に登録されてるなら無視
  let list = readfile(dict)
  if match(list, word) != -1
    return
  endif

  " 辞書に登録
  if input("Append '" . word . "' to '" . dict . "'? [Yn]: ", 'n', ) == 'Y'
    call writefile([word], dict, "a")
    echo "Appended '" . word . "'"
  endif
endfunction "}}}

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
