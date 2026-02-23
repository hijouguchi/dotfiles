let s:save_cpo = &cpo
set cpo&vim

let e = packman#config#github#new('itchyny/landscape.vim')

function! e.post_load()
  if !has('gui_running')
    colorscheme landscape
  end
endfunction

augroup MyColorSchemeLandScape
  autocmd!
  autocmd ColorScheme *
        \   if g:colors_name == 'landscape'
        \ |   highlight! default link NonText Comment
        \ | endif
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

