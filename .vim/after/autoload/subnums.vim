if !exists("g:loaded_subnums")
  runtime! plugin/subnums.vim
endif
let s:save_cpo = &cpo
set cpo&vim

function! subnums#insertnums(...) range "{{{
  if a:0 == 1
    let num_first = 0
    let num_last  = a:1 - 1
    let num_incr  = 1
  elseif a:0 == 2
    let num_first = a:1
    let num_last  = a:2
    let num_incr  = (num_first <= num_last) ? 1 : -1
  elseif a:0 == 3
    let num_first = a:1
    let num_last  = a:3
    let num_incr  = a:2
  else
    echoerr ":SubstituteInsertNums [start] [incr] [last]"
  endif

  let lines = getline(a:firstline, a:lastline)
  " 元の行を削除する
  call cursor(a:firstline, 1)
  execute a:firstline. ',' . a:lastline . 'd _'
  let now_num = a:firstline - 1

  if !exists("g:subnums_patterns")
    call s:default_patterns()
  endif

  for i in range(num_first, num_last, num_incr)
    let ltmp = copy(lines)

    for j in range(0, len(ltmp)-1)
      let ltmp[j] = s:substitute(ltmp[j], i)
    endfor

    call append(now_num, ltmp)
    let now_num = now_num + len(ltmp)
  endfor
endfunction "}}}
function! subnums#nums(...) range "{{{
  let col  = col('.')
  let idx  = (a:0 >= 1) ? a:1 : 0
  let incr = (a:0 >= 2) ? a:2 : 1

  if !exists("g:subnums_patterns")
    call s:default_patterns()
  endif

  for i in range(a:firstline, a:lastline)
    call cursor(i, col)
    let str_cur = getline('.')
    let str_sub = s:substitute(str_cur, idx)

    if str_cur != str_sub
      call setline(line('.'), str_sub)
      let idx = idx + incr
    endif
  endfor
endfunction "}}}

function! s:default_patterns() abort "{{{
  let g:subnums_patterns = [
        \ {'pat': 'XXX',             'str': '"%d"'},
        \ {'pat': '_\(%\d*[dxX]\)_', 'str': 'submatch(1)'},
        \ ]
endfunction "}}}
function! s:substitute(str, idx) abort "{{{
  let str = a:str

  for pats in g:subnums_patterns
    let str = substitute(str, pats.pat,
          \ '\=printf(' . pats.str . ', ' . a:idx . ')', 'g')
  endfor

  return str
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
