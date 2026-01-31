let s:save_cpo = &cpo
set cpo&vim

" Extract the path portion from a status line, handling rename arrows.
" For rename lines, returns the destination path.
" Used by status actions to resolve the file under cursor.
function! s:status_path_from_line(text) abort
  let l:path = a:text[3:]
  if l:path =~# ' -> '
    let l:parts = split(l:path, ' -> ')
    return l:parts[-1]
  endif
  return l:path
endfunction

" Fetch porcelain status lines (branch header + entry lines).
" This is the raw input used to build the status buffer sections.
" Returns [] on error.
function! s:git_status_entries(root) abort
  let l:entries = systemlist(gitui#core#git_cmd(a:root, ['status', '--porcelain=v1', '-b']))
  if v:shell_error
    return []
  endif
  return l:entries
endfunction

" Clear existing match highlights for the status buffer.
" Called before applying new staged/unstaged/untracked highlights.
" Safely handles the case where no matches exist yet.
function! s:gitstatus_clear_matches() abort
  if !exists('b:gitui_match_ids')
    return
  endif
  for l:id in b:gitui_match_ids
    call matchdelete(l:id)
  endfor
  let b:gitui_match_ids = []
endfunction

" Apply match highlights for staged/unstaged/untracked sections.
" Each category gets its own highlight group.
" The match ids are stored so they can be cleared later.
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

" Keep cursor within buffer bounds when refreshing.
" Ensures the target line is valid after a redraw.
" Prevents cursor errors when the list length changes.
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

" Determine which section the cursor is currently in by scanning upward.
" Used to decide which restore action is appropriate.
" Returns '', 'staged', 'unstaged', or 'untracked'.
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

" Resolve the file path for the current cursor line or ''.
" Prefers cached line->path mappings, falls back to parsing the text.
" Returns '' for headers and blank lines.
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

" Open or refresh the git status buffer and rebuild all sections.
" Populates the buffer text and sets up match highlights.
" Keeps the cursor position when possible.
function! gitui#status#open() abort
  let l:dir = expand('%:p:h')
  if empty(l:dir)
    let l:dir = getcwd()
  endif
  let l:root = gitui#core#git_root(l:dir)
  if empty(l:root)
    echohl ErrorMsg | echom 'not a git repository' | echohl None
    return
  endif

  call gitui#core#open_scratch('[git-status]', 'gitstatus', 'botright')
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
  call gitui#core#buffer_set_lines(l:out)
  call s:gitstatus_apply_matches(l:staged_lines, l:unstaged_lines, l:untracked_lines)
  if exists('b:gitui_target_line')
    call s:gitstatus_place_cursor(b:gitui_target_line)
    unlet b:gitui_target_line
  else
    call cursor(1, 1)
  endif
endfunction

" Refresh status buffer and keep cursor near the previous line.
" Optional argument specifies the target line for the new view.
" Used after add/restore actions.
function! gitui#status#refresh(...) abort
  if a:0 > 0
    let b:gitui_target_line = a:1
  endif
  call gitui#status#open()
endfunction

" Stage the file under the cursor in the status buffer.
" Moves to the next line to preserve navigation flow.
" Refreshes the status buffer after git add.
function! gitui#status#add_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:next_line = line('.') + 1
  call gitui#core#git_run(b:gitui_root, ['add', '--', l:path])
  call gitui#status#refresh(l:next_line)
endfunction

" Restore file changes for the cursor line based on section.
" Staged files are unstaged; unstaged files can be discarded with confirm.
" Other sections show a warning.
function! gitui#status#restore_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:section = s:gitstatus_current_section()
  let l:next_line = line('.')
  if l:section ==# 'staged'
    call gitui#core#git_run(b:gitui_root, ['restore', '--staged', '--', l:path])
    call gitui#status#refresh(l:next_line)
    return
  elseif l:section ==# 'unstaged'
    let l:msg = 'Restore working tree for ' . l:path . '?'
    if confirm(l:msg, "&Yes\n&No", 2) != 1
      return
    endif
    call gitui#core#git_run(b:gitui_root, ['restore', '--', l:path])
    call gitui#status#refresh(l:next_line)
    return
  else
    echohl WarningMsg | echom 'restore is not supported for this line' | echohl None
  endif
endfunction

" Diff the file under cursor (HEAD or index).
" The cached flag switches between working tree and index diff.
" Opens a vertical diff view.
function! gitui#status#diff_line(cached) abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  call gitui#diff#file(l:path, a:cached, b:gitui_root)
endfunction

" Open blame for the file under cursor (preserve filetype).
" Ensures filetype is captured even when the file is not loaded.
" Delegates to the blame view builder.
function! gitui#status#blame_line() abort
  let l:path = s:gitstatus_get_path()
  if empty(l:path)
    return
  endif
  let l:full = b:gitui_root . '/' . l:path
  let l:bnr = bufnr(l:full)
  if l:bnr == -1
    execute 'badd ' . fnameescape(l:full)
    let l:bnr = bufnr(l:full)
  endif
  let l:ft = getbufvar(l:bnr, '&filetype')
  call gitui#diff#blame_file(l:path, b:gitui_root, l:ft)
endfunction

" Open the file under cursor in the current window.
" Reuses existing buffers and avoids reopening on each entry.
" Clears status highlights before switching buffers.
function! gitui#status#open_file() abort
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

" Define buffer-local mappings for git status actions.
" Keeps mappings local to the gitstatus buffer.
" Keys provide open/add/restore/diff/blame/refresh.
function! gitui#status#setup_buffer() abort
  setlocal nowrap
  nnoremap <silent><buffer> q :close<CR>
  nnoremap <silent><buffer> <CR> :<C-u>call gitui#status#open_file()<CR>
  nnoremap <silent><buffer> a :<C-u>call gitui#status#add_line()<CR>
  nnoremap <silent><buffer> r :<C-u>call gitui#status#restore_line()<CR>
  nnoremap <silent><buffer> d :<C-u>call gitui#status#diff_line(0)<CR>
  nnoremap <silent><buffer> D :<C-u>call gitui#status#diff_line(1)<CR>
  nnoremap <silent><buffer> b :<C-u>call gitui#status#blame_line()<CR>
  nnoremap <silent><buffer> gr :<C-u>call gitui#status#refresh()<CR>
endfunction

" Define syntax groups and highlights for branch/section/status lines.
" Highlights section headers and staged/unstaged/untracked entries.
" Uses default links so user colors can override.
function! gitui#status#setup_syntax() abort
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

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
