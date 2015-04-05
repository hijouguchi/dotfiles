" autoload/verilog/utility.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

" if exists("g:loaded_autoload#verilog#utility")
"   finish
" endif
" let g:loaded_autoload#verilog#utility = 1

let s:save_cpo = &cpo
set cpo&vim


function! verilog#utility#ExpandArray(line1, line2) "{{{
  echo 'here'
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

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
