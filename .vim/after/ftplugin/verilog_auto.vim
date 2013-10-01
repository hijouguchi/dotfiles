if exists("g:loaded_verilog_auto")
  finish
endif
let g:loaded_verilog_auto = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists(":VerilogAutoArg")
  command VerilogAutoArg call <SID>verilogAutoArg()
endif
if !exists(":VerilogAutoInst")
  command VerilogAutoInst call <SID>verilogAutoInst()
endif


function! s:verilogAutoGetIO(file)
  " [type, port_name, '[lhs:rhs]'] 形式のリストを返す
  "                    ^^^^^^^^^ この部分はソースコードコピペ
  if bufexists(a:file) != 0
    if bufnr(a:file) == bufnr('%')
      " current buffer
      let lines = getline(1, '$')
    else
      " FIXME: getbufline(), 表示されていないと読めないっぽい
      "let lines = getbufline(bufnr(a:file), 1, '$')
      let lines = readfile(a:file)
    endif
  else
    let lines = readfile(a:file)
  endif
  let ports = []

  for line in lines
    let str = line

    " コメントを無視
    " FIXME: 今のところ '//' スタイルだけ
    if str =~ '//'
      let str = substitute(str, '//.*$', '', '')
    endif

    " input, output の行を探す
    if str =~# '\<\(in\|out\)put\>'
      let type = (str =~# '\<input\>') ? 'input' : 'output'
      let bits = matchstr(str, '\[.*\]')
      let str = substitute(str, '\<\(in\|out\)put\>', '', '')
      let str = substitute(str, 'wire', '', '')   " wire 宣言を削除
      let str = substitute(str, '\[.*\]', '', '') " 配列宣言を削除
      let str = substitute(str, '\s', '', 'g')    " 無駄なスペースを消去
      let str = substitute(str, ';', '', 'g')     " ; を削除

      " FIXME: , で区切られたタイプを考慮していない
      if str =~ ','
        for str_split in split(str, ',\s*')
          call add(ports, [type, str_split, bits])
        endfor
      else
        call add(ports, [type, str, bits])
      endif
    endif
  endfor

  return ports
endfunction


function! s:verilogAutoArg()
  call cursor(1, 1)
  let lnum = search('/\*AUTOARG\*/', 'e')
  let ports = <SID>verilogAutoGetIO(expand('%'))

  " インデントと ',' を追加する
  for i in range(0, len(ports)-1)
      " FIXME: extendtab 前提で書いた
      let ports[i] = repeat(' ', indent('.') + &sw) . ports[i][1]
    if i != len(ports)-1
      let ports[i] = ports[i] . ','
    endif
  endfor

  " AUTOARG に挿入されるようにする
  let line = split(getline('.'), '/\*AUTOARG\*/')
  d _
  " FIXME: ');' のインデントが考慮されていない
  call append(lnum-1, line)
  call append(lnum, ports)
endfunction


function! s:verilogAutoInst()
  " ports_top: ['type', 'port_name', '[lhs:rhs]', count]
  let ports_top = []

  call cursor(1,1)
  " AUTOINST が無くなるまで続ける
  while search('/\*AUTOINST\*/', 'e')
    let lnum = line('.')
    let line = substitute(getline('.'), '^\s*', '', '') " 行頭のインデントを削除してから
    let inst_name = matchstr(line, '\S*')

    let ports_assign = []

    " ports 取得
    if !filereadable(inst_name . '.v')
      echoerr inst_name . '.v is not exist'
      return
    endif
    let ports = <SID>verilogAutoGetIO(inst_name . '.v')

    " ports_top にマージ
    for port in ports
      let port_exist = 0
      for port_top in ports_top
        if port_top[1] == port[1]
          let port_exist = 1
          let port_top[3] = port_top[3] + 1
          break
        endif
      endfor

      if port_exist == 0
        call add(ports_top, [port[0], port[1], port[2], 1])
      endif
    endfor

    for i in range(0, len(ports)-1)
      let str = repeat(' ', indent(lnum)+&sw) . '.' . ports[i][1] . '(' . ports[i][1] . ')'
      if i != len(ports)-1
        let str = str . ','
      endif
      call add(ports_assign, str)
    endfor



    " AUTOINST 書き換え
    let line_list = split(getline('.'), '/\*AUTOINST\*/')
    let line_list[1] = repeat(' ', indent(lnum)) . line_list[1]
    d _
    call append(lnum-1, line_list)
    call append(lnum, ports_assign)

    call cursor(1,1)
  endwhile

  " input, output, wire 宣言
  let ports_input  = []
  let ports_output = []
  let ports_wire   = []
  for port_top in ports_top
    if port_top[3] > 1
      call add(ports_wire, port_top[2] . ' ' . port_top[1])
    elseif port_top[0] == 'input'
      call add(ports_input, port_top[2] . ' ' . port_top[1])
    else
      call add(ports_output, port_top[2] . ' ' . port_top[1])
    endif
  endfor

  " input
  call cursor(1,1)
  let lnum = search('/\*AUTOINPUT\*/', 'e')
  for i in range(0, len(ports_input)-1)
    let ports_input[i] = repeat(' ', indent(lnum)) . 'input ' . ports_input[i] . ';'
  endfor
  d _
  call append(lnum-1, ports_input)

  " output
  call cursor(1,1)
  let lnum = search('/\*AUTOOUTPUT\*/', 'e')
  for i in range(0, len(ports_output)-1)
    let ports_output[i] = repeat(' ', indent(lnum)) . 'output ' . ports_output[i] . ';'
  endfor
  d _
  call append(lnum-1, ports_output)

  " wire
  call cursor(1,1)
  let lnum = search('/\*AUTOWIRE\*/', 'e')
  for i in range(0, len(ports_wire)-1)
    let ports_wire[i] = repeat(' ', indent(lnum)) . 'wire ' . ports_wire[i] . ';'
  endfor
  d _
  call append(lnum-1, ports_wire)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
