" runtime 向けの config 生成
let s:save_cpo = &cpo
set cpo&vim

" runtime する
function! packman#config#runtime#load_impl() dict "{{{
  execute 'runtime! ' . self.cfg.repo
endfunction "}}}

" update は何もしない
function! packman#config#runtime#update() dict "{{{
endfunction "}}}

" オブジェクトを作る
" 引数は未定
function! packman#config#runtime#new(repo, ...) abort "{{{
  let obj          = call('packman#config#new', a:000)
  let obj.cfg.repo = a:repo

  " クラスメソッドを登録する
  let flist = [
        \ 'load_impl',
        \ 'update'
        \ ]

  for f in flist
    let obj[f] = function('packman#config#runtime#' . f)
  endfor

  return obj
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

