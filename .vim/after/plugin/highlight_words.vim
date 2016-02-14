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
  let gm   = s:filter_matches('v:val["pattern"][2:-3] == a:1', word)

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
  windo call s:match_word_remove(word)
endfunction "}}}

function! HighlightWordsClear() abort "{{{
  windo call s:match_highlight_remove()
endfunction "}}}

function! s:filter_matches(str, ...) "{{{
  return filter(copy(getmatches()), a:str)
endfunction "}}}

function! s:get_mininum_index() "{{{
  let list = map(s:filter_matches(
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'str2nr(v:val["group"][13:-1])') " len('Highlightword') is 13

  let cnt = -1
  let cur = 0

  for i in range(s:highlight_count)
    let t = count(list, i)
    if t < cnt || cnt < 0
      let cnt = t
      let cur = i
    endif
  endfor

  return cur
endfunction "}}}

function! s:match_word_remove(pattern) "{{{
  let list = map(s:filter_matches(
        \ 'v:val["pattern"][2:-3] == a:1', a:pattern),
        \ 'v:val["id"]')

  for d in list
    call matchdelete(d)
  endfor
endfunction "}}}

function! s:match_highlight_remove() "{{{
  let list = map(s:filter_matches(
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'v:val["id"]')

  for d in list
    call matchdelete(d)
  endfor
endfunction "}}}

augroup HighghtWord "{{{
  autocmd!
  autocmd BufWinEnter,ColorScheme * call HighlightWordsDefHighlight()
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
