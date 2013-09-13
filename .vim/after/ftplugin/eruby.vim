if !exists('g:neocomplcache_same_filetype_lists')
  let g:neocomplcache_same_filetype_lists = {}
endif

let ext2 = expand('%:r:e')

if ext2 == 'v'
  let g:neocomplcache_same_filetype_lists.eruby = 'ruby,verilog'
elseif ext2 == 'gp'
  let g:neocomplcache_same_filetype_lists.eruby = 'ruby,gnuplot'
elseif ext2 == 'sp'
  let g:neocomplcache_same_filetype_lists.eruby = 'ruby,spice'
elseif ext2 == 'il'
  let g:neocomplcache_same_filetype_lists.eruby = 'ruby,skill'
endif

if empty(g:neocomplcache_same_filetype_lists)
  unlet g:neocomplcache_same_filetype_lists
endif



function! s:ErubyPreview()
  let fname = expand('%')
  let ftype = b:eruby_subtype
  let name  = '[Preview ' . ftype .']'
  let ename  = '[Preview ' . ftype .'\]'

  if !bufexists(name)
    execute 'topleft split ' . name
    setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
    let &filetype = ftype
  elseif bufwinnr(ename) != -1
    execute bufwinnr(ename) . 'wincmd w'
    silent! %d _
  else
    topleft split enew
    execute 'buffer ' . bufnr(ename)
    let &filetype = ftype
    silent! %d _
  endif



  silent! execute 'r! erb -T - ' . fname
  silent! 1d _
  let &l:modified = 0
  call cursor(1, 1)





endfunction

"nnoremap <Space>e :!erb -T - % > %:t:r<CR>
"nnoremap <Space>e :call <SID>ErubyPreview()<CR>
execute 'nnoremap <buffer> <Space>e :QuickRun -type eruby -outputter/buffer/filetype ' . b:eruby_subtype . '<CR>'
