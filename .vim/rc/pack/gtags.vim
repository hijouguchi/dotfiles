let s:save_cpo = &cpo
set cpo&vim

call packman#config#github#new('vim-scripts/gtags.vim')
      \ .add_hook_commands('Gtags', 'GtagsCursor')

nnoremap <expr> <space>gt ':Gtags '   .expand('<cword>')."\<CR>"
nnoremap <expr> <space>gr ':Gtags -r '.expand('<cword>')."\<CR>"
nnoremap <expr> <space>gs ':Gtags -s '.expand('<cword>')."\<CR>"
nnoremap <expr> <space>gf ':Gtags -f '.expand('<cword>')."\<CR>"
nnoremap <expr> <space>gg ':Gtags -g '.expand('<cword>')."\<CR>"

nnoremap <expr> <C-]> <SID>TagSearch()

function! s:TagSearch() "{{{
  if &l:ft != 'help' && filereadable('GPATH')
    return ':Gtags '.expand('<cword>')."\<CR>"
  else
    return "\<C-]>"
  endif
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

