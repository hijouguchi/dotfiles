" .vim/rc/command.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-13

let s:save_cpo = &cpo
set cpo&vim

command! -bang Utf8  e<bang> ++enc=utf-8
command! -bang Euc   e<bang> ++enc=euc-jp
command! -bang Cp932 e<bang> ++enc=cp932
command! -bang Jis   e<bang> ++enc=iso-2022-jp

command! -bang Unix  e<bang> ++ff=unix
command! -bang Mac   e<bang> ++ff=mac
command! -bang Dos   e<bang> ++ff=dos

command! -nargs=+ -complete=file Diff call <SID>diff_start(<f-args>)

function! s:diff_start(...) abort "{{{
  let fname = expand('%')

  tabnew

  if a:0 == 1
    execute 'edit ' . fname
    execute 'vertical diffsplit ' . a:1
  else
    execute 'edit ' . a:1
    for i in range(1,a:0-1)
      execute 'vertical diffsplit ' . a:000[i]
    endfor
  endif

  return
endfunction "}}}

" カーソル下のハイライトグループを表示する
command! HighlightName call <SID>get_syn_id()

function! s:get_syn_id() "{{{
  let l:id    = synID(line("."), col("."), 1)
  let l:trans = synIDtrans(l:id)
  execute 'highlight ' . synIDattr(l:id, 'name')
  if l:trans != l:id
    execute 'highlight ' . synIDattr(l:trans, 'name')
  end
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
