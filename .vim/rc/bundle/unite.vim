" .vim/rc/bundle/unite.vim
"
" Maintainer: XXX <XXX>
" Last Change: 2015 Apr 05

"if exists("g:loaded_vim_rc_bundle_unite")
"  finish
"endif
"let g:loaded_vim_rc_bundle_unite = 1

let s:save_cpo = &cpo
set cpo&vim

NeoBundleLazy "Shougo/unite.vim", {
      \   'autoload' : {
      \     'commands' : [ "Unite" ]
      \   }
      \ }

NeoBundleLazy 'Shougo/vimfiler', {
      \   'depends' : ["Shougo/unite.vim"],
      \   'autoload' : {
      \     'commands' : [ "VimFilerTab", "VimFiler", "VimFilerExplorer" ]
      \   }
      \ }

NeoBundleLazy 'Shougo/unite-help', {
      \   'depends' : ["Shougo/unite.vim"],
      \   'autoload' : {
      \     'mappings' : "<C-h>"
      \   }
      \ }

" https://github.com/Shougo/unite.vim/wiki/unite-plugins
nnoremap <C-h>  :<C-u>Unite -start-insert help<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
