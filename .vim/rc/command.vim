" .vim/rc/command.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-06

let s:save_cpo = &cpo
set cpo&vim

command! -bang Utf8  e<bang> ++enc=utf-8
command! -bang Euc   e<bang> ++enc=euc-jp
command! -bang Cp932 e<bang> ++enc=cp932
command! -bang Jis   e<bang> ++enc=iso-2022-jp

command! -bang Unix  e<bang> ++ff=unix
command! -bang Mac   e<bang> ++ff=mac
command! -bang Dos   e<bang> ++ff=dos


" カーソル下のハイライトグループを表示する
command! HighlightName
      \    execute 'highlight ' . synIDattr(<SID>get_syn_id(0), 'name')
      \  | execute 'highlight ' . synIDattr(<SID>get_syn_id(1), 'name')

function! s:get_syn_id(trans)
  let l:synid = synID(line('.'), col('.'), 1)
  return a:trans ? synIDtrans(l:synid) : l:synid
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
