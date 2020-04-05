let s:save_cpo = &cpo
set cpo&vim

let s:during_setup = v:false

" PackMan のコンフィグ設定を開始する
" packman#begin() ~ packman#end() の間で
" 各種設定を作ること
function! packman#begin() abort "{{{
  if !exists('g:packman_default_directory')
    let g:packman_default_directory = $HOME.'/.vim/pack/packman/opt'
  endif

  let s:during_setup = v:true
  let s:list = []
  call packman#command#prepare_commands()
  call packman#hook#timer#setup()
endfunction "}}}

" list に config を登録する
" @param [in] cfg packman#new で作ったオブジェクト
" @return 登録した時の id
" @memo new 側の関数で明示的に push するので特に登録しなくて良い
function! packman#push(cfg) abort "{{{
  if s:during_setup == v:false
    throw 'Please Called packman#begin() before creaing the package confituration'
    return
  endif

  let id = len(s:list) " 登録順に id を振る
  call add(s:list, a:cfg)
  return id
endfunction "}}}

" PackMan のコンフィグ設定を終了してプラグインをロードする
" packman#init@begin() ~ packman#end() の間で
" 各種設定を作ること
function! packman#end() abort "{{{
  if s:during_setup == v:false
    throw 'Please Called packman#begin() before calling packman#end()'
    return
  endif

  let s:during_setup = v:false

  for obj in s:list
    call obj.try_load()
  endfor

  call packman#hook#timer#invoke()
endfunction "}}}

" list そのものを返す
function! packman#get_configs() abort "{{{
  return copy(s:list)
endfunction "}}}

" list から config を取得する
" @param [in] id config id
" @return id に対応する config
function! packman#get_config(id) abort "{{{
  return s:list[a:id]
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
