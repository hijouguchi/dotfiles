function! s:InsertIncludeGuard()
	let l:def_str = toupper(expand("%"))
	let l:def_str = substitute(l:def_str, '\W\+', '_', 'g')
	let l:def_str = l:def_str . '_' . strftime("%Y%m%d%H%M%S")
	call append(0, ['#ifndef ' . l:def_str, '#define ' . l:def_str, ''])
	call append(line('$'), ['', '#endif'])
endfunction

command! -buffer InsertIncludeGuard call <SID>InsertIncludeGuard()

nnoremap <buffer> [Space]m make
