let s:save_cpo = &cpo
set cpo&vim

let elm = {'event': ['InsertEnter']}

let g:neocomplete#enable_at_startup  = 1
let g:neocomplete#max_keyword_width  = 30
let g:neocomplete#enable_smart_case  = 1
let g:neocomplete#enable_auto_select = 0
let g:neocomplete#sources#syntax#min_keyword_length = 2
let g:neocomplete#use_vimproc        = 1

if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {
        \ 'default' : '\h\w*'
        \ }
endif

inoremap <expr> <Tab>   <SID>InsertTabWrapper()
inoremap <expr> <CR>    <SID>InsertCRWrapper()
"inoremap <expr> <Esc>[Z pumvisible() ? "\<C-P>" : "\<S-Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"
"inoremap <expr> <C-F>   <SID>FileCompleteWrapper()
inoremap <expr> <C-F>   neocomplete#start_manual_complete('file')

" see also: https://github.com/Shougo/neocomplete.vim/issues/333
" <Plug>(vimrc_bs) is defined by
" .vim/rc/bundle/vim-smartinput.vim (#map_to_triger)
" vim-smartinput が呼ばれたときに再定義される
inoremap <unique> <Plug>(vimrc_bs) <BS>
imap <expr> <C-H> neocomplete#close_popup() . "\<Plug>(vimrc_bs)"
imap <expr> <BS>  neocomplete#close_popup() . "\<Plug>(vimrc_bs)"

imap    <C-K> <Plug>(neosnippet_expand_or_jump)
smap    <C-K> <Plug>(neosnippet_expand_or_jump)

"imap    <C-L> <Plug>(neosnippet_expand)
"smap    <C-L> <Plug>(neosnippet_expand)


PackManAddLazy 'Shougo/neocomplete.vim.git', elm

function! s:InsertTabWrapper() "{{{
  if pumvisible()
    return "\<C-N>"
  elseif getline('.')[col('.')-2] =~ '\k'
    "call neocomplcache#start_manual_complete()
    call neocomplete#start_manual_complete()
    return "\<C-N>"
  else
    return "\<TAB>"
  endif
endfunction "}}}
function! s:InsertCRWrapper() "{{{
  if !pumvisible()
    return "\<CR>"
  " elseif neosnippet#expandable()
  "   return "\<Plug>(neosnippet_expand)"
  else
    return neocomplete#close_popup() . "\<CR>"
  endif
endfunction "}}}
" function! s:FileCompleteWrapper() "{{{
"   call feedkeys(neocomplete#start_manual_complete('file'))
"   return pumvisible() ? '' : "\<C-X>\<C-F>"
" endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
