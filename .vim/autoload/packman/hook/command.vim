" commands 用の hook を登録
let s:save_cpo = &cpo
set cpo&vim

" ダミーコマンドを登録する
function! packman#hook#command#set(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_commands')
    return v:false
  endif

  let id = a:obj.id

  for cmd in a:obj.cfg.hook_commands
    execute 'silent! command -nargs=* -range -bang -bar' cmd
          \ 'call packman#hook#command#execute("'.id.'", "'.cmd.'", <q-bang>, <line1>, <line2>, <q-args>)'
  endfor

  return v:true
endfunction "}}}

" ダミーコマンド実体
function! packman#hook#command#execute(id, cmd, bang, line1, line2, args) abort "{{{
  let obj = packman#get_config(a:id)
  call obj.load()

  " コマンド再実行
  let range = (a:line1 == a:line2) ? '' : a:line1.','.a:line2
  execute range.a:cmd.a:bang a:args
endfunction "}}}

" ダミーコマンドを削除する
" obj.load() のときに呼ぶので execute で呼ばなくて良い
function! packman#hook#command#clear(obj) abort "{{{
  if !has_key(a:obj.cfg, 'hook_commands')
    return
  endif

  for cmd in a:obj.cfg.hook_commands
    execute 'silent! delcommand' cmd
  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
