let g:substitite_insert_nums_patterns = [
      \ {'type': 'char',    'pat': 'XXX', 'str': '%d'},
      \ {'type': 'pattern', 'pat': '_\(%\d*[dxX]\)_'},
      \ ]

command! -range -nargs=+ SubstituteInsertNums <line1>,<line2>call SubstituteInsertNums(<f-args>)
command! -range -nargs=? SubstituteNums       <line1>,<line2>call SubstituteNums(<f-args>)

function! SubstituteInsertNums(...) range "{{{
  let nums = a:1
  let nume = a:2

  let lines = getline(a:firstline, a:lastline)

  " 元の行を削除する
  call cursor(a:firstline, 0)
  execute a:firstline. ',' . a:lastline . 'd _'
  let now_num = a:firstline - 1

  for i in range(nums, nume)
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
  let col = col('.')
  let idx = (a:0 == 1) ? a:1 : 0

  for i in range(a:firstline, a:lastline)
    call cursor(i, col)
    for pats in g:substitite_insert_nums_patterns
      if pats['type'] == 'pattern'
        execute 'silent! s/' . pats['pat'] . '/\=printf(submatch(1), ' . idx . ')/g'
      elseif pats['type'] == 'char'
        execute 'silent! s/' . pats['pat'] . '/' . printf(pats['str'], idx) . '/g'
      endif
    endfor

    let idx = idx + 1
  endfor
endfunction "}}}

