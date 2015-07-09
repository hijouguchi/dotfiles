" /Users/hijouguchi/.vim/after/plugin/highlight_words.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

" if exists("g:loaded_highlight_words")
"   finish
" endif
let g:loaded_highlight_words = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap * :call HighlightWords(1)<CR>
nnoremap # :call HighlightWords(0)<CR>

let s:highlight_count = 12

function! HighlightWordsSetup() abort "{{{
  let b:highlight_word_ids = {}
  let b:highlight_table    = repeat([0], s:highlight_count)
endfunction }}}"

function! HighlightWordsDefHighlight() abort "{{{
  highlight  HighlightWord0  ctermbg=90
  highlight  HighlightWord1  ctermbg=98
  highlight  HighlightWord2  ctermbg=88
  highlight  HighlightWord3  ctermbg=94
  highlight  HighlightWord4  ctermbg=100
  highlight  HighlightWord5  ctermbg=64
  highlight  HighlightWord6  ctermbg=28
  highlight  HighlightWord7  ctermbg=29
  highlight  HighlightWord8  ctermbg=30
  highlight  HighlightWord9  ctermbg=24
  highlight  HighlightWord10 ctermbg=18
  highlight  HighlightWord11 ctermbg=54
endfunction "}}}

function! HighlightWords(append) abort "{{{
  if !exists('b:highlight_word_ids')
    let b:highlight_word_ids = {}
    " {'word' : [match_id, highlight_id]}
  endif

  if !exists('b:highlight_table')
    let b:highlight_table = [0, 0, 0, 0]
  endif

  let word = expand('<cword>')
  let targ = get(b:highlight_word_ids, word, [-1, -1])

  if a:append
    if targ[0] == -1
      let hid = s:get_mininum_index()
      let mid = matchadd('HighlightWord'.hid, '\<'.word.'\>')
      let b:highlight_word_ids[word] = [mid, hid]
      let b:highlight_table[hid]     = b:highlight_table[hid] + 1
    endif

    call feedkeys('*', 'n')

  elseif targ[0] != -1
    let mid = targ[0]
    let hid = targ[1]
    let b:highlight_table[hid] = b:highlight_table[hid] - 1
    call matchdelete(mid)
    call remove(b:highlight_word_ids, word)
  endif
endfunction "}}}

function! s:get_mininum_index() "{{{
  let it = 0
  let im = 100

  for i in range(s:highlight_count)
    if b:highlight_table[i] < im
      let it = i
      let im = b:highlight_table[i]
    endif
  endfor

  return it
endfunction "}}}

augroup HighghtWord "{{{
  autocmd!
  autocmd BufEnter,ColorScheme * call HighlightWordsDefHighlight()
  autocmd BufEnter             * call HighlightWordsSetup()
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
