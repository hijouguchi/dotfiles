if !exists('g:neocomplcache_same_filetype_lists')
  let g:neocomplcache_same_filetype_lists = {}
endif

let ext2 = join(['ruby', substitute(&l:filetype, '^eruby.', '', '')], ',')
let g:neocomplcache_same_filetype_lists.eruby = ext2

"if empty(g:neocomplcache_same_filetype_lists)
"  unlet g:neocomplcache_same_filetype_lists
"endif

execute 'nnoremap <buffer> <Space>e ' .
      \ ':QuickRun -type eruby ' .
      \ '-outputter multi:file:buffer ' .
      \ '-outputter/buffer/filetype ' . b:eruby_subtype . ' ' .
      \ '-outputter/file/name ' . expand('%:r') . ' ' .
      \ '<CR>'
