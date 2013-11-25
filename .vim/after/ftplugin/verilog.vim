setlocal commentstring=\ //\ %s

let b:verilog_indent_modules = 1
let b:surround_{char2nr("b")} = "begin \r end"
let b:match_words = '\<begin\>:\<end\>'

nnoremap <buffer> <Space>e :!verilator --lint-only %<CR>
nnoremap <buffer> <Space>a :VerilogExpandArray<CR>
" inoremap <buffer> <expr> = smartchr#loop(' = ', ' <= ', ' == ', '=')


" 'input reg [n] hoge [m]' -> 'input reg [n-1:0] hoge [m-1:0]'
command! -nargs=0 -range=% VerilogExpandArray call <SID>verilogExpandArray(<line1>, <line2>)
function! s:verilogExpandArray(line1, line2) "{{{
  " 'input reg [n] hoge [m]' の部分をマッチさせる
  let l:regexp_io  = '\%(\%(input\|output\|inout\)\s\+\)'
  let l:regexp_wr  = '\%(\%(wire\|reg\)\s\+\)'
  let l:regexp_arr = '\%(\[\s*\([1-9]\d*\s*\)\]\)\?'
  let l:regexp_val = '\s*\h\w\+\s*'
  let l:regexp     = '^\s*\%('.l:regexp_io.l:regexp_wr.'\?\|'.l:regexp_wr.'\)'
  let l:regexp     = l:regexp . l:regexp_arr . l:regexp_val
  let l:regexp     = l:regexp . l:regexp_arr

  for num in range(a:line1, a:line2)
    let l:line  = getline(l:num)
    let l:match = matchlist(l:line, l:regexp)

    if !empty(l:match)
      if l:match[1] != ''
        let l:anum = l:match[1] - 1
        let l:anum = l:anum . ':0'
        execute l:num . 's/' . l:match[1] . '/' . l:anum . '/'
      endif

      if l:match[2] != ''
        let l:anum = l:match[2] - 1
        let l:anum = '0:' . l:anum
        execute l:num . 's/' . l:match[2] . '/' . l:anum . '/'
      endif
    endif
  endfor
endfunction "}}}

" vim: fdm=marker

