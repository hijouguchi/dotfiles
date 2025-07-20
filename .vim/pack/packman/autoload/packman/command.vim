" お万度を用意する
let s:save_cpo = &cpo
set cpo&vim

" utility 関数を準備する
function! packman#command#prepare_commands()  abort "{{{
  command!            PackManUpdate  call packman#command#updates()
  command!            PackManList    call packman#command#list()
  "command!            PackManCleanup call packman#cleanup()
  command! -nargs=1 -complete=customlist,packman#command#load_complete
        \             PackManLoad    call packman#command#load(<q-args>)
endfunction "}}}

" ロード済みのパッケージをアップデートする
function! packman#command#updates() abort "{{{
  for obj in packman#get_configs()
    if obj.loaded()
      call obj.update()
    endif
  endfor
endfunction "}}}

" PackMan で登録しているパッケージ一覧を表示する
function! packman#command#list() abort "{{{
  for obj in packman#get_configs()
    let l = obj.loaded() ? '*' : ' '
    let n = obj.cfg.repo
    echo l n
  endfor
endfunction "}}}

" PackMan でまだロードしていない repo の一覧を返す
function! packman#command#load_complete(ArgLead, CmdLine, CursorPos) abort "{{{
  return copy(packman#get_configs())
        \ ->filter({_, v -> !v.loaded() && !v.depended() })
        \ ->map(   {_, v -> v.repo() })
endfunction "}}}

" PackMan でロードする
function! packman#command#load(repo) abort "{{{
  let objs = copy(packman#get_configs())
        \ ->filter({_, v -> v.repo() == a:repo })

  for obj in objs
    call obj.load()
  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
