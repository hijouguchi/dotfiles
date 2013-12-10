" Usage
" :SubstituteInsertNums <start> <end>
"   選択行のパターンを置換して，行を追加していく
"
" int fooXXX = XXX; (:SubstituteInsertNums 2 5)
" int foo2 = 2;
" int foo3 = 3;
" int foo4 = 4;
" int foo5 = 5;
"
" int foo_%02x_ = XXX; (:SubstituteInsertNums 41 43)
" int foo29 = 41;
" int foo2a = 42;
" int foo2b = 43;
"
" :SubstituteNums <start> <end>
"   複数行のパターンを置換
"
" int a = XXX;
" int b = XXX; (:SubstituteNums 2)
" int a = 2;
" int b = 3;
"
if exists("g:loaded_substitute_insert_nums")
  finish
endif
let g:loaded_substitute_insert_nums = 1


if !exists("g:substitite_insert_nums_patterns")
  let g:substitite_insert_nums_patterns = [
        \ {'type': 'char',    'pat': 'XXX', 'str': '%d'},
        \ {'type': 'pattern', 'pat': '_\(%\d*[dxX]\)_'},
        \ ]
endif

if !exists(":SubstituteInsertNums")
  command -range -nargs=+ SubstituteInsertNums <line1>,<line2>call SubstituteInsertNums(<f-args>)
endif

if !exists(":SubstituteNums")
  command -range -nargs=* SubstituteNums       <line1>,<line2>call SubstituteNums(<f-args>)
endif

function! SubstituteInsertNums(...) range "{{{
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

  echo [num_first, num_last, num_incr]
  let lines = getline(a:firstline, a:lastline)

  " 元の行を削除する
  call cursor(a:firstline, 0)
  execute a:firstline. ',' . a:lastline . 'd _'
  let now_num = a:firstline - 1

  for i in range(num_first, num_last, num_incr)
    let ltmp = copy(lines)

    for j in range(0, len(ltmp)-1)
      for pats in g:substitite_insert_nums_patterns
        if pats['type'] == 'pattern'
          let ltmp[j] = substitute(ltmp[j], pats['pat'], '\=printf(submatch(1), '.i.')', 'g')
        elseif pats['type'] == 'char'
          let ltmp[j] = substitute(ltmp[j], pats['pat'], printf(pats['str'], i), 'g')
        endif
      endfor
    endfor

    call append(now_num, ltmp)
    let now_num = now_num + len(ltmp)
  endfor
endfunction "}}}

function! SubstituteNums(...) range "{{{
  let col  = col('.')
  let idx  = (a:0 >= 1) ? a:1 : 0
  let incr = (a:0 >= 2) ? a:2 : 1

  for i in range(a:firstline, a:lastline)
    call cursor(i, col)
    for pats in g:substitite_insert_nums_patterns
      if pats['type'] == 'pattern'
        execute 'silent! s/' . pats['pat'] . '/\=printf(submatch(1), ' . idx . ')/g'
      elseif pats['type'] == 'char'
        execute 'silent! s/' . pats['pat'] . '/' . printf(pats['str'], idx) . '/g'
      endif
    endfor

    let idx = idx + incr
  endfor
endfunction "}}}

