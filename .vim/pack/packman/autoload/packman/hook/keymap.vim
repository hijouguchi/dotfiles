" keymap 用の hook を登録
let s:save_cpo = &cpo
set cpo&vim

" ダミーのキーマップを登録する
function! packman#hook#keymap#set(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_keymaps')
    return v:false
  endif

  let id = a:obj.id

  for key in a:obj.cfg.hook_keymaps
    execute 'map  <expr>' key 'packman#hook#keymap#execute("'.id.'", "\'.key.'")'
    execute 'map! <expr>' key 'packman#hook#keymap#execute("'.id.'", "\'.key.'")'
  endfor

  return v:true
endfunction "}}}

" ダミーのキーマップ
function! packman#hook#keymap#execute(id, key) abort "{{{
  let obj = packman#get_config(a:id)
  call obj.load()

  " キー再入力
  call feedkeys(a:key)
  return ''
endfunction "}}}

" ダミーのキーマップを削除する
" obj.load() のときに呼ぶので execute で呼ばなくて良い
function! packman#hook#keymap#clear(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_keymaps')
    return
  endif

  for key in a:obj.cfg.hook_keymaps
    execute 'unmap'  key
    execute 'unmap!' key
  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
