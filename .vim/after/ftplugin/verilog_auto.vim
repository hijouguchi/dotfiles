" ftplugin/verilog_auto.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>

"if exists("g:loaded_verilog_auto")
"  finish
"endif
"let g:loaded_verilog_auto = 1

let s:save_cpo = &cpo
set cpo&vim

command! VerilogAutoArg silent call verilog_auto#autoarg()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
