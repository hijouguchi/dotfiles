let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_gitui')
  finish
endif
let g:loaded_gitui = 1

function! s:git_root(dir) abort
  if !executable('git')
    echohl ErrorMsg | echom 'git is not available' | echohl None
    return ''
  endif

  let l:cmd = s:git_cmd(a:dir, ['rev-parse', '--show-toplevel'])
  let l:out = systemlist(l:cmd)
  if v:shell_error || empty(l:out)
    return ''
  endif
  return l:out[0]
endfunction

function! s:current_file_path() abort
  let l:path = expand('%:p')
  if empty(l:path)
    echohl ErrorMsg | echom 'no file for current buffer' | echohl None
    return ''
  endif
  return l:path
endfunction

function! s:relative_path(root, path) abort
  let l:root = fnamemodify(a:root, ':p')
  let l:root = substitute(l:root, '/\+$', '', '')
  let l:path = fnamemodify(a:path, ':p')
  if l:path[:len(l:root) - 1] ==# l:root && l:path[len(l:root)] ==# '/'
    return l:path[len(l:root) + 1:]
  endif
  return a:path
endfunction

function! s:normalize_pathspec(root, rel) abort
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

function! s:git_run(root, args) abort
  let l:cmd = s:git_cmd(a:root, a:args)
  let l:out = systemlist(l:cmd)
  if v:shell_error
    echohl ErrorMsg | echom l:cmd | echohl None
  endif
  return l:out
endfunction

function! s:git_cmd(root, args) abort
  let l:parts = ['git', '-C', a:root]
  call extend(l:parts, a:args)
  return join(map(copy(l:parts), 'shellescape(v:val)'))
endfunction

function! s:git_file_status(root, rel) abort
  let l:out = s:git_run(a:root, ['status', '--porcelain=v1', '--', a:rel])
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

function! s:open_scratch(name, filetype, where) abort
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
      botleft new
    elseif a:where ==# 'botright'
      botright new
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

function! s:buffer_set_lines(lines) abort
  setlocal modifiable
  if empty(a:lines)
    call setline(1, [''])
  else
    call setline(1, a:lines)
  endif
  setlocal nomodifiable
endfunction

function! s:status_path_from_line(text) abort
  let l:path = a:text[3:]
  if l:path =~# ' -> '
    let l:parts = split(l:path, ' -> ')
    return l:parts[-1]
  endif
  return l:path
endfunction

function! s:git_status_entries(root) abort
  let l:entries = systemlist(s:git_cmd(a:root, ['status', '--porcelain=v1', '-b']))
  if v:shell_error
    return []
  endif
  return l:entries
endfunction

function! s:gitstatus_clear_matches() abort
  if !exists('b:gitui_match_ids')
    return
  endif
  for l:id in b:gitui_match_ids
    call matchdelete(l:id)
  endfor
  let b:gitui_match_ids = []
endfunction

function! s:gitstatus_apply_matches(staged_lines, unstaged_lines, untracked_lines) abort
  call s:gitstatus_clear_matches()
  let b:gitui_match_ids = []

  if !empty(a:staged_lines)
    let l:pos = map(copy(a:staged_lines), {_, v -> [v, 1, 999]})
    call add(b:gitui_match_ids, matchaddpos('GitStatusStaged', l:pos))
  endif
  if !empty(a:unstaged_lines)
    let l:pos = map(copy(a:unstaged_lines), {_, v -> [v, 1, 999]})
    call add(b:gitui_match_ids, matchaddpos('GitStatusUnstaged', l:pos))
  endif
  if !empty(a:untracked_lines)
    let l:pos = map(copy(a:untracked_lines), {_, v -> [v, 1, 999]})
    call add(b:gitui_match_ids, matchaddpos('GitStatusUntracked', l:pos))
  endif
endfunction

function! s:git_status_open() abort
  let l:dir = expand('%:p:h')
  if empty(l:dir)
    let l:dir = getcwd()
  endif
  let l:root = s:git_root(l:dir)
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif

  call s:open_scratch('[git-status]', 'gitstatus', 'botright')
  setlocal bufhidden=hide
  let b:gitui_root = l:root

  let l:entries = s:git_status_entries(l:root)

  let l:branch = ''
  let l:staged = []
  let l:unstaged = []
  let l:untracked = []

  let l:i = 0
  while l:i < len(l:entries)
    let l:entry = l:entries[l:i]
    if l:entry =~# '^## '
      let l:branch = l:entry[3:]
      let l:i += 1
      continue
    endif
    if empty(l:entry)
      let l:i += 1
      continue
    endif

    let l:status = l:entry[0:1]
    let l:path = s:status_path_from_line(l:entry)
    let l:display = l:status . ' ' . l:entry[3:]

    if l:status ==# '??'
      call add(l:untracked, #{display: l:display, path: l:path})
    else
      if l:status[0] !=# ' '
        call add(l:staged, #{display: l:display, path: l:path})
      endif
      if l:status[1] !=# ' '
        call add(l:unstaged, #{display: l:display, path: l:path})
      endif
    endif
    let l:i += 1
  endwhile

  let l:out = []
  let l:line_paths = {}
  let l:staged_lines = []
  let l:unstaged_lines = []
  let l:untracked_lines = []
  let l:lnum = 0

  call add(l:out, 'Branch: ' . (empty(l:branch) ? '(unknown)' : l:branch))
  let l:lnum += 1
  call add(l:out, '')
  let l:lnum += 1
  call add(l:out, 'Staged:')
  let l:lnum += 1
  for l:item in l:staged
    call add(l:out, '  ' . l:item.display)
    let l:lnum += 1
    let l:line_paths[l:lnum] = l:item.path
    call add(l:staged_lines, l:lnum)
  endfor

  call add(l:out, '')
  let l:lnum += 1
  call add(l:out, 'Unstaged:')
  let l:lnum += 1
  for l:item in l:unstaged
    call add(l:out, '  ' . l:item.display)
    let l:lnum += 1
    let l:line_paths[l:lnum] = l:item.path
    call add(l:unstaged_lines, l:lnum)
  endfor

  call add(l:out, '')
  let l:lnum += 1
  call add(l:out, 'Untracked:')
  let l:lnum += 1
  for l:item in l:untracked
    call add(l:out, '  ' . l:item.display)
    let l:lnum += 1
    let l:line_paths[l:lnum] = l:item.path
    call add(l:untracked_lines, l:lnum)
  endfor

  let b:gitui_line_paths = l:line_paths
  call s:buffer_set_lines(l:out)
  call s:gitstatus_apply_matches(l:staged_lines, l:unstaged_lines, l:untracked_lines)
  if exists('b:gitui_target_line')
    call s:gitstatus_place_cursor(b:gitui_target_line)
    unlet b:gitui_target_line
  else
    call cursor(1, 1)
  endif
endfunction

function! s:gitstatus_get_path() abort
  let l:text = getline('.')
  if l:text =~# '^Branch:' || l:text =~# '^Staged:' || l:text =~# '^Unstaged:' || l:text =~# '^\s*$'
    return ''
  endif
  let l:trim = substitute(l:text, '^\s\+', '', '')
  if l:trim =~# '^.. '
    return s:status_path_from_line(l:trim)
  endif
  if exists('b:gitui_line_paths')
    let l:lnum = line('.')
    if has_key(b:gitui_line_paths, l:lnum)
      return b:gitui_line_paths[l:lnum]
    endif
  endif
  return ''
endfunction

function! s:gitstatus_refresh(...) abort
  if a:0 > 0
    let b:gitui_target_line = a:1
  endif
  call s:git_status_open()
endfunction

function! s:gitstatus_add_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:next_line = line('.') + 1
  call s:git_run(b:gitui_root, ['add', '--', l:path])
  call s:gitstatus_refresh(l:next_line)
endfunction

function! s:gitstatus_restore_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:section = s:gitstatus_current_section()
  let l:next_line = line('.')
  if l:section ==# 'staged'
    call s:git_run(b:gitui_root, ['restore', '--staged', '--', l:path])
    call s:gitstatus_refresh(l:next_line)
    return
  elseif l:section ==# 'unstaged'
    let l:msg = 'Restore working tree for ' . l:path . '?'
    if confirm(l:msg, "&Yes\n&No", 2) != 1
      return
    endif
    call s:git_run(b:gitui_root, ['restore', '--', l:path])
    call s:gitstatus_refresh(l:next_line)
    return
  else
    echohl WarningMsg | echom 'restore is not supported for this line' | echohl None
  endif
endfunction


function! s:gitstatus_diff_line(cached) abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  call s:git_diff_file(l:path, a:cached, b:gitui_root)
endfunction

function! s:gitstatus_blame_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  call s:git_blame_file(l:path, b:gitui_root)
endfunction

function! s:gitstatus_open_file() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:full = b:gitui_root . '/' . l:path
  call s:gitstatus_clear_matches()

  let l:bnr = bufnr(l:full)
  if l:bnr == -1
    execute 'badd ' . fnameescape(l:full)
    let l:bnr = bufnr(l:full)
  endif
  execute 'buffer ' . l:bnr
endfunction

function! s:git_diff_file(path, cached, root) abort
  let l:args = ['diff']
  if a:cached
    call add(l:args, '--cached')
  endif
  call extend(l:args, ['--', a:path])
  let l:out = s:git_run(a:root, l:args)

  call s:open_scratch('[git-diff]', 'diff', 'botright')
  if empty(l:out)
    call s:buffer_set_lines(['(no changes)'])
  else
    call s:buffer_set_lines(l:out)
  endif
  normal! gg
endfunction

function! s:git_diff_current(cached) abort
  let l:path = s:current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = s:git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = s:relative_path(l:root, l:path)
  let l:rel = s:normalize_pathspec(l:root, l:rel)
  call s:git_diff_file(l:rel, a:cached, l:root)
endfunction

function! s:git_add_current() abort
  let l:path = s:current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = s:git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = s:relative_path(l:root, l:path)
  let l:rel = s:normalize_pathspec(l:root, l:rel)
  call s:git_run(l:root, ['add', '--', l:rel])
endfunction

function! s:git_restore_current() abort
  let l:path = s:current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = s:git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = s:relative_path(l:root, l:path)
  let l:rel = s:normalize_pathspec(l:root, l:rel)
  let l:st = s:git_file_status(l:root, l:rel)
  if l:st.staged
    call s:git_run(l:root, ['restore', '--staged', '--', l:rel])
    return
  endif
  if l:st.unstaged
    let l:msg = 'Restore working tree for ' . l:rel . '?'
    if confirm(l:msg, "&Yes\n&No", 2) != 1
      return
    endif
    call s:git_run(l:root, ['restore', '--', l:rel])
    return
  endif
  if l:st.untracked
    echohl WarningMsg | echom 'file is untracked' | echohl None
    return
  endif
  echohl WarningMsg | echom 'no changes to restore' | echohl None
endfunction


function! s:git_blame_file(path, root) abort
  let l:out = s:git_run(a:root, ['blame', '--date=short', '--', a:path])
  if v:shell_error
    return
  endif

  call s:open_scratch('[git-blame]', 'gitannotate', 'botleft')
  call s:buffer_set_lines(l:out)
  normal! gg
endfunction

function! s:gitstatus_place_cursor(target_line) abort
  let l:line = a:target_line
  let l:max = line('$')
  if l:line < 1
    let l:line = 1
  elseif l:line > l:max
    let l:line = l:max
  endif
  call cursor(l:line, 1)
endfunction

function! s:gitstatus_current_section() abort
  let l:lnum = line('.')
  while l:lnum >= 1
    let l:text = getline(l:lnum)
    if l:text =~# '^Staged:$'
      return 'staged'
    elseif l:text =~# '^Unstaged:$'
      return 'unstaged'
    elseif l:text =~# '^Untracked:$'
      return 'untracked'
    endif
    let l:lnum -= 1
  endwhile
  return ''
endfunction

function! s:git_blame_current() abort
  let l:path = s:current_file_path()
  if empty(l:path)
    return
  endif
  let l:root = s:git_root(expand('%:p:h'))
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif
  let l:rel = s:relative_path(l:root, l:path)
  call s:git_blame_file(l:rel, l:root)
endfunction

function! s:gitstatus_setup_buffer() abort
  setlocal nowrap
  nnoremap <silent><buffer> q :close<CR>
  nnoremap <silent><buffer> <CR> :<C-u>call <SID>gitstatus_open_file()<CR>
  nnoremap <silent><buffer> a :<C-u>call <SID>gitstatus_add_line()<CR>
  nnoremap <silent><buffer> r :<C-u>call <SID>gitstatus_restore_line()<CR>
  nnoremap <silent><buffer> d :<C-u>call <SID>gitstatus_diff_line(0)<CR>
  nnoremap <silent><buffer> D :<C-u>call <SID>gitstatus_diff_line(1)<CR>
  nnoremap <silent><buffer> b :<C-u>call <SID>gitstatus_blame_line()<CR>
  nnoremap <silent><buffer> gr :<C-u>call <SID>gitstatus_refresh()<CR>
endfunction

function! s:gitstatus_setup_syntax() abort
  syntax clear
  syntax match GitStatusBranch /^Branch:.*/
  syntax match GitStatusHeader /^Staged:$/
  syntax match GitStatusHeader /^Unstaged:$/
  syntax match GitStatusHeader /^Untracked:$/

  highlight default link GitStatusBranch Identifier
  highlight default link GitStatusHeader  Title
  highlight default link GitStatusStaged  Added
  highlight default link GitStatusUnstaged Removed
  highlight default link GitStatusUntracked Removed
endfunction

augroup GitUI
  autocmd!
  autocmd FileType gitstatus call <SID>gitstatus_setup_buffer() | call <SID>gitstatus_setup_syntax()
  autocmd BufEnter * if &l:filetype ==# 'gitstatus' | call <SID>gitstatus_refresh(line('.')) | endif
augroup END

command! GitStatus     call <SID>git_status_open()
command! GitDiff       call <SID>git_diff_current(0)
command! GitDiffCached call <SID>git_diff_current(1)
command! GitAdd        call <SID>git_add_current()
command! GitRestore    call <SID>git_restore_current()
command! GitBlame      call <SID>git_blame_current()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
