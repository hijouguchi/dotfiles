" module 内部でインデントを起こす
" module hoge;
"		input ...
let b:verilog_indent_modules = 1
setlocal foldmethod=expr
setlocal foldexpr=MyVerilogFold(v:lnum)


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

  " input 関係をたたみこめるように {{{
  let signal_def = '^\s*\(input\|output\|wire\|reg\|parameter\)\>'
  if line =~ signal_def
    if getline(prevnonblank(a:lnum-1)) !~ signal_def
      " 見ている行から宣言が始まっている
      if getline(nextnonblank(a:lnum+1)) =~ signal_def
        return 'a1'
      endif
    elseif getline(nextnonblank(a:lnum+1)) !~ signal_def
      " 見ている行で宣言が終わっている
      return 's1'
    endif
  endif " }}}

  " assign ( 1行で記述されている) {{{
  let assign_one_line = '^\s*assign\>.*;'
  if line =~ assign_one_line
    if getline(prevnonblank(a:lnum-1)) !~ assign_one_line
      " 見ている行から宣言が始まっている
      if getline(nextnonblank(a:lnum+1)) =~ assign_one_line
        return 'a1'
      endif
    elseif getline(nextnonblank(a:lnum+1)) !~ assign_one_line
      " 見ている行で宣言が終わっている
      return 's1'
    endif
  endif "}}}

  " assign 複数行で記述されている {{{
  if line =~ '^\s*assign\>[^;]*$'
    if getline(a:lnum-1) =~ '^\s*/' || getline(a:lnum-1) =~ '^\s*$'
      return 'a1'
    endif
  endif

  if line =~ '[^=]\{-};' && nextnonblank(a:lnum+1) != a:lnum+1
    let pnum = a:lnum - 1

    " 上の方に assign があるか探す
    while pnum > 0
      let line = getline(pnum)

      if line =~ '^\s*$' " 空行は無視
        return '='
      elseif line =~ '^\s*assign\>[^;]*$'
        return 's1'
      endif

      let pnum = pnum - 1
    endwhile
  endif
  " }}}


  return '='
endfunction
