augroup WickedAU
	autocmd!
	autocmd BufNewFile,BufRead *.wick set filetype=wicked
augroup END

function! WickedSourcePush()
	if(!exists('w:wicked_file_stack'))
		let w:wicked_file_stack = []
	endif

	let l:line = getline('.')

	" カーソルより左の部分が "[[..." となっているかどうか
	let l:start = match(l:line[:col('.')], '\[\[[^\]]*$')
	" カーソルより右の部分が "..]]" となっているかどうか
	let l:end   = match(l:line[col('.'):], '^[^\[]*\]\]')

	" カーソル部分が "[[...]]" の内部なら処理を始める
	if(l:start == -1 || l:end == -1) | return | endif

	let l:regexp = '\%(\[\[\)\@<=\%(\h\w*\)\%(/\h\w*\)*\%(:\h\w*\)*'
	let l:source_str = matchstr(l:line, l:regexp, l:start)

	let l:dir_name = split(l:source_str, ':')
	"let l:path_file = split(l:dir_name[0], '/')
	let l:head_name = get(l:dir_name, 1, '')

	let l:file_list = [expand('%'), line('.'), col('.')]
	call add(w:wicked_file_stack, l:file_list)
	execute 'edit ~/wicked/'.l:dir_name[0].'.wick'
	if(l:head_name != '')
		call search('^=\+\s*\['.l:head_name.'\]')
		normal zt
	endif

endfunction

function! WickedSourcePull()
	if(exists('w:wicked_file_stack') && !empty(w:wicked_file_stack))
		let l:file_list = remove(w:wicked_file_stack, -1)
		execute 'edit '.l:file_list[0]
		call cursor(l:file_list[1], l:file_list[2])
	endif
endfunction
