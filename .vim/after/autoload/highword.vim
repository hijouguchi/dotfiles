if !exists("g:loaded_highword")
  runtime! plugin/highword.vim
endif

let s:save_cpo = &cpo
set cpo&vim

function! highword#add() abort "{{{
  " TODO: 大文字小文字無視する・しないを選べるようにしとくべき
  let word = expand('<cword>')
  let mat  = '\<' . word . '\>\C'

  let ma = filter(getmatches(),
        \ {idx, val -> val.group =~ '^HighWord\d\+$' && val.pattern ==# mat })

  echo ma
  if !empty(ma)
    return
  endif

  let hlname = s:get_hlname_minimum()

  if !exists(s:autocmd_loaded)
    call highword#set_autocmd()
  endif

  let wnr = winnr()
  windo call matchadd(hlname, mat)
  execute wnr . 'wincmd w'

endfunction "}}}
function! highword#del() abort "{{{
  let word = expand('<cword>')
  let mat  = '\<' . word . '\>\C'

  let wnr = winnr()
  windo call s:delete_highlight(mat)
  execute wnr . 'wincmd w'
endfunction "}}}
function! highword#clear() abort "{{{
  let wnr = winnr()
  windo call s:delete_highlight()
  execute wnr . 'wincmd w'

endfunction "}}}
function! highword#set_autocmd() abort "{{{
  let s:autocmd_loaded = 1

  call s:colorscheme()

  augroup Highlightword
    autocmd!
    autocmd BufWinEnter,ColorScheme * call highword#match_pop()
    autocmd WinEnter                * call highword#match_pop()
    autocmd WinLeave                * call highword#match_push()
  augroup END
endfunction "}}}
function! highword#match_pop() abort "{{{
  call s:colorscheme()

  if !exists('s:match_pattern_list')
    return
  endif

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
function! highword#match_push() abort "{{{
  let s:match_pattern_list = filter(getmatches(),
        \ {idx, val -> val.group =~ '^HighWord\d\+$'})
endfunction "}}}

function! s:get_hlname_minimum() abort "{{{
  let matches = map(getmatches(), {idx, val -> val.group} )

  let cnt = 100
  let str = ''

  for i in range(12)
    let targ = 'HighWord'.i
    let tmp  = count(matches, targ)

    if tmp < cnt
      let cnt = tmp
      let str = targ
    endif
  endfor

  return str
endfunction "}}}
function! s:delete_highlight(...) abort "{{{
  " 引数無し: すべて
  " 引数有り: pattern が一致した物
  if a:0 > 0
    let ma = filter(getmatches(),
          \ {idx, val -> val.group =~ '^HighWord\d\+$' && val.pattern ==# a:1 })
  else
    let ma = filter(getmatches(),
          \ {idx, val -> val.group =~ '^HighWord\d\+$' })
  endif
  for m in ma
    call matchdelete(m.id)
  endfor
endfunction "}}}
function! s:colorscheme() abort "{{{
  if hlexists('HighWord0')
    return
  endif

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
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
