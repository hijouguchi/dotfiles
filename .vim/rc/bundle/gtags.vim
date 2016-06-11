" /Users/hijouguchi/.vim/rc/bundle/gtags.vim
"
" Maintainer: XXX <XXX>
" Last Change: 2015 Apr 05

"if exists("g:loaded_#Users#hijouguchi#.vim#rc#bundle#gtags")
"  finish
"endif
"let g:loaded_#Users#hijouguchi#.vim#rc#bundle#gtags = 1

let s:save_cpo = &cpo
set cpo&vim


NeoBundleLazy 'vim-scripts/gtags.vim', {
      \   'autoload' : {
      \     'commands' : [ 'Gtags', 'GtagsCursor' ]
      \   }
      \ }

nnoremap <expr> <space>gt ':Gtags '   .expand('<cword>')."\<CR>"
nnoremap <expr> <space>gr ':Gtags -r '.expand('<cword>')."\<CR>"
nnoremap <expr> <space>gf ':Gtags -f '.expand('<cword>')."\<CR>"
nnoremap <expr> <space>gg ':Gtags -g '.expand('<cword>')."\<CR>"


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
