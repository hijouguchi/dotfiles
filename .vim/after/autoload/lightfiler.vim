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

  " if !filereadable(fname)
  "   execute 'echomsg ' . fname . 'is not exist'
  "   return ''
  " endif

  if a:targ == 'here'
    execute winnr('#') . 'wincmd w'
    execute 'edit ' . fname
  elseif a:targ == 'tab'
    execute 'tabnew ' . fname
  elseif a:targ == 'split'
    execute 'split ' . fname
  elseif a:targ == 'vsplit'
    execute winnr('#') . 'wincmd w'
    execute 'vsplit ' . fname
  endif

  return ''
endfunction "}}}

function! s:transform_to_completion_dist_for_file(item) abort "{{{
  let sep = has('win32') || has('win64') ? '\' : '/'
  let item = map(copy(a:item),
        \ "isdirectory(v:val) ? v:val . '" . sep . "' : v:val")
  return map(item,
        \ "{'word': v:val, 'menu': isdirectory(v:val) ? '[dir]' : '[file]'}")
endfunction "}}}

function! lightfiler#complete_function(findstart, base) abort "{{{
  if a:findstart
    let pat      = '\(\f\|\*\)*$'
    let cur_text = getline('.')
    let base     = matchstr(cur_text, pat)

    " find files
    let list    = s:search_files(base)
    let b:items = s:transform_to_completion_dist_for_file(list)

    " add buffer
    let b:items = extend(s:search_buffers(base), b:items)

    if empty(b:items)
      return -1
    endif

    return match(cur_text, pat)
  endif

  if exists('b:items')
    return b:items
  else
    return []
  endif

endfunction "}}}

function! s:search_files(base) abort "{{{
  if a:base == ''
    return glob('*', 1, 1)
  endif

  let files  = split(a:base, '[\/]\+', 1)
  let ppath  = get(b:, 'ppath', [])
  let iseek  = 0

  " 前回と重複してるディレクトリを見つける
  let len = min([len(files), len(ppath)])
  if len > 0
    for i in range(0, len-1)
      if files[i] != ppath[i]
        let iseek = i
        break
      endif
    endfor
  endif

  " make search path
  let list = []
  let wildcard = -1

  for i in range(iseek, (len(files)-1))
    " check wildcard mode
    if files[i] == '**'
      let wildcard = i
      break
    endif

    if i != 0 || files[i] !~ '^\(\~\)\?$'
      let str  = join(files[0:i], '/')
      let list = glob(str . '*', 1, 1)

      if empty(list)
        return []
      elseif len(list) == 1
        let files[i] = matchstr(list[0], '[^\/]*$')
      else
        let files[i] = files[i] . '*'
      endif
    endif
  endfor

  let b:ppath = files

  " wildcard mode
  if wildcard != -1
    let lhs = join(files[0:(wildcard-1)], '/')

    let rhs = ''
    if wildcard < len(files)-1
      let rhs = substitute(join(files[(wildcard+1):-1], '/'),
            \ '\*', '.*', 'g')
    endif

    return glob(lhs, 1, 1)
  endif

  return list
endfunction "}}}

function! s:search_buffers(base) abort "{{{
  let buflist = []
  for i in range(tabpagenr('$'))
    call extend(buflist, tabpagebuflist(i + 1))
  endfor

  call uniq(buflist)
  call filter(buflist, 'v:val != bufnr("")') " 自分自身を削除する
  call map(buflist, 'bufname(v:val)')

  let pat = substitute(a:base, '\([.~]\)', '\\\1', 'g')
  let pat = substitute(pat, '\(\w\+\)/', '\1[^/]*/', 'g')
  let str = printf("match(v:val, '%s') != -1", pat)
  call filter(buflist, str)
  return map(buflist, "{'word': v:val, 'menu': '[buffer]'}")
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
