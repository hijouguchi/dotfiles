" alignlight.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>

" if exists("g:loaded_alignlight")
"   finish
" endif
let g:loaded_alignlight = 1

let s:save_cpo = &cpo
set cpo&vim

let g:alignlight_separator = {
      \ ','  : ',',
      \ ':'  : ':',
      \ '='  : '[=><!]\?=',
      \ '=>' : '=>',
      \ '|'  : '|\([^\s.]\+\.\)\?'
      \ }

command! -range -nargs=* AlignLight <line1>,<line2>call AlignLight(<f-args>)

function! AlignLight(...) range abort "{{{
  "XXX: とりあえず , のみ
  let sep = get(g:alignlight_separator, a:1, ',')

  " make bufline
  let bufline = s:make_bufline(sep, a:firstline, a:lastline)

  " search maximum number of charactors of each word, separator
  let elm_chars_list = s:make_elm_chars_list(bufline)

  " aligment
  let align = s:make_alignment(elm_chars_list, bufline)

  " 行を書き換え
  let cursor = getpos('.')
  execute a:firstline.','.a:lastline.'d _'
  call append(a:firstline-1, align)
  call cursor(cursor)
endfunction "}}}

function! s:make_bufline(sep, line1, line2) abort "{{{
  let pat  = '\s*'    . a:sep . '\s*'    " セパレータ境界
  let patl = '\s*\zs' . a:sep . '\s*'    " 左スペース
  let patr = '\s*'    . a:sep . '\s*\zs' " 右スペース

  " make bufline
  let bufline = []
  " item format is [getline(), [offset, ... ]]
  for line in getline(a:line1, a:line2)
    " ignore indent
    let idx = matchend(line, '^\s*')
    let tmp = [idx]
    " item is here...
    " 4i:   word      (ceil(N/4) items)
    " 4i+2: separator (floor(N/4) items)
    " 2i+1: space

    while 1
      let st = match(line, pat, idx)

      if st == -1
        call add(tmp, strchars(line))
        break
      endif

      let idxl = match(line, patl, idx)
      let idxr = match(line, patr, idx)
      let idx = matchend(line, pat, idx)
      call extend(tmp, [st, idxl, idxr, idx])
    endwhile

    call add(bufline, [line, tmp])
  endfor

  return bufline
endfunction "}}}

function! s:make_elm_chars_list(bufline) abort "{{{
  let elm_cnt_max = float2nr(ceil(max(
        \ map(copy(a:bufline), 'len(v:val[1])'))/4.0))

  " search maximum number of charactors of each word, separator
  let elm_chars_list = []
  for i in range(2*elm_cnt_max-1)
    let tmp = max(map(copy(a:bufline),
          \ 'len(v:val[1]) > 2*i ? v:val[1][2*i+1]-v:val[1][2*i] : 0'))
    call add(elm_chars_list, tmp)
  endfor

  return elm_chars_list
endfunction "}}}

function! s:make_alignment(elm_chars_list, bufline) abort "{{{
  " インデント保持のため、1行目のインデントをコピー
  let ind = matchstr(getline(a:bufline[0][0]), '^\s*')

  let align = []
  for b in a:bufline
    let [line, tmp] = b

    let s = ind
    for i in range(float2nr(floor(len(tmp)/4.0)))
      let word = strpart(line, tmp[4*i  ], tmp[4*i+1]-tmp[4*i  ])
      let sepa = strpart(line, tmp[4*i+2], tmp[4*i+3]-tmp[4*i+2])
      let s    = s . word
      let s    = s . repeat(' ', a:elm_chars_list[2*i  ]-strchars(word)+1)
      let s    = s . sepa
      let s    = s . repeat(' ', a:elm_chars_list[2*i+1]-strchars(sepa)+1)
    endfor

    " 最後の word を追加
    let s = s . strpart(line, tmp[-2], tmp[-1]-tmp[-2])
    call add(align, s)
  endfor

  return align
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
"
