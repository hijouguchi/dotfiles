" module 内部でインデントを起こす
" module hoge;
"		input ...
let b:verilog_indent_modules = 1
setlocal foldmethod=expr
setlocal foldexpr=MyVerilogFold(v:lnum)


" always ... begin; end を畳み込み
function! MyVerilogFold(lnum)
  let line = getline(a:lnum)
  let fl   = foldlevel(a:lnum)

  "" marker
  "let l:fms = split(&l:foldmarker, ',')
  "if line =~ l:fms[0]
  "  return 'a1'
  "elseif line =~ l:fms[1]
  "  return 's1'
  "endif

  " always () begin ... end をたためるように {{{
  if line =~ '^\s*\<always\>.*\<begin\>'
    return 'a1'
  elseif line =~ '^\s*\<end\>' && line !~ '\<begin\>'
    " ヒットした end に対応した begin を探す
    let level = 1
    let pnum = prevnonblank(a:lnum - 1)

    while pnum > 0
      let line = getline(pnum)

      if line =~ '^\s*\<end\>' && line !~ '\<begin\>'
        let level = level + 1
      elseif line !~ '^\s*\<end\>' && line =~ '\<begin\>'
        let level = level - 1
      endif

      if level == 0
        if line =~ '\<always\>'
          return 's1'
        else
          return '='
        endif
      endif

      let pnum = prevnonblank(pnum - 1)
    endwhile
  endif " }}}

  " function
  if line =~ '\<function\>'
    return 'a1'
  elseif line =~ '\<endfunction\>'
    return 's1'
  endif

  " ... definition をたためるように
  " 2行以上の空行まで
  if line =~ '//.\{-}definition$'
    return 'a1'
  endif

  " 下2行が空行
  if getline(a:lnum+1) =~ '^\s*$' && getline(a:lnum+2) =~ '^\s*$'
    let pnum = a:lnum - 1

    while pnum > 0
      let line = getline(pnum)
      if getline(pnum) =~ '^\s*$'
        if getline(pnum-1) =~ '^\s*$'
          return '='
        endif
        let pnum = pnum - 2
        next
      elseif line =~ '//.\{-}definition$'
        return 's1'
      endif

      let pnum = pnum - 1
    endwhile
  endif

  return '='
endfunction
