" .vim/rc/bundle/thumbnail.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

let s:save_cpo = &cpo
set cpo&vim

NeoBundleLazy 'itchyny/thumbnail.vim', {'commands' : 'Thumbnail'} " depened by rc/keymap.vim

nnoremap <Space>b :Thumbnail -here<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
