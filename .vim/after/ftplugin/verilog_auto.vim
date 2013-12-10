" TODO: bit の中に parameter が入っていたら取りだしておく
"       autoinst 時に宣言したい
if exists("g:loaded_verilog_auto")
  finish
endif
let g:loaded_verilog_auto = 1

let g:verilog_auto_search_path = [
      \ '../rtl',
      \ '../bhv',
      \ '../test'
      \ ]

let s:save_cpo = &cpo
set cpo&vim

if !exists(":VerilogAutoArg")
  command VerilogAutoArg call <SID>verilogAutoArg()
endif
if !exists(":VerilogAutoInst")
  command VerilogAutoInst call <SID>verilogAutoInst()
endif
if !exists(":VerilogAutoTestTemplate")
  command -nargs=1 VerilogAutoTestTemplate call <SID>verilogAutoTestTemplate(<q-args>)
endif

function! s:verilogAutoGetPath(file) " {{{
  " [bufnr, filepath] の形式で返す
  " bufnr が -1 の場合，buffer が開かれていない
  let l:list = map(copy(g:verilog_auto_search_path), 'v:val . "/" . a:file')
  call insert(l:list, a:file, 0)

  for f in l:list
    if bufexists(f) != 0
      return [bufnr(f), f]
    elseif filereadable(f)
      return [-1 , f]
    endif
  endfor

  echoerr a:file . ' is not exist'
  return
endfunction " }}}

function! s:verilogAutoGetIO(file) " {{{
  " input/output/inout (wire/reg) [...] hoge
  " wire/reg [...] hoge
  " parameter [...] hoge = val;
  " の部分を取り出す (wire/reg/parameter は autoinst で使用)
  " [[type, bits, name], ...] の形式で返す
  " parameter の場合は ['parameter', bits, name, val] とする
  " (デフォルト引数として値も返すように)
  " bits は [WIDTH-1:0] などを想定し，そのまま切り出す
  if a:file[0] == bufnr('%')
    " current buffer
    let lines = getline(1, '$')
  elseif a:file[0] != -1
    " other buffer
    " FIXME: getbufline(), 表示されていないと読めないっぽい
    "let lines = getbufline(bufnr(a:file), 1, '$')
    let lines = readfile(a:file[1])
  else
    let lines = readfile(a:file[1])
  endif

  let ports        = []
  let l:regexp_io  = '\(input\|output\|inout\|wire\|reg\)\s\+'
  let l:regexp_wr  = '\%(\%(wire\|reg\|parameter\)\s\+\)\?'
  let l:regexp_arr = '\%(\(\[[^\]]\+\]\)\s\+\)\?'
  let l:regexp_val = '\(\h\w*\%(\s*,\s*\h\w*\)*\)'
  let l:regexp     = '^\s*' . l:regexp_io . l:regexp_wr
  let l:regexp     = l:regexp . l:regexp_arr . l:regexp_val

  let l:regexp_param = '^\s+'

  let l:is_comment  = 0
  let l:is_function = 0

  for line in lines
    " コメント行，function 文などを無視する
    let line = substitute(line, '/\*.\{-}\*/', '', 'g')
    let line = substitute(line, '//.*$', '', 'g')
    if l:is_comment
      if line =~ '\*/'
        let l:is_comment = 0
      else
        continue
      endif
    else

      if line =~ '/\*'
        let l:is_comment = 1
        let line = substitute(line, '/\*.*$', '', 'g')
      endif

      " function 文などの行を無視
      if l:is_function
        if line =~ '\<endfunction\>\|\<endtask\>'
          let l:is_function = 0
        endif
        continue
      elseif line =~ '\<function\>\|\<task\>'
        let l:is_function = 1
        continue
      endif
    endif

    let l:match = matchlist(line, l:regexp)

    if !empty(l:match)
      for prt in split(l:match[3], '\s*,\s*')
        call add(ports, [l:match[1], l:match[2], prt])
      endfor
    endif
  endfor

  return ports
endfunction " }}}

function! s:verilogAutoArg() " {{{
  let l:pattern     = '/\*\s*autoarg\s*\*/'
  call cursor(1, 1)

  let l:lnum = search(l:pattern, 'e')
  let l:ports = <SID>verilogAutoGetIO(<SID>verilogAutoGetPath(expand('%')))
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
endfunction " }}}

function! s:verilogAutoInst() " {{{
  " ports_top: ['type', 'port_name', bits]
  let l:pattern_inst = '/\*\s*autoinst\s*\*/'
  let l:local_wire   = <SID>verilogAutoGetIO(<SID>verilogAutoGetPath(expand('%')))
  let l:ports_top    = []
  let l:param_top    = []
  call cursor(1,1)

  let l:local_param = map(
        \ filter(copy(l:local_wire), 'v:val[0] != "parameter"'),
        \ 'v:val[2]')
  call filter(l:local_wire, 'v:val[0] == "parameter"')
  let l:local_wire  = map(l:local_wire, 'v:val[2]')

  " autoinst が無くなるまで
  while search(l:pattern_inst, 'e')
    let l:num       = line('.')
    let l:inst_name = matchlist(getline(l:num), '^\s*\(\S\+\)')[1]

    " ports 取得
    let l:ports = <SID>verilogAutoGetIO(<SID>verilogAutoGetPath(inst_name . '.v'))
    call filter(l:ports, 'index(["input", "output"], v:val[0]) >= 0')

    " param_top マージ
    " [name, val] だけにする
    " FIXME: 書きかけ
    " let l:param_tmp = map(filter(copy(l:ports), 'v:val[0] != "parameter"'), '[v:val[2], v:val[3]]')

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

    if l:ports_assign[i][1] != ''
      let l:tmp = l:tmp . ' ' . l:ports_assign[i][1]
    endif

    let l:tmp = l:tmp . ' ' . l:ports_assign[i][2] . ';'

    let l:ports_assign[i] = l:tmp
  endfor

  call append(l:num, l:ports_assign)
  d _
endfunction " }}}

function! s:verilogAutoTestTemplate(target) " {{{
  let l:ports = <SID>verilogAutoGetIO(<SID>verilogAutoGetPath(a:target . '.v'))
  let l:inout = filter(copy(l:ports), 'v:val[0] == "inout"')
  call filter(l:ports, 'index(["input", "output"], v:val[0]) >= 0')

  " l:ports を書き換える
  " input -> reg, output -> wire
  for i in range(0, len(l:ports)-1)
    if     l:ports[i][0] == 'input'
      let l:ports[i][0] = 'reg'
    elseif l:ports[i][0] == 'output'
      let l:ports[i][0] = 'wire'
    else
      echoerr l:ports[i][0] . ' is unknown'
      return 1
    endif
  endfor

  echo l:ports
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
