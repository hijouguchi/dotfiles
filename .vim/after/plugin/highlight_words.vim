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

nnoremap <silent> * :call HighlightWordsAdd()<CR>*zvzz
nnoremap <silent> # :call HighlightWordsRemove()<CR>

function! HighlightWordsDefHighlight() abort "{{{
  " highlight 追加と、match の追加 (必要があれば)
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

  call HighlightWordsStashPop()
endfunction "}}}

function! HighlightWordsStash() abort "{{{
  " HighlightWord に指定された単語を覚えておく
  " {'group': 'HighlightWord1', 'pattern': '\<highlight\>', 'priority': 10, 'id': 62}
  let g:highlight_words_stashed = s:filter_matches('v:val["group"] =~ "HighlightWord"')
endfunction  "}}}

function! HighlightWordsStashPop() abort "{{{
  if ! exists('g:highlight_words_stashed')
    return
  endif

  let hw = map(
        \ s:filter_matches('v:val["group"] =~ "HighlightWord"'),
        \ 'v:val["pattern"]')

  for g in g:highlight_words_stashed
    if count(hw, g['pattern']) == 0
      call matchadd(g['group'], g['pattern'])
    endif
  endfor
endfunction "}}}

function! s:get_command_result(arg) abort "{{{
  " command の結果を取り出す
  " 例: s:get_command_result('set cpo?') -> ' cpoptions=aABceFs'
  let tmp = @a
  redir @a
  execute 'silent' a:arg
  redir END
  let result = @a
  let @a = tmp
  return result
endfunction "}}}

function! s:get_highlight_count() abort "{{{
  " hi Highlightword の定義されている個数を返す
  let list = s:get_command_result('highlight')
  return len(filter(split(list), 'v:val =~ "^\\<HighlightWord\\d\\+\\>"'))
endfunction "}}}

function! HighlightWordsAdd() abort "{{{
  " カーソルの下にある単語をハイライトに追加
  " これをすべてのバッファで行う
  let word = expand('<cword>')
  let gm   = s:filter_matches('v:val["pattern"][2:-3] == a:1', word)

  if !empty(gm)
    return
  endif

  if get(g:, 'highlight_words_nohl', 0)
    setlocal nohlsearch
  endif

  let hid = s:get_mininum_index()

  let wnr = winnr()
  windo call matchadd('HighlightWord'.hid, '\<'.word.'\>')
  execute wnr . 'wincmd w'
endfunction "}}}

function! HighlightWordsRemove() abort "{{{
  " カーソルの下にある単語のハイライトを削除
  " これをすべてのバッファで行う
  let word = expand('<cword>')

  let wnr = winnr()
  windo call s:match_word_remove(word)
  execute wnr . 'wincmd w'
endfunction "}}}

function! HighlightWordsClear() abort "{{{
  " HighlightWord にセットされた単語をすべて削除
  " これをすべてのバッファで行う
  let wnr = winnr()
  windo call s:match_highlight_remove()
  execute wnr . 'wincmd w'
endfunction "}}}

function! s:filter_matches(str, ...) "{{{
  return filter(copy(getmatches()), a:str)
endfunction "}}}

function! s:get_mininum_index() "{{{
  " HighlightWord に使われている中で、1番少ない物を返す
  let list = map(s:filter_matches(
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'str2nr(v:val["group"][13:-1])') " len('Highlightword') is 13

  let cnt = -1
  let cur = 0

  for i in range(s:get_highlight_count())
    let t = count(list, i)
    if t < cnt || cnt < 0
      let cnt = t
      let cur = i
    endif
  endfor

  return cur
endfunction "}}}

function! s:match_word_remove(pattern) "{{{
  " 指定した単語を matchdelete() する
  " カレントバッファのみ
  let list = map(s:filter_matches(
        \ 'v:val["pattern"][2:-3] == a:1', a:pattern),
        \ 'v:val["id"]')

  for d in list
    call matchdelete(d)
  endfor
endfunction "}}}

function! s:match_highlight_remove() "{{{
  " すべての単語を HighlightWord から削除する
  " カレントバッファのみ
  let list = map(s:filter_matches(
        \ 'v:val["group"] =~ "^HighlightWord"'),
        \ 'v:val["id"]')

  for d in list
    call matchdelete(d)
  endfor
endfunction "}}}

augroup Highlightword "{{{
  autocmd!
  autocmd BufWinEnter,ColorScheme * call HighlightWordsDefHighlight()
  autocmd WinEnter                * call HighlightWordsStashPop()
  autocmd WinLeave                * call HighlightWordsStash()
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
