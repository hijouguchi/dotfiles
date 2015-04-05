NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 2

if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {
        \ 'default' : '\h\w*'
        \ }
endif


inoremap <expr> <Tab>   <SID>InsertTabWrapper()
inoremap <expr> <CR>    <SID>InsertCRWrapper()
"inoremap <expr> <Esc>[Z pumvisible() ? <C-P> : <S-Tab>
inoremap <expr> <S-Tab> pumvisible() ? <C-P> : <S-Tab>
inoremap <expr> <C-F>   neocomplete#manual_filename_complete()

imap    <C-K> <Plug>(neosnippet_expand_or_jump)
smap    <C-K> <Plug>(neosnippet_expand_or_jump)

imap    <C-L> <Plug>(neosnippet_expand)
smap    <C-L> <Plug>(neosnippet_expand)

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
  if neosnippet#expandable()
    return "\<Plug>(neosnippet_expand)"
  elseif pumvisible()
    "call neocomplcache#close_popup()
    call neocomplete#close_popup()
    return "\<CR>"
  else
    return "\<CR>"
  endif
endfunction "}}}

" vim: ts=2 sw=2 sts=2 et
