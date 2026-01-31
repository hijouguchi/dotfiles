let s:save_cpo = &cpo
set cpo&vim

function! gitui#core#git_root(dir) abort
  if !executable('git')
    echohl ErrorMsg | echom 'git is not available' | echohl None
    return ''
  endif

  let l:cmd = gitui#core#git_cmd(a:dir, ['rev-parse', '--show-toplevel'])
  let l:out = systemlist(l:cmd)
  if v:shell_error || empty(l:out)
    return ''
  endif
  return l:out[0]
endfunction

function! gitui#core#current_file_path() abort
  let l:path = expand('%:p')
  if empty(l:path)
    echohl ErrorMsg | echom 'no file for current buffer' | echohl None
    return ''
  endif
  return l:path
endfunction

function! gitui#core#relative_path(root, path) abort
  let l:root = fnamemodify(a:root, ':p')
  let l:root = substitute(l:root, '/\+$', '', '')
  let l:path = fnamemodify(a:path, ':p')
  if l:path[:len(l:root) - 1] ==# l:root && l:path[len(l:root)] ==# '/'
    return l:path[len(l:root) + 1:]
  endif
  return a:path
endfunction

function! gitui#core#normalize_pathspec(root, rel) abort
  let l:rel = a:rel
  if empty(l:rel)
    return l:rel
  endif
  if filereadable(a:root . '/' . l:rel) || isdirectory(a:root . '/' . l:rel)
    return l:rel
  endif
  if l:rel[0] !=# '.' && (filereadable(a:root . '/.' . l:rel) || isdirectory(a:root . '/.' . l:rel))
    return '.' . l:rel
  endif
  return l:rel
endfunction

function! gitui#core#git_run(root, args) abort
  let l:cmd = gitui#core#git_cmd(a:root, a:args)
  let l:out = systemlist(l:cmd)
  if v:shell_error
    echohl ErrorMsg | echom l:cmd | echohl None
  endif
  return l:out
endfunction

function! gitui#core#git_cmd(root, args) abort
  let l:parts = ['git', '-C', a:root]
  call extend(l:parts, a:args)
  return join(map(copy(l:parts), 'shellescape(v:val)'))
endfunction

function! gitui#core#git_file_status(root, rel) abort
  let l:out = gitui#core#git_run(a:root, ['status', '--porcelain=v1', '--', a:rel])
  if v:shell_error || empty(l:out)
    return #{staged: v:false, unstaged: v:false, untracked: v:false}
  endif
  let l:line = l:out[0]
  if l:line[0:1] ==# '??'
    return #{staged: v:false, unstaged: v:false, untracked: v:true}
  endif
  return #{
        \ staged:   l:line[0] !=# ' ',
        \ unstaged: l:line[1] !=# ' ',
        \ untracked: v:false
        \ }
endfunction

function! gitui#core#open_scratch(name, filetype, where) abort
  if bufexists(a:name)
    let l:bnr = bufnr(a:name)
    let l:wnr = bufwinnr(l:bnr)
    if l:wnr != -1
      execute l:wnr . 'wincmd w'
    else
      execute 'sbuffer ' . l:bnr
    endif
  else
    if a:where ==# 'botleft'
      if exists(':botleft')
        botleft new
      else
        new | wincmd J
      endif
    elseif a:where ==# 'botright'
      if exists(':botright')
        botright new
      else
        new | wincmd J | wincmd L
      endif
    elseif a:where ==# 'tab'
      tabnew
    else
      new
    endif
    execute 'file ' . a:name
  endif

  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal modifiable
  let &l:filetype = a:filetype
endfunction

function! gitui#core#buffer_set_lines(lines) abort
  setlocal modifiable
  if empty(a:lines)
    call setline(1, [''])
  else
    call setline(1, a:lines)
  endif
  setlocal nomodifiable
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
