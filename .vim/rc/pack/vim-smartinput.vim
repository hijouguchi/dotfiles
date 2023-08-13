let s:save_cpo = &cpo
set cpo&vim


let e = packman#config#github#new( 'kana/vim-smartinput.git')
call e.add_hook_events('InsertEnter')

function! e.post_load()
  call smartinput#map_to_trigger('i', '<Plug>(vimrc_bs)', '<BS>', '<BS>')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
"
"" vim: ts=2 sw=2 sts=2 et fdm=marker
