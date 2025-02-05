
set complete=.,w,b,u,t,k

inoremap <expr> <Tab>   <SID>InsertTabWrapper("\<C-N>", "\<Tab>")
inoremap <expr> <S-Tab> <SID>InsertTabWrapper("\<C-P>", "\<S-Tab>")
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"
nnoremap <expr> <C-K>   <SID>RegisterWordToDictionary()

nnoremap        <C-L><C-D> <plug>(lsp-document-diagnostics)
nnoremap        <C-L><C-R> <plug>(lsp-rename)
nnoremap        <C-L><C-H> <plug>(lsp-hover)
nnoremap <expr> <plug>(lsp-hover-scroll-down) lsp#scroll(+4)
nnoremap <expr> <plug>(lsp-hover-scroll-up)   lsp#scroll(-4)
nnoremap             <C-J> <plug>(lsp-hover-scroll-down)
nnoremap             <C-K> <plug>(lsp-hover-scroll-up)

let g:lsp_diagnostics_enabled                        = 1
let g:lsp_diagnostics_virtual_text_enabled           = 0
let g:lsp_diagnostics_echo_cursor                    = 1
let g:lsp_diagnostics_highlights_insert_mode_enabled = 0
let g:lsp_document_highlight_delay                   = 200
let g:lsp_text_edit_enabled                          = 0

let g:lsp_settings = {
      \  'clangd': {'args': ['--clang-tidy']},
      \  'verible-verilog-ls': {'args': [
      \    '--ruleset=all',
      \    '--rules_config=' .. expand('~/.vim/rc/pack/verible-verilog-ls-rules.conf')
      \  ]},
      \  'efm-langserver': {'disabled': v:false}
      \}

call packman#config#github#new('prabirshrestha/vim-lsp')
      \ .add_depends(
      \   packman#config#github#new('prabirshrestha/async.vim'),
      \   packman#config#github#new('prabirshrestha/asyncomplete.vim'),
      \   packman#config#github#new('prabirshrestha/asyncomplete-lsp.vim'),
      \   packman#config#github#new('mattn/vim-lsp-settings')
      \ )

augroup MyInsertComplete "{{{
  autocmd!
  autocmd FileType * call <SID>LspSetUp()
  "autocmd CursorHold * LspHover
augroup END "}}}

function! s:RegisterWordToDictionary() "{{{
  let word = expand('<cword>')
  let dict = &l:dictionary

  if !filereadable(dict)
    echo dict . ' is not exist...'
    return
  endif

  " 既に登録されてるなら無�  let list = readfile(dict)
  if match(list, word) != -1
    return
  endif

  " 辞書に登録
  if input("Append '" . word . "' to '" . dict . "'? [Yn]: ", 'n', ) == 'Y'
    call writefile([word], dict, "a")
    echo "Appended '" . word . "'"
  endif
endfunction "}}}
function! s:LspSetUp() "{{{
  exec 'setlocal dictionary=~/.vim/dict/'.&l:filetype.'.dict'
  setlocal omnifunc=lsp#complete
endfunction "}}}
function! s:InsertCRWrapper() "{{{
  if pumvisible()
    return "\<C-Y>"
  else
    return "\<CR>"
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

" vim: ts=2 sw=2 sts=2 et fdm=marker


