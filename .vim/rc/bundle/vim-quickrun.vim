NeoBundle 'thinca/vim-quickrun.git'
NeoBundle 'osyo-manga/quickrun-outputter-replace_region.git'
NeoBundle 'osyo-manga/shabadou.vim.git'


let g:quickrun_config = {
      \   "_" : {
      \       "outputter/buffer/split"              : ":topleft",
      \       "outputter/error/error"               : "quickfix",
      \       "outputter/error/success"             : "buffer",
      \       "outputter"                           : "error",
      \       "outputter/buffer/close_on_empty"     : 1
      \   }
      \}

" vim: ts=2 sw=2 sts=2 et fdm=marker
