"inoremap .  .<C-X><C-O><C-P>
"inoremap :: ::<C-X><C-O><C-P>
"setlocal omnifunc=rubycomplete#Complete
set expandtab
set smarttab
compiler ruby
setlocal makeprg=ruby\ -c\ %
nnoremap <buffer> <Space>e :<c-u>!time ruby %<cr>
nnoremap <buffer> <Space>s :<c-u>!ruby -c %<cr>
