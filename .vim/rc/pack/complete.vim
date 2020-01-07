let s:save_cpo = &cpo
set cpo&vim

let elm = #{
      \ depends: [
      \   'prabirshrestha/async.vim',
      \   'prabirshrestha/asyncomplete.vim',
      \   'prabirshrestha/asyncomplete-lsp.vim'
      \ ]
      \ }

function! elm.pre_load()
  let g:lsp_diagnostics_enabled = 0
  "let g:lsp_log_verbose = 1
  "let g:lsp_log_file = expand('~/vim-lsp.log')
  "let g:asyncomplete_log_file = expand('~/asyncomplete.log')

  if executable('solargraph')
    " gem install solargraph
    au User lsp_setup call lsp#register_server({
          \ 'name': 'solargraph',
          \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
          \ 'initialization_options': {"diagnostics": "true"},
          \ 'whitelist': ['ruby'],
          \ })
  endif

  if executable('clangd')
    au User lsp_setup call lsp#register_server({
          \ 'name': 'clangd',
          \ 'cmd': {server_info->['clangd', '-background-index']},
          \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
          \ })
  endif
endfunction

PackManAdd 'prabirshrestha/vim-lsp', elm

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker


