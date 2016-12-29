let s:save_cpo = &cpo
set cpo&vim

let elm = {'event': ['InsertEnter']}

function! elm.post_func()
  call smartinput#map_to_trigger('i', '<Plug>(vimrc_bs)', '<BS>', '<BS>')
endfunction

PackManAddLazy 'kana/vim-smartinput.git',elm

let &cpo = s:save_cpo
unlet s:save_cpo
"
"" vim: ts=2 sw=2 sts=2 et fdm=marker
