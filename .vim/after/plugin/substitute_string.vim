let s:save_cpo = &cpo
set cpo&vim

let g:substitite_string_commands = {
      \ 'erb'  : 'erb -T-',
      \ 'ruby' : 'ruby',
      \ 'perl' : 'perl'
      \ }

function! SubstituteString(prog) range
  let l:cmd = g:substitite_string_commands[a:prog]
  if l:cmd == ''
    execute 'echoerr ' . a:prog . ' is not found'
    return
  endif

  let l:tmpfile1 = tempname()
  call writefile(getline(a:firstline, a:lastline), l:tmpfile1)
  let l:result = systemlist(l:cmd . ' ' . l:tmpfile1 . ' 2>&1')
  call delete(l:tmpfile1)


  let l:lines = a:lastline - a:firstline + 1
  call cursor(a:firstline, 0)
  silent! execute 'silent! normal ' . l:lines . 'dd'
  silent! call append(a:firstline-1, l:result)
endfunction

command! -range -nargs=1 SubstituteString <line1>,<line2>call SubstituteString(<f-args>)


nnoremap <Space>rr :SubstituteString ruby<CR>
vnoremap <Space>rr :SubstituteString ruby<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
