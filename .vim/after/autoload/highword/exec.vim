
let s:save_cpo = &cpo
set cpo&vim

function! highword#exec#add() abort "{{{
  " TODO: 大文字小文字無視する・しないを選べるようにしとくべき
  let word = expand('<cword>')
  let mat  = '\<' . word . '\>\C'

  let ma = filter(getmatches(),
        \ {idx, val -> val.group =~ '^HighWord\d\+$' && val.pattern ==# mat })

  echo ma
  if !empty(ma)
    return
  endif

  let hlname = s:get_hlname_minimum()


  let wnr = winnr()
  windo call matchadd(hlname, mat)
  execute wnr . 'wincmd w'

endfunction "}}}
function! highword#exec#del() abort "{{{
  let word = expand('<cword>')
  let mat  = '\<' . word . '\>\C'

  let wnr = winnr()
  windo call s:delete_highlight(mat)
  execute wnr . 'wincmd w'
endfunction "}}}
function! highword#exec#clear() abort "{{{
  let wnr = winnr()
  windo call s:delete_highlight()
  execute wnr . 'wincmd w'

endfunction "}}}

function! s:get_hlname_minimum() abort "{{{
  let matches = map(getmatches(), {idx, val -> val.group} )

  let cnt = 100
  let str = ''

  for i in range(12)
    let targ = 'HighWord'.i
    let tmp  = count(matches, targ)

    if tmp < cnt
      let cnt = tmp
      let str = targ
    endif
  endfor

  return str
endfunction "}}}
function! s:delete_highlight(...) abort "{{{
  " 引数無し: すべて
  " 引数有り: pattern が一致した物
  if a:0 > 0
    let ma = filter(getmatches(),
          \ {idx, val -> val.group =~ '^HighWord\d\+$' && val.pattern ==# a:1 })
  else
    let ma = filter(getmatches(),
          \ {idx, val -> val.group =~ '^HighWord\d\+$' })
  endif
  for m in ma
    call matchdelete(m.id)
  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
