NeoBundleLazy 'kana/vim-smartinput.git', {'insert' : 1 }

let s:bundle = neobundle#get('vim-smartinput')
function! s:bundle.hooks.on_source(bundle)
    call smartinput#map_to_trigger('i', '<Plug>(vimrc_cr)', '<CR>', '<CR>')
    call smartinput#define_rule({
    \ 'at': '^\%(.*=\)\?\s*\zs\%(begin\)\>\%(.*[^.:@$]\<end\>\)\@!.*\%#$',
    \ 'char': '<CR>',
    \ 'input': '<CR>end<Esc>O',
    \ 'filetype': ['verilog', 'eruby.verilog'],
    \ })

    " call smartinput#map_to_trigger('i', '%', '%', '%')
    " call smartinput#define_rule({
    "       \   'at'       : '<\%#',
    "       \   'char'     : '%',
    "       \   'input'    : '% %><Left><Left><Left>',
    "       \   'filetype' : ['eruby.verilog'],
    "       \ })
endfunction
unlet s:bundle
"
"" vim: ts=2 sw=2 sts=2 et fdm=marker
