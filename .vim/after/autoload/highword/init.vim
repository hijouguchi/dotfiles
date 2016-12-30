
let s:save_cpo = &cpo
set cpo&vim

function! highword#init#colorscheme() abort "{{{
  " highlight 追加と、match の追加 (必要があれば)
  highlight  HighWord0  ctermfg=black ctermbg=88  guifg=black guibg=#660000
  highlight  HighWord1  ctermfg=black ctermbg=94  guifg=black guibg=#663300
  highlight  HighWord2  ctermfg=black ctermbg=100 guifg=black guibg=#666600
  highlight  HighWord3  ctermfg=black ctermbg=64  guifg=black guibg=#336600
  highlight  HighWord4  ctermfg=black ctermbg=28  guifg=black guibg=#006600
  highlight  HighWord5  ctermfg=black ctermbg=29  guifg=black guibg=#006633
  highlight  HighWord6  ctermfg=black ctermbg=30  guifg=black guibg=#006666
  highlight  HighWord7  ctermfg=black ctermbg=24  guifg=black guibg=#003366
  highlight  HighWord8  ctermfg=black ctermbg=18  guifg=black guibg=#000066
  highlight  HighWord9  ctermfg=black ctermbg=54  guifg=black guibg=#330066
  highlight  HighWord10 ctermfg=black ctermbg=90  guifg=black guibg=#660066
  highlight  HighWord11 ctermfg=black ctermbg=98  guifg=black guibg=#660033

  call highword#init#match_pop()
endfunction "}}}
function! highword#init#match_push() abort "{{{
  let s:match_pattern_list = filter(getmatches(),
        \ {idx, val -> val.group =~ '^HighWord\d\+$'})
endfunction "}}}
function! highword#init#match_pop() abort "{{{

  let ma = map(filter(getmatches(),
        \ {idx, val -> val.group =~ '^HighWord\d\+$'}),
        \ {idx, val -> val.pattern})

  for mat in s:match_pattern_list
    if count(ma, mat.pattern) == 0
      call matchadd(mat.group, mat.pattern)
    endif
  endfor

  unlet s:match_pattern_list
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
