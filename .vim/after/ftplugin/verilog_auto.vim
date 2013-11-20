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
  " input (wire) [n:0] hoge
  " wire [n:0] hoge
  " の部分を取り出す (wire は auto-inst で使用)
  " [[type, bits, val], ...] の形式で返す
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

  let ports        = []
  let l:regexp_io  = '\(input\|output\|inout\|wire\|reg\)\s\+'
  let l:regexp_wr  = '\%(\%(wire\|reg\)\s\+\)\?'
  let l:regexp_arr = '\%(\[\s*\([1-9]\d*\)\s*:\s*0\s*\]\s\+\)\?'
  let l:regexp_val = '\(\h\w*\)'
  let l:regexp     = '^\s*' . l:regexp_io . l:regexp_wr
  let l:regexp     = l:regexp . l:regexp_arr . l:regexp_val

  let l:is_comment = 0

  for line in lines
    " コメント行を無視する
    let line = substitute(line, '/\*.\{-}\*/', '', 'g')
    if l:is_comment
      if line =~ '\*/'
        let l:is_comment = 0
      else
        continue
      endif
    elseif line =~ '/\*'
      let l:is_comment = 1
      continue
    endif

    let l:match = matchlist(line, l:regexp)

    if !empty(l:match)
      let l:bits = l:match[2] + 1
      call add(ports, [l:match[1], l:bits, l:match[3]])
    endif
  endfor

  return ports
endfunction


function! s:verilogAutoArg()
  let l:pattern     = '/\*\s*autoarg\s*\*/'
  call cursor(1, 1)

  let l:lnum = search(l:pattern, 'e')
  let l:ports = <SID>verilogAutoGetIO(expand('%'))
  call filter(l:ports, 'index(["input", "output", "inout"], v:val[0]) >= 0')



  " ports を成形する
  let l:tab = repeat(' ', indent(".") + &sw)
  for i in range(0, len(l:ports)-1)
    let l:tmp = l:tab . l:ports[i][2]

    if i != len(l:ports)-1
      let l:tmp = l:tmp . ','
    endif

    let l:ports[i] = l:tmp
  endfor

  " AUTOARG に挿入されるようにする
  let l:line = split(getline('.'), '/\*\s*autoarg\s*\*/')
  d _
  " FIXME: ');' のインデントが考慮されていない
  call append(l:lnum-1, l:line)
  call append(l:lnum, l:ports)
endfunction


function! s:verilogAutoInst()
  " ports_top: ['type', 'port_name', bits]
  let l:pattern_inst = '/\*\s*autoinst\s*\*/'
  let l:local_wire   = <SID>verilogAutoGetIO(expand('%'))
  let l:ports_top    = []
  call cursor(1,1)

  let l:local_wire = map(l:local_wire, "v:val[2]")

  " autoinst が無くなるまで
  while search(l:pattern_inst, 'e')
    let l:num       = line('.')
    let l:inst_name = matchlist(getline(l:num), '^\s*\(\S\+\)')[1]

    " ports () 取得
    if !filereadable(inst_name . '.v')
      echoerr inst_name . '.v is not exist'
      return
    endif
    let l:ports = <SID>verilogAutoGetIO(inst_name . '.v')
    call filter(l:ports, 'index(["input", "output"], v:val[0]) >= 0')

    " autoinst 書き換え
    let l:indent       = repeat(' ', indent(l:num) + &sw)
    let l:inst_port    = filter(copy(l:ports), 'index(["input", "output"], v:val[0]) >= 0')
    call map(l:inst_port, 'l:indent . "." . v:val[2] . "(" . v:val[2] . ")"')
    for i in range(0, len(l:inst_port)-2)
      let l:inst_port[i] = l:inst_port[i] . ','
    endfor
    let l:line_list    = split(getline(l:num), l:pattern_inst)
    let l:line_list[1] = repeat(' ', indent(l:num)) . l:line_list[1]
    d _
    call append(l:num-1, line_list)
    call append(l:num, l:inst_port)


    " l:local_wire にあれば無視
    call filter(l:ports, 'index(l:local_wire, v:val[2]) == -1')

    " l:ports_top にマージ
    for port in l:ports
      let l:exist = 0
      for port_top in l:ports_top
        if port_top[2] == port[2]
          " 同じ物が見つかったら， wire に書き換え
          let l:exist = 1
          let port_top[0] = 'wire'
          break
        endif
      endfor
      " 見つからなかった場合は追加
      if !l:exist
        call add(l:ports_top, port)
      endif
    endfor
  endwhile

  " 宣言追加
  " input, output, input, wire の順に並ぶように
  let l:ports_assign = []
  call extend(l:ports_assign, filter(copy(l:ports_top), 'v:val[0] == "input"'))
  call extend(l:ports_assign, filter(copy(l:ports_top), 'v:val[0] == "output"'))
  call extend(l:ports_assign, filter(copy(l:ports_top), 'v:val[0] == "inout"'))
  call extend(l:ports_assign, filter(copy(l:ports_top), 'v:val[0] == "wire"'))

  let l:pattern_wire = '/\*\s*autowire\s*\*/'

  call cursor(1,1)
  let l:num = search(l:pattern_wire, 'e')

  let l:indent = repeat(' ', indent('.'))

  for i in range(0, len(l:ports_assign)-1)
    let l:tmp = l:indent . l:ports_assign[i][0]

    if l:ports_assign[i][1] != 1
      let l:tmp = l:tmp . ' [' . (l:ports_assign[i][1]-1) . ':0]'
    endif

    let l:tmp = l:tmp . ' ' . l:ports_assign[i][2] . ';'

    let l:ports_assign[i] = l:tmp
  endfor

  call append(l:num, l:ports_assign)
  d _
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
