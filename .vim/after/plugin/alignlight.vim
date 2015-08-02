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
      \ '=' : '[=><!]\?=',
      \ '|' : '|\([^\s.]\+\.\)\?'
      \ }

command! -range -nargs=* AlignLight <line1>,<line2>call AlignLight(<f-args>)

function! AlignLight(...) range abort "{{{
  call s:getopt(a:000)

  " make bufline
  let bufline = s:parse_bufline(a:firstline, a:lastline)

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

function! s:getopt(argv) abort "{{{
  let s:sep                  = []
  let s:align                = []
  let s:ignore_no_match      = 0
  let s:separetor_sequential = 0

  let i = 0
  while i < len(a:argv)
    if (a:argv[i] == '-a' || a:argv[i] == '-align')
      let s:align = split(a:argv[i+1], '\zs')
      let i = i + 2
    elseif (a:argv[i] == '-s' || a:argv[i] == '-sequential')
      let s:separetor_sequential = 1
      let i = i + 1
    elseif (a:argv[i] == '-i' || a:argv[i] == '-ignore_no_match')
      let s:ignore_no_match  = 1
      let i = i + 1
    else
      call add(s:sep, a:argv[i])
      let i = i + 1
    endif
  endwhile
endfunction "}}}

function! s:parse_bufline(line1, line2) abort "{{{
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

    let sep_idx = 0
    while 1
      if s:separetor_sequential
        let mat = '\(' . s:sep[sep_idx % len(s:sep)] . '\)'
        let sep_idx = sep_idx + 1
      else
        let mat = '\(' . join(s:sep, '\|') . '\)'
      endif

      let pat  = '\s*'    . mat . '\s*'    " セパレータ境界
      let patl = '\s*\zs' . mat . '\s*'    " 左スペース
      let patr = '\s*'    . mat . '\zs\s*' " 右スペース
      let st = match(line, pat, idx)

      if st != -1
        let idxl = match(line, patl, idx)
        let idxr = match(line, patr, idx)
        let idx = matchend(line, pat, idx)
        call extend(tmp, [st, idxl, idxr, idx])
      endif

      if st == -1 || sep_idx == len(s:sep)
        call add(tmp, strchars(line))
        break
      endif
    endwhile

    call add(bufline, [line, tmp])
  endfor

  return bufline
endfunction "}}}

function! s:make_elm_chars_list(bufline) abort "{{{
  let elm_cnt_max = float2nr(ceil(max(
        \ map(copy(a:bufline), 'len(v:val[1])'))/4.0))

  if empty(s:align)
    let s:align = repeat(['l'], elm_cnt_max)
  elseif len(s:align) < elm_cnt_max
    call extend(s:align,
          \ repeat([s:align[-1]], elm_cnt_max-len(s:align)))
  endif

  " search maximum number of charactors of each word, separator
  " even: word, odd: separator
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
  let ind = matchstr(a:bufline[0][0], '^\s*')

  let align = []
  for b in a:bufline
    let [line, tmp] = b

    if s:ignore_no_match && len(tmp) == 2
      call add(align, line)
    else
      let s = ind
      for i in range(float2nr(len(tmp)/4.0))
        let word = strpart(line, tmp[4*i  ], tmp[4*i+1]-tmp[4*i  ])
        let sepa = strpart(line, tmp[4*i+2], tmp[4*i+3]-tmp[4*i+2])
        " let s    = s . word
        " let s    = s . repeat(' ', a:elm_chars_list[2*i  ]-strchars(word)+1)
        " let s    = s . sepa
        " let s    = s . repeat(' ', a:elm_chars_list[2*i+1]-strchars(sepa)+1)
        let spc = a:elm_chars_list[2*i  ] + a:elm_chars_list[2*i+1]
              \ - strchars(word) - strchars(sepa)

        if s:align[i] == 'l'
          let s = s . word . repeat(' ', spc+1) . sepa . ' '
        elseif s:align[i] == 'r'
          let s = s . repeat(' ', spc) . word . ' ' . sepa . ' '
        elseif s:align[i] == 'c'
          let s = s . repeat(' ', spc/2) . word . repeat(' ', spc-(spc/2)+1) . sepa . ' '
        elseif s:align[i] == 'w'
          let s = s  . word . sepa . repeat(' ', spc+1)
        endif
      endfor

      " 最後の word を追加
      let s = s . strpart(line, tmp[-2], tmp[-1]-tmp[-2])
      call add(align, s)
    endif
  endfor

  return align
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
"
