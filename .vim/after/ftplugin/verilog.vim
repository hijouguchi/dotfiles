" module 内部でインデントを起こす
" module hoge;
"		input ...
let b:verilog_indent_modules = 1
nnoremap <buffer> [SPACE]e <C-U>:!verilator --lint-only %<CR>
