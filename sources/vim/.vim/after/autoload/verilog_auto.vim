" autoload/verilog_auto.vim
"

let s:save_cpo = &cpo


function! verilog_auto#autoarg() abort "{{{
  " search module name
  " カーソル行の module をターゲットにする
  " 上の方に /*autoarg*/ があるはずなのでそこをさがす
  call search('\/\*autoarg\*\/', 'be')
  let argcur0 = getpos('.')

  " /*autoarg*/ の次に出てくる ')' を探す
  call search(')')
  let argcur1 = getpos('.')

  " port 一覧取得と成形
  let ports = s:parse_line()
  let sp    = &l:expandtab ? repeat(' ', &l:shiftwidth) : "\t"
  let cr    = (&l:ff == 'dos') ? "\r\n" : (&l:ff == 'mac') ? "\n" : "\r"
  call map(ports, 'sp . v:val')

  " , を追加する
  if len(ports) > 1
    let tmp = ports[0:-2]
    call map(tmp, 'v:val . ","')
    let ports[0:-2] = tmp
    unlet tmp
  endif

  " /*autoarg*/ の所に port を挿入
  let lhs = getline(argcur0[1])[0:(argcur0[2]-1)]
  let rhs = getline(argcur1[1])[(argcur1[2]-1):-1]
  let ret = [lhs, rhs]
  call extend(ret, ports, 1)

  let num = argcur1[1] - argcur0[1] + 1
  call append(argcur1[1], ret)
  call cursor(argcur0[1], 0)
  execute 'normal' num . 'd_'
endfunction "}}}

function! s:parse_line() abort "{{{
  let is_comment = 0
  let str        = ''
  let ports      = []

  for i in range(line('.'), line('$'))
    " /* ... */ の部分はあらかじめ削除
    let line = substitute(getline(i), '/\*.\{-}\*/', '', 'g')

    " /* ... */ の読み飛ばし (複数行にまたぐもの)
    if is_comment == 0 "{{{
      if line =~ '/\*'
        let is_comment = 1
        let line = substitute(line, '/\*.*$', '', '')
      endif
    else
      if line =~ '\*/'
        is_comment = 0
        let line = substitute(line, '^.*\*/', '', '')
      else
        continue
      endif
    endif "}}}

    " // ... の読み飛ばし
    let line = substitute(line, '//.*$', '', '')

    " <port> [vec] name, name, ..., name; を探す
    let ltmp    = split(line, ';', 1)
    let ltmp[0] = str . ' ' . ltmp[0]

    for ltm in ltmp
      let tmp = map(s:get_identify(ltm), 'v:val[2]')
      call extend(ports, tmp)
    endfor

    " 次にパースする行を残す
    if len(ltmp) == 1
      let str = ltmp[0]
    else
      let str = ltmp[-1]
    endif
    " endmodule があればパース終わり
    if line =~ '\<endmodule\>'
      break
    endif
  endfor

  return ports
endfunction "}}}

function! s:get_identify(line) abort "{{{
  let line = a:line
  let ptn_port = '\<input\>\|\<output\>\|\<inout\>'
  if line !~ ptn_port
    return [] " null
  endif

  let type = matchstr(line, '\(\<input\>\|\<output\>\|\<inout\>\)')
  let line = substitute(line, '^.*\(\<input\>\|\<output\>\|\<inout\>\)\s*', '', '')

  let line = substitute(line, '^.*\(\<wire\>\|\<reg\>\|\<tri\d\>\)\s*',     '', '')

  let vect = matchstr(line, '\[[^\]]*\]')
  let line = substitute(line, '\[[^\]]*\]\s*',                              '', '')
  return map(split(line, '\s*,\s*'),
        \ '[type, vect, v:val]')
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
