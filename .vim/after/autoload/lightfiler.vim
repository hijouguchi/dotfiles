" autoload/lightfiler.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-26

" if exists("g:loaded_lightfiler")
"   finish
" endif
" let g:loaded_lightfiler = 1

let s:save_cpo = &cpo
set cpo&vim

function! lightfiler#setup() abort "{{{
  topleft 3new [filer]
  setlocal buftype=nofile
  setlocal completefunc=lightfiler#complete_function
  call lightfiler#initalize()
  call feedkeys('i> ')
  call lightfiler#set_keymap()
endfunction "}}}

function! lightfiler#initalize() abort "{{{
  " FIXME: neobundle で遅延読み込みして、かつ読み込まれない状態で
  "        このプラグインが呼ばれると NG (insert mode に入ると結局
  "        neocomplete が起動する)
  if get(g:, 'neocomplete#enable_at_startup')
    if exists('NeoCompleteDisable')
      NeoCompleteDisable
    endif
  endif

  augroup lightfiler
    autocmd!
    autocmd! CursorMovedI * call lightfiler#force_completion()
    autocmd! BufLeave     * call lightfiler#prefinalize()
    autocmd! BufEnter     * call lightfiler#finalize()
  augroup END
endfunction "}}}

function! lightfiler#prefinalize() abort "{{{
  let g:myfilter_bufnr = bufnr('%')
  return ''
endfunction "}}}

function! lightfiler#finalize() abort "{{{
  if exists('g:myfilter_bufnr') && bufexists(g:myfilter_bufnr)
    execute g:myfilter_bufnr . 'bdelete!'
    unlet g:myfilter_bufnr
  endif

  augroup lightfiler
    autocmd!
  augroup END

  if get(g:, 'neocomplete#enable_at_startup')
    if exists('NeoCompleteEnable')
      NeoCompleteEnable
    endif
  endif

  return ''
endfunction "}}}

function! lightfiler#force_completion() abort "{{{
  call feedkeys("\<C-X>\<C-U>\<C-P>")
  return ''
endfunction "}}}

function! lightfiler#set_keymap() abort "{{{
  inoremap <buffer> <CR>  <Esc>:call lightfiler#openfile('here')<CR>
  inoremap <buffer> <C-T> <Esc>:call lightfiler#openfile('tab')<CR>
  inoremap <buffer> <C-E> <Esc>:call lightfiler#openfile('split')<CR>
  inoremap <buffer> <C-V> <Esc>:call lightfiler#openfile('vsplit')<CR>
endfunction "}}}

function! lightfiler#openfile(targ) abort "{{{
  let fname = matchstr(getline('.'), '\f*$')

  if !filereadable(fname)
    execute 'echomsg ' . fname . 'is not exist'
    return ''
  endif

  if a:targ == 'here'
    execute winnr('#') . 'wincmd w'
    execute 'edit ' . fname
  elseif a:targ == 'tab'
    execute 'tabnew ' . fname
  elseif a:targ == 'split'
    execute 'split ' . fname
  elseif a:targ == 'vsplit'
    execute 'vsplit ' . fname
  endif

  return ''
endfunction "}}}

function! lightfiler#complete_function(findstart, base) abort "{{{
  if a:findstart
    let cur_text = getline('.')
    let base     = matchstr(cur_text, '\f*$')
    let list     = glob(base . '*')

    if list == ''
      let list = substitute(base, '\(\w\)\@<=/', '*/', 'g')
      let list = glob(list . '*')
    endif

    if list == ''
      let b:items = []
      return -1
    else
      let b:items = split(list, "\<NL>")
      return match(cur_text, '\f*$')
    endif
  endif

  if exists('b:items')
    return b:items
  else
    return []
  endif

endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
