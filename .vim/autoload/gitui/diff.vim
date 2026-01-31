let s:save_cpo = &cpo
set cpo&vim

" Open a vertical diff view against HEAD or index for a repo path.
" The right split shows the base content while the current buffer is diffed.
" Keeps the original filetype for proper highlighting.
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

" Diff the current buffer file against HEAD/index using a repo-relative path.
" Resolves the git root from the current buffer location.
" Delegates to gitui#diff#file for the actual diff view.
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

" Stage the current buffer file via git add.
" Converts the current file path to a repo-relative path.
" Does not prompt; failures are reported by gitui#core#git_run.
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

" Restore changes for the current buffer (unstage or discard working tree).
" Staged files are unstaged; unstaged files can be discarded with confirm.
" Untracked files are reported without changes.
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

" Render a single-buffer blame view (meta + code) in a botright split.
" Builds a fixed-width meta column followed by the original code.
" The resulting buffer is scratch and non-editable.
function! gitui#diff#blame_file(path, root, code_ft) abort
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

  let l:blame_buf = bufnr('[git-blame]')
  if l:blame_buf == -1
    try
      botright new
    catch
      new
    endtry
    execute 'file [git-blame]'
  else
    try
      botright split
    catch
      new
    endtry
    execute 'buffer ' . l:blame_buf
  endif

  let l:blame_win = win_getid()
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setlocal nowrap nonumber norelativenumber foldcolumn=0 signcolumn=no
  setlocal modifiable
  let &l:filetype = 'gitblame'
  let l:prefix_width = 30
  let b:gitui_blame_prefix_width = l:prefix_width
  let b:gitui_blame_code_ft = a:code_ft
  unlet! b:gitui_blame_syntax_done
  let l:blame_lines = s:blame_render_lines(l:entries, l:prefix_width)
  call gitui#core#buffer_set_lines(l:blame_lines)
  setlocal nomodifiable

  call gitui#diff#blame_define_highlights()
  call setbufvar(winbufnr(l:blame_win), 'gitui_blame_entries', l:entries)
  call win_execute(l:blame_win, 'call gitui#diff#blame_apply_matches()')

  call win_execute(l:blame_win, 'call gitui#diff#blame_enable_syntax()')
  call win_execute(l:blame_win, 'normal! gg')
endfunction

" Parse blame porcelain into per-line metadata and code text.
" Extracts hash, author, and author-time for each line.
" The tab-prefixed code line becomes the displayed code portion.
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
      call add(l:entries, #{hash: l:hash, author: l:author, time: l:time, code: l:line[1:]})
      continue
    endif
  endfor

  return l:entries
endfunction

" Build blame lines: fixed-width meta + separator + code.
" The meta column is padded/truncated to a stable width.
" Returns a list of display lines for the blame buffer.
function! s:blame_render_lines(entries, prefix_width) abort
  let l:lines = []
  let l:sep = ' | '
  let l:width = a:prefix_width
  for l:entry in a:entries
    let l:hash = empty(l:entry.hash) ? '--------' : l:entry.hash[0:7]
    let l:date = (l:entry.time > 0) ? strftime('%Y-%m-%d', l:entry.time) : '----------'
    let l:author = empty(l:entry.author) ? '(unknown)' : l:entry.author
    let l:meta = printf('%s %s %s', l:hash, l:date, l:author)
    let l:meta = s:blame_fit_width(l:meta, l:width)
    call add(l:lines, l:meta . l:sep . l:entry.code)
  endfor
  if empty(l:lines)
    return ['']
  endif
  return l:lines
endfunction

" Clamp or pad text to a fixed display width for meta alignment.
" Uses display width to handle multi-byte characters safely.
" Returns a string exactly at the requested width.
function! s:blame_fit_width(text, width) abort
  let l:text = a:text
  if strdisplaywidth(l:text) > a:width
    let l:text = strcharpart(l:text, 0, a:width)
  endif
  let l:pad = a:width - strdisplaywidth(l:text)
  if l:pad > 0
    let l:text .= repeat(' ', l:pad)
  endif
  return l:text
endfunction

" Define highlight groups for blame age buckets and separator.
" Uses default links so colors remain user-theme friendly.
" The separator has its own group to avoid filetype variance.
function! gitui#diff#blame_define_highlights() abort
  highlight default link GitBlameAge1 DiffAdd
  highlight default link GitBlameAge2 DiffChange
  highlight default link GitBlameAge3 DiffDelete
  highlight default link GitBlameAge4 Comment
  highlight default link GitBlameAge5 NonText
  highlight default link GitBlameSeparator NonText
endfunction

" Apply per-line highlight based on blame age and separator width.
" Creates match positions for each age bucket and the separator.
" Stores match ids so they can be replaced on refresh.
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
  let l:width = get(b:, 'gitui_blame_prefix_width', 30)
  let l:age1 = []
  let l:age2 = []
  let l:age3 = []
  let l:age4 = []
  let l:age5 = []
  let l:seps = []

  let l:lnum = 1
  for l:entry in b:gitui_blame_entries
    let l:age_days = (l:entry.time > 0) ? float2nr((l:now - l:entry.time) / 86400.0) : 99999
    let l:pos = [l:lnum, 1, l:width]
    if l:age_days <= 1
      call add(l:age1, l:pos)
    elseif l:age_days <= 7
      call add(l:age2, l:pos)
    elseif l:age_days <= 30
      call add(l:age3, l:pos)
    elseif l:age_days <= 180
      call add(l:age4, l:pos)
    else
      call add(l:age5, l:pos)
    endif
    call add(l:seps, [l:lnum, l:width + 1, strchars(' | ')])
    let l:lnum += 1
  endfor

  if !empty(l:age1)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge1', l:age1))
  endif
  if !empty(l:age2)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge2', l:age2))
  endif
  if !empty(l:age3)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge3', l:age3))
  endif
  if !empty(l:age4)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge4', l:age4))
  endif
  if !empty(l:age5)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameAge5', l:age5))
  endif
  if !empty(l:seps)
    call add(b:gitui_blame_match_ids, matchaddpos('GitBlameSeparator', l:seps))
  endif
endfunction

" Enable target filetype syntax in blame buffer (code portion).
" Sets local syntax to match the original filetype.
" Keeps blame metadata coloring via match highlights.
function! gitui#diff#blame_enable_syntax() abort
  if !exists('b:gitui_blame_prefix_width')
    return
  endif
  let l:ft = get(b:, 'gitui_blame_code_ft', '')
  if empty(l:ft)
    return
  endif
  if exists('b:gitui_blame_syntax_done')
    return
  endif
  let b:gitui_blame_syntax_done = 1
  if l:ft ==# 'zsh' && !exists('b:is_sh')
    let b:is_sh = 1
  endif
  silent! syntax enable
  silent! execute 'setlocal syntax=' . l:ft
  silent! execute 'syntax clear GitBlameCode'
endfunction

" Open blame for the current buffer file with detected filetype.
" Resolves repo root and relative path from the current buffer.
" Passes the filetype so the blame buffer can apply syntax.
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
  let l:ft = &filetype
  call gitui#diff#blame_file(l:rel, l:root, l:ft)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
