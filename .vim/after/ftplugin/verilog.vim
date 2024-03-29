" .vim/after/ftplugin/verilog.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

let s:save_cpo = &cpo
set cpo&vim

setlocal commentstring=\ //\ %s
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

let b:verilog_indent_modules = 1
let b:systemverilog_indent_modules = 1
let b:surround_{char2nr("b")} = "begin \r end"
let b:match_words = join([
      \ '\<begin\>:\<end\>',
      \ '\<module\>:\<endmodule\>',
      \ '\<interface\>:\<endinterface\>',
      \ '\<task\>:\<endtask\>',
      \ '\<function\>:\<endfunction\>',
      \ '\<case[cz]\?\>:\<endcase\>',
      \ '`ifn\?def\>:`elseif\>:`endif\>',
      \ '\<class\>:\<endclass\>',
      \ '\<package\>:\<endpackage\>',
      \ '\<covergroup\>:\<endcovergroup\>',
      \ ], ',')


nnoremap <buffer> <Space>a :VerilogExpandArray<CR>
vnoremap <buffer> <Space>a :VerilogExpandArray<CR>
" inoremap <buffer> <expr> = smartchr#loop(' = ', ' <= ', ' == ', '=')


" 'input reg [n] hoge [m]' -> 'input reg [n-1:0] hoge [m-1:0]'
command! -nargs=0 -range=% VerilogExpandArray call verilog#utility#ExpandArray(<line1>, <line2>)

function! MyFoldVerilog(lnum) "{{{
  let line = getline(a:lnum)
  let flv  = foldlevel(a:lnum)
  let fl   = flv

  let line = substitute(line, '\<\(virtual\|static\|automatic\|extern\)\>', '', 'g')

  if line =~ '^\s*\<\(function\|task\|class\|module\|covergroup\)\>'
    let fl = fl + 1
  elseif line =~ '\<end\(function\|task\|class\|module\|endgroup\)\>'
    let fl = fl - 1
  elseif line =~ '^\s*\<always'
    if line =~ '\<begin\>' || getline(a:lnum+1) =~ '\<begin\>'
      let fl = fl + 1
    endif
  "elseif fl =~ '\<end\>'
  "    let fl = fl - 1
  end

  if fl - flv > 0
    return 'a' . (fl-flv)
  elseif flv - fl > 0
    return 's' . (flv-fl)
  else
    return '='
  endif
endfunction "}}}

"setl foldmethod=expr
"setl foldexpr=MyFoldVerilog(v:lnum)

augroup MyVerilog
  autocmd!

  autocmd InsertEnter * setlocal foldmethod=manual
  autocmd InsertLeave * setlocal foldmethod=expr
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

