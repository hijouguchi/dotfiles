" .vim/rc/bundle/vim-smartinput.vim
" Last Change: 2015-04-12
" Maintainer:  hijouguchi <taka13.mac+vim@gmail.com>

let s:save_cpo = &cpo
set cpo&vim

let g:my_smartinput_loaded = 0
NeoBundleLazy 'kana/vim-smartinput.git', {'insert' : 1 }

let s:bundle = neobundle#get('vim-smartinput')
function! s:bundle.hooks.on_source(bundle)
  call MySmartinputEnable()
endfunction
unlet s:bundle


function! MySmartinputDisable() abort "{{{
  if g:my_smartinput_loaded
    call smartinput#clear_rules()
    let g:my_smartinput_loaded = 0
  endif

  return
endfunction "}}}

function! MySmartinputEnable() abort
  if g:my_smartinput_loaded
    return
  endif

  call smartinput#define_default_rules()

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

  let g:my_smartinput_loaded = 1
endfunction

" ブロック挿入の挙動が変なので無効にさせる
vnoremap I :<C-U>call MySmartinputDisable()<CR>gvI
vnoremap A :<C-U>call MySmartinputDisable()<CR>gvA

" XXX: ブロック挿入時に <C-O> 等で Normal に戻ると呼ばれちゃうので注意
augroup MySmartinput
  autocmd!
  autocmd InsertLeave * call MySmartinputEnable()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
"
"" vim: ts=2 sw=2 sts=2 et fdm=marker
