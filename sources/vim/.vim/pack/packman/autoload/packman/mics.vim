" デバッグ関係の関数を定義
" 初期化関数の定義
let s:save_cpo = &cpo
set cpo&vim

" 何もしない
function! packman#mics#nop(...) abort "{{{
endfunction "}}}

" echo
function! packman#mics#echo(msg) abort "{{{
  "if !v:vim_did_enter
  "  redraw
  "endif

  let str = '[packman] ' . string(a:msg)
  echom str
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
