let s:save_cpo = &cpo
set cpo&vim

function! LightlineFilename() abort "{{{
  let file_path = bufname()

  " これくらい長ければ切り詰めたほうが良いかな
  if len(file_path) > 35
    return pathshorten(file_path)
  endif

  return file_path
endfunction "}}}

let g:lightline = #{
      \ component_function: #{
      \   filename: 'LightlineFilename'
      \ }
      \ }

call packman#config#github#new('itchyny/lightline.vim')

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

