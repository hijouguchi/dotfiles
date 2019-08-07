let s:save_cpo = &cpo
set cpo&vim

command! Cd cd %:h

command! -bang Utf8  e<bang> ++enc=utf-8
command! -bang Euc   e<bang> ++enc=euc-jp
command! -bang Cp932 e<bang> ++enc=cp932
command! -bang Jis   e<bang> ++enc=iso-2022-jp

command! -bang Unix  e<bang> ++ff=unix
command! -bang Mac   e<bang> ++ff=mac
command! -bang Dos   e<bang> ++ff=dos

command! Ruby silent new [ruby] | setl bt=nofile ft=ruby

command! Tab2 call <SID>set_indent_style(2)
command! Tab4 call <SID>set_indent_style(4)

command! -nargs=* -complete=file Diff call <SID>diff_start(<f-args>)

command! HighlightName call <SID>get_syn_id()

command! -range=% Reverse <line1>,<line2>call <SID>my_reverse()

command! -nargs=* -complete=file Grep silent grep<bang> <args>

function! s:diff_start(...) abort "{{{
  " MEMO: botright vertical にしたいから 'diffopt' の vertical
  " オプションは使わない
  let fname = expand('%')

  " make new tab page
  tabnew

  if a:0 == 0
    ":help DiffOrig
    " open curernt buffers
    execute 'edit' fname

    let ft=&l:filetype
    botright vertical new
    setlocal buftype=nofile
    let &l:filetype=ft
    read ++edit #
    0d_
    diffthis
    wincmd p
    diffthis
  elseif a:0 == 1
    execute 'edit' fname
    diffthis
    execute 'botright vertical diffsplit' a:1
  else
    tabnew
    execute 'edit ' . a:1
    for i in range(1,a:0-1)
      execute 'botright vertical diffsplit ' . a:000[i]
    endfor
  endif

  return
endfunction "}}}
function! s:get_syn_id() "{{{
  let l:id    = synID(line("."), col("."), 1)
  let l:trans = synIDtrans(l:id)
  execute 'highlight ' . synIDattr(l:id, 'name')
  if l:trans != l:id
    execute 'highlight ' . synIDattr(l:trans, 'name')
  end
endfunction "}}}
function! s:my_reverse() range "{{{
  let l:line = line('.')

  let l:lines = reverse(getline(a:firstline, a:lastline))
  let l:num   = len(l:lines)

  if l:num <= 1
    return
  endif

  call cursor(a:firstline, 0)
  execute 'normal '.l:num.'dd'
  call append(a:firstline-1, l:lines)
  call cursor(l:line, 0)
endfunction "}}}
function! s:set_indent_style(length) "{{{
  setlocal expandtab
  execute 'setlocal tabstop='     . a:length
  execute 'setlocal shiftwidth='  . a:length
  execute 'setlocal softtabstop=' . a:length

  let str = &l:expandtab ? '  expandtab' : 'noexpandtab'
  let str = str . ' tabstop='     . a:length
  let str = str . ' shiftwidth='  . a:length
  let str = str . ' softtabstop=' . a:length
  echo str
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
