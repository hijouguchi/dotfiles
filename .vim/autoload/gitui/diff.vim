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
  let l:out = gitui#core#git_run(a:root, ['blame', '--date=short', '--', a:path])
  if v:shell_error
    return
  endif

  call gitui#core#open_scratch('[git-blame]', 'gitannotate', 'botleft')
  call gitui#core#buffer_set_lines(l:out)
  normal! gg
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
