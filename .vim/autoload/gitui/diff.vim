let s:save_cpo = &cpo
set cpo&vim

function! gitui#diff#file(path, cached, root) abort
  let l:repo_path = a:path
  let l:src = a:root . '/' . l:repo_path
  if !filereadable(l:src)
    echohl ErrorMsg | echom 'file not found: ' . l:src | echohl None
    return
  endif

  let l:ft = &filetype
  let l:hash = systemlist(gitui#core#git_cmd(a:root, ['rev-parse', '--short', 'HEAD']))
  let l:hash = (!v:shell_error && !empty(l:hash)) ? l:hash[0] : 'HEAD'
  let l:title = fnamemodify(l:repo_path, ':t') . ' (' . l:hash . ')'

  let l:args = []
  if a:cached
    let l:args = ['show', ':' . l:repo_path]
  else
    let l:args = ['show', 'HEAD:' . l:repo_path]
  endif

  let l:content = systemlist(gitui#core#git_cmd(a:root, l:args))
  if v:shell_error
    echohl ErrorMsg | echom 'failed to get base content' | echohl None
    return
  endif

  diffthis
  botright vertical new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal modifiable
  execute 'file ' . fnameescape(l:title)
  if empty(l:content)
    call setline(1, [''])
  else
    call setline(1, l:content)
  endif
  setlocal nomodifiable readonly
  let &l:filetype = l:ft
  diffthis
endfunction

function! gitui#diff#current(cached) abort
  let l:path = gitui#core#current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = gitui#core#git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = gitui#core#relative_path(l:root, l:path)
  let l:rel = gitui#core#normalize_pathspec(l:root, l:rel)
  call gitui#diff#file(l:rel, a:cached, l:root)
endfunction

function! gitui#diff#add_current() abort
  let l:path = gitui#core#current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = gitui#core#git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = gitui#core#relative_path(l:root, l:path)
  let l:rel = gitui#core#normalize_pathspec(l:root, l:rel)
  call gitui#core#git_run(l:root, ['add', '--', l:rel])
endfunction

function! gitui#diff#restore_current() abort
  let l:path = gitui#core#current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = gitui#core#git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = gitui#core#relative_path(l:root, l:path)
  let l:rel = gitui#core#normalize_pathspec(l:root, l:rel)
  let l:st = gitui#core#git_file_status(l:root, l:rel)
  if l:st.staged
    call gitui#core#git_run(l:root, ['restore', '--staged', '--', l:rel])
    return
  endif
  if l:st.unstaged
    let l:msg = 'Restore working tree for ' . l:rel . '?'
    if confirm(l:msg, "&Yes\n&No", 2) != 1
      return
    endif
    call gitui#core#git_run(l:root, ['restore', '--', l:rel])
    return
  endif
  if l:st.untracked
    echohl WarningMsg | echom 'file is untracked' | echohl None
    return
  endif
  echohl WarningMsg | echom 'no changes to restore' | echohl None
endfunction

function! gitui#diff#blame_file(path, root) abort
  let l:full = a:root . '/' . a:path
  if !filereadable(l:full)
    echohl ErrorMsg | echom 'file not found: ' . l:full | echohl None
    return
  endif

  let l:raw = gitui#core#git_run(a:root, ['blame', '--line-porcelain', '--', a:path])
  if v:shell_error || empty(l:raw)
    return
  endif

  let l:entries = s:blame_parse_porcelain(l:raw)
  if empty(l:entries)
    return
  endif

  let l:code_win = win_getid()
  let l:blame_buf = bufnr('[git-blame]')
  if l:blame_buf != -1
    let l:blame_winnr = bufwinnr(l:blame_buf)
    if l:blame_winnr != -1
      execute l:blame_winnr . 'wincmd w'
    else
      vnew
      wincmd H
      execute 'buffer ' . l:blame_buf
    endif
  else
    vnew
    wincmd H
    execute 'file [git-blame]'
  endif

  let l:blame_win = win_getid()
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal nowrap nonumber norelativenumber foldcolumn=0 signcolumn=no
  setlocal modifiable
  let &l:filetype = 'gitblame'
  let l:blame_lines = s:blame_render_lines(l:entries)
  call gitui#core#buffer_set_lines(l:blame_lines)
  setlocal nomodifiable
  call win_execute(l:blame_win, 'vertical resize 38')
  call win_execute(l:blame_win, 'setlocal winfixwidth')

  call gitui#diff#blame_define_highlights()
  call setbufvar(winbufnr(l:blame_win), 'gitui_blame_entries', l:entries)
  call win_execute(l:blame_win, 'call gitui#diff#blame_apply_matches()')

  call win_execute(l:blame_win, 'setlocal scrollbind cursorbind scrollopt=ver,jump')
  call win_execute(l:code_win, 'setlocal scrollbind cursorbind scrollopt=ver,jump')
  call win_execute(l:blame_win, 'normal! gg')
  call win_gotoid(l:code_win)
endfunction

function! s:blame_parse_porcelain(lines) abort
  let l:entries = []
  let l:hash = ''
  let l:author = ''
  let l:time = 0

  for l:line in a:lines
    if l:line =~# '^[0-9a-f]\{8,40}\s'
      let l:hash = split(l:line)[0]
      let l:author = ''
      let l:time = 0
      continue
    endif
    if l:line =~# '^author '
      let l:author = l:line[7:]
      continue
    endif
    if l:line =~# '^author-time '
      let l:time = str2nr(l:line[12:])
      continue
    endif
    if l:line =~# '^\t'
      call add(l:entries, #{hash: l:hash, author: l:author, time: l:time})
      continue
    endif
  endfor

  return l:entries
endfunction

function! s:blame_render_lines(entries) abort
  let l:lines = []
  for l:entry in a:entries
    let l:hash = empty(l:entry.hash) ? '--------' : l:entry.hash[0:7]
    let l:date = (l:entry.time > 0) ? strftime('%Y-%m-%d', l:entry.time) : '----------'
    let l:author = empty(l:entry.author) ? '(unknown)' : l:entry.author
    call add(l:lines, printf('%s %s %s', l:hash, l:date, l:author))
  endfor
  if empty(l:lines)
    return ['']
  endif
  return l:lines
endfunction

function! gitui#diff#blame_define_highlights() abort
  highlight default link GitBlameAge1 DiffAdd
  highlight default link GitBlameAge2 DiffChange
  highlight default link GitBlameAge3 DiffDelete
  highlight default link GitBlameAge4 Comment
  highlight default link GitBlameAge5 NonText
endfunction

function! gitui#diff#blame_apply_matches() abort
  if !exists('b:gitui_blame_entries')
    return
  endif
  if exists('b:gitui_blame_match_ids')
    for l:id in b:gitui_blame_match_ids
      call matchdelete(l:id)
    endfor
  endif
  let b:gitui_blame_match_ids = []

  let l:now = localtime()
  let l:age1 = []
  let l:age2 = []
  let l:age3 = []
  let l:age4 = []
  let l:age5 = []

  let l:lnum = 1
  for l:entry in b:gitui_blame_entries
    let l:age_days = (l:entry.time > 0) ? float2nr((l:now - l:entry.time) / 86400.0) : 99999
    if l:age_days <= 1
      call add(l:age1, l:lnum)
    elseif l:age_days <= 7
      call add(l:age2, l:lnum)
    elseif l:age_days <= 30
      call add(l:age3, l:lnum)
    elseif l:age_days <= 180
      call add(l:age4, l:lnum)
    else
      call add(l:age5, l:lnum)
    endif
    let l:lnum += 1
  endfor

  if !empty(l:age1)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge1', map(l:age1, {_, v -> [v, 1, 999]})))
  endif
  if !empty(l:age2)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge2', map(l:age2, {_, v -> [v, 1, 999]})))
  endif
  if !empty(l:age3)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge3', map(l:age3, {_, v -> [v, 1, 999]})))
  endif
  if !empty(l:age4)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge4', map(l:age4, {_, v -> [v, 1, 999]})))
  endif
  if !empty(l:age5)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge5', map(l:age5, {_, v -> [v, 1, 999]})))
  endif
endfunction

function! gitui#diff#blame_current() abort
  let l:path = gitui#core#current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = gitui#core#git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = gitui#core#relative_path(l:root, l:path)
  call gitui#diff#blame_file(l:rel, l:root)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
