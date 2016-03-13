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

NeoBundleLazy 'Shougo/unite.vim', {
      \   'autoload' : {
      \     'commands' : [ 'Unite' ]
      \   }
      \ }

NeoBundleLazy 'Shougo/vimfiler', {
      \   'depends' : ['Shougo/unite.vim'],
      \   'autoload' : {
      \     'commands' : [ 'VimFilerTab', 'VimFiler', 'VimFilerExplorer' ]
      \   }
      \ }

NeoBundleLazy 'hrsh7th/vim-versions', {
      \   'depends' : ['Shougo/unite.vim'],
      \   'autoload' : {
      \     'commands' : [ 'UniteVersions' ]
      \   }
      \ }


"NeoBundleLazy 'Shougo/unite-help', {
"      \   'depends' : ['Shougo/unite.vim'],
"      \   'autoload' : {
"      \     'commands' : [ 'Unite' ],
"      \   }
"      \ }

" https://github.com/Shougo/unite.vim/wiki/unite-plugins
"nnoremap <C-h>  :<C-u>Unite -start-insert help<CR>

nmap <Space>u [UNITE]
nnoremap [UNTIE] <nop>
nnoremap [UNITE]u :<C-u>Unite -no-split<Space>
nnoremap <silent> [UNITE]f :<C-u>Unite file<CR>
nnoremap <silent> [UNITE]b :<C-u>Unite buffer<CR>

nmap [UNITE]v [UNITE/VCS]
nnoremap [UNITE/VCS] <nop>

nnoremap <silent> [UNITE/VCS]s :<C-u>UniteVersions status:!<CR>
nnoremap <silent> [UNITE/VCS]l :<C-u>UniteVersions log:%<CR>


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
