let s:save_cpo = &cpo
set cpo&vim


" see ':help pi_netrw'
let g:netrw_preview        = 1
let g:netrw_liststyle      = 1
let g:netrw_banner         = 0
let g:netrw_sizestyle      = "H"
let g:netrw_timefmt        = "%y/%m/%d %H:%M"
"let g:netrw_special_syntax = 1


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

