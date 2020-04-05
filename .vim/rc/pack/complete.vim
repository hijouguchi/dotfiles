let s:save_cpo = &cpo
set cpo&vim

let e = packman#config#github#new('prabirshrestha/vim-lsp')
call e.add_hook_events('InsertEnter')
call e.add_depends(
      \   packman#config#github#new('prabirshrestha/async.vim'),
      \   packman#config#github#new('prabirshrestha/asyncomplete.vim'),
      \   packman#config#github#new('prabirshrestha/asyncomplete-lsp.vim')
      \)

function! e.pre_load()
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


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker


