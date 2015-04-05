" .vim/rc/bundle/vim-template.vim
" Last Change: 2015 Apr 05
" Maintainer:  hijouguchi <taka13.mac+vim@gmail.com>

let s:save_cpo = &cpo
set cpo&vim

NeoBundle 'thinca/vim-template'

let s:bundle = neobundle#get('vim-template')
function! s:bundle.hooks.on_source(bundle)
	autocmd User plugin-template-loaded
        \ silent %s/<%=\(.\{-}\)%>/\=eval(submatch(1))/ge
  autocmd User plugin-template-loaded
        \    if search('<+CURSOR+>')
        \  |   execute 'normal! "_da>'
        \  | endif
endfunction
unlet s:bundle

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
