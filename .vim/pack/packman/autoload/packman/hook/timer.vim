" timer 用の hook を登録
let s:save_cpo = &cpo
set cpo&vim

function! packman#hook#timer#setup() abort "{{{
  let s:timer_list       = []
  let s:timer_loaded_pos = 0

  if !exists('g:packman_delay_load_time')
    let g:packman_delay_load_time = 10
  endif
endfunction "}}}

" タイマーリストに登録する
function! packman#hook#timer#set(obj) abort "{{{
  if !get(a:obj.cfg, 'lazy', v:false)
    return v:false
  endif

  call add(s:timer_list, a:obj.id)
  return v:true
endfunction "}}}

" タイマー実体
function! packman#hook#timer#execute(...) abort "{{{
  let id  = s:timer_list[s:timer_loaded_pos]
  let s:timer_loaded_pos += 1

  let obj = packman#get_config(id)
  call obj.load()
endfunction "}}}

" タイマーを登録する
function! packman#hook#timer#invoke() abort "{{{
  let len = len(s:timer_list)

  if len > 0
    call timer_start(g:packman_delay_load_time,
          \ 'packman#hook#timer#execute', {'repeat': len})
  endif
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
