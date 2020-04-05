" event 用の hook を登録
let s:save_cpo = &cpo
set cpo&vim

" ダミーのオードコマンドを登録する
function! packman#hook#event#set(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_events')
    return v:false
  endif

  let id = a:obj.id

  execute 'augroup' s:get_event_name(a:obj)
    autocmd!
    for eve in a:obj.cfg.hook_events
      execute 'autocmd' eve '* call packman#hook#event#execute("'.id.'")'
    endfor
  augroup END

  return v:true
endfunction "}}}

" ダミーのオートコマンド
function! packman#hook#event#execute(id) abort "{{{
  let obj = packman#get_config(a:id)
  call obj.load()

  " 特に何もしなくても良さそう？
endfunction "}}}

" ダミーのオートコマンドを削除する
" obj.load() のときに呼ぶので execute で呼ばなくて良い
function! packman#hook#event#clear(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_events')
    return
  endif

  silent! execute 'silent! autocmd!' s:get_event_name(a:obj)
endfunction "}}}

" イベント名を返す
function! s:get_event_name(obj) "{{{
  let repo = a:obj.cfg.repo
  return substitute(repo, '^.*\/', 'packman-hook-', '')
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
