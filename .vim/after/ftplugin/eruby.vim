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
endif

if empty(g:neocomplcache_same_filetype_lists)
  unlet g:neocomplcache_same_filetype_lists
endif
