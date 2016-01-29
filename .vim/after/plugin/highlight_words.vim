" /Users/hijouguchi/.vim/after/plugin/highlight_words.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015/07/13

" if exists("g:loaded_highlight_words")
"   finish
" endif
let g:loaded_highlight_words = 1
let g:highlight_words_nohl   = 0

let s:save_cpo = &cpo
set cpo&vim

nnoremap          * :call HighlightWordsAdd()<CR>*zvzz
nnoremap <silent> # :call HighlightWordsRemove()<CR>

let s:highlight_count = 12

function! HighlightWordsDefHighlight() abort "{{{
  highlight  HighlightWord0  ctermfg=black ctermbg=88  guifg=black guibg=#660000
  highlight  HighlightWord1  ctermfg=black ctermbg=94  guifg=black guibg=#663300
  highlight  HighlightWord2  ctermfg=black ctermbg=100 guifg=black guibg=#666600
  highlight  HighlightWord3  ctermfg=black ctermbg=64  guifg=black guibg=#336600
  highlight  HighlightWord4  ctermfg=black ctermbg=28  guifg=black guibg=#006600
  highlight  HighlightWord5  ctermfg=black ctermbg=29  guifg=black guibg=#006633
  highlight  HighlightWord6  ctermfg=black ctermbg=30  guifg=black guibg=#006666
  highlight  HighlightWord7  ctermfg=black ctermbg=24  guifg=black guibg=#003366
  highlight  HighlightWord8  ctermfg=black ctermbg=18  guifg=black guibg=#000066
  highlight  HighlightWord9  ctermfg=black ctermbg=54  guifg=black guibg=#330066
  highlight  HighlightWord10 ctermfg=black ctermbg=90  guifg=black guibg=#660066
  highlight  HighlightWord11 ctermfg=black ctermbg=98  guifg=black guibg=#660033
endfunction "}}}

function! HighlightWordsAdd() abort "{{{
  let word = expand('<cword>')
  let gm   = filter(copy(getmatches()), 'v:val["pattern"][2:-3] == word')

  if empty(gm)
    if get(g:, 'highlight_words_nohl', 0)
      setlocal nohlsearch
    endif

    let hid = s:get_mininum_index()
    windo call matchadd('HighlightWord'.hid, '\<'.word.'\>')
  endif

  return
endfunction "}}}

function! HighlightWordsRemove() abort "{{{
  let word = expand('<cword>')
  let gm   = filter(copy(getmatches()), 'v:val["pattern"][2:-3] == word')

  if !empty(gm)
    for g in gm
      windo call matchdelete(g['id'])
    endfor
  endif
  return
endfunction "}}}

function! HighlightWordsClear() abort "{{{
  let list = map(filter(copy(getmatches()),
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'v:val["id"]')

  for d in list
    windo call matchdelete(d)
  endfor
endfunction "}}}

function! s:get_mininum_index() "{{{
  let list = map(filter(copy(getmatches()),
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'str2nr(substitute(v:val["group"], "^Highlightword", "", ""))')

  let it = 0
  let im = 100

  for i in range(s:highlight_count)
    let cnt = count(list, i)
    if cnt < im
      let it = i
      let im = cnt
    endif
  endfor

  return it
endfunction "}}}

augroup HighghtWord "{{{
  autocmd!
  autocmd BufWinEnter,ColorScheme * call HighlightWordsDefHighlight()
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
