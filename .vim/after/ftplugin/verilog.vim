" autoload/verilog/utility.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

setlocal commentstring=\ //\ %s

let b:verilog_indent_modules = 1
let b:surround_{char2nr("b")} = "begin \r end"
let b:match_words = '\<begin\>:\<end\>'

if &l:filetype !~ '^eruby.'
  nnoremap <buffer> <Space>e :!verilator --lint-only %<CR>
endif
nnoremap <buffer> <Space>a :VerilogExpandArray<CR>
vnoremap <buffer> <Space>a :VerilogExpandArray<CR>
" inoremap <buffer> <expr> = smartchr#loop(' = ', ' <= ', ' == ', '=')


" 'input reg [n] hoge [m]' -> 'input reg [n-1:0] hoge [m-1:0]'
command! -nargs=0 -range=% VerilogExpandArray call verilog#utility#ExpandArray(<line1>, <line2>)

" vim: ts=2 sw=2 sts=2 et fdm=marker

