" .vim/rc/bundle/neocomplete.vim
" Last Change: 2015 Apr 05
" Maintainer:  hijouguchi <taka13.mac+vim@gmail.com>

" FIXME: ファイルだけ補完したい場合はどうすれば？
"        現状 <C-X><C-F> で頑張る

let s:save_cpo = &cpo
set cpo&vim

" NeoBundle 'Shougo/neocomplete.vim'
" NeoBundle 'Shougo/neosnippet.vim'
" NeoBundle 'Shougo/neosnippet-snippets'

NeoBundleLazy 'Shougo/neocomplete.vim', {
      \ 'depends' : [
      \   'Shougo/neosnippet.vim',
      \   'Shougo/neosnippet-snippets'
      \  ],
      \ 'insert' : 1
      \ }


let g:neocomplete#enable_at_startup  = 1
let g:neocomplete#enable_smart_case  = 1
let g:neocomplete#enable_auto_select = 1
let g:neosnippet#snippets_directory  = '~/.vim/snippet'
let g:neocomplete#sources#syntax#min_keyword_length = 2

if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {
        \ 'default' : '\h\w*'
        \ }
endif


inoremap <expr> <Tab>   <SID>InsertTabWrapper()
inoremap <expr> <CR>    <SID>InsertCRWrapper()
"inoremap <expr> <Esc>[Z pumvisible() ? "\<C-P>" : "\<S-Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"
" neocomplete#manual_filename_complete() is outdead
" inoremap <expr> <C-F>   neocomplete#manual_filename_complete()



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

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
