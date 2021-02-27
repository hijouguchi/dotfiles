setlocal commentstring=\ //%s

command! -buffer InsertIncludeGuard call <SID>InsertIncludeGuard()

setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

function! s:InsertIncludeGuard()
	let l:def_str = toupper(expand("%"))
	let l:def_str = substitute(l:def_str, '\W\+', '_', 'g')
	let l:def_str = l:def_str . '_' . strftime("%Y%m%d%H%M%S")
	call append(0, ['#ifndef ' . l:def_str, '#define ' . l:def_str, ''])
	call append(line('$'), ['', '#endif'])
endfunction
