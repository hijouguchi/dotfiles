let s:save_cpo = &cpo
set cpo&vim

set laststatus=2

function! LightlineFilename() abort "{{{
  let file_path = bufname()
  let len_fpath = len(file_path)

  " これくらい長ければ切り詰めたほうが良いかな
  if len_fpath == 0
    return 'No Name'
  elseif len_fpath < 35
    return file_path
  else
    return pathshorten(file_path)
  endif
endfunction "}}}

function! s:dir() abort "{{{
  if expand('%') != ''
    return expand('%:p:h')
  else
    return getcwd()
  endif
endfunction "}}}

function! s:try_create_lightline_git_status() abort "{{{
  if exists('b:lightline_git_status')
    return
  endif

  let b:lightline_git_status = #{
        \   branch:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['branch'],
        \     callback:     'LightlineGitBranchCallback',
        \     job:          v:false
        \   },
        \   untracked:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['status', '--porcelain=v1', '-b'],
        \     callback:     'LightlineGitUntrackedCallback',
        \     job:          v:false
        \   },
        \   unstaged:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['status', '--porcelain=v1', '-b'],
        \     callback:     'LightlineGitUnstageCallback',
        \     job:          v:false
        \   },
        \   staged:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['status', '--porcelain=v1', '-b'],
        \     callback:     'LightlineGitStageCallback',
        \     job:          v:false
        \   },
        \   behind:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['status', '--porcelain=v1', '-b'],
        \     callback:     'LightlineGitBehindCallback',
        \     job:          v:false
        \   },
        \   ahead:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      ['status', '--porcelain=v1', '-b'],
        \     callback:     'LightlineGitAheadCallback',
        \     job:          v:false
        \   }
        \ }
endfunction "}}}

function! LightlineGitStatus(arg) abort "{{{
  call s:try_create_lightline_git_status()

  let ltime = localtime()
  let job   = b:lightline_git_status[a:arg]

  if (ltime - job.last_changed >= 60) && (job.job == v:false)
    let cmd = ['git', '-C', s:dir()]
    let cmd += (type(job.command) == v:t_list) ? job.command : [job.command]
    let job.result = ''
    let job.job = job_start(
          \ cmd,
          \ {
          \   'out_cb':  function(job.callback, [a:arg]),
          \   'err_cb':  function('LightlineGitErrorCallback', [a:arg]),
          \   'exit_cb': function('LightlineGitExitCallback', [a:arg])
          \ })
  endif

  return job.result
endfunction "}}}

function! s:GitBranchCallbackJob(target) abort "{{{
    call s:try_create_lightline_git_status()

    let job = b:lightline_git_status[a:target]

    return job
endfunction "}}}

function! s:GitBranchCallbackResult(target, text) abort "{{{
    call s:try_create_lightline_git_status()

    let job = b:lightline_git_status[a:target]

    if job.result != a:text
      let job.result = a:text
      call lightline#update()
    else
      let job.result = a:text
    endif
endfunction "}}}

function! LightlineGitExitCallback(target, job, status) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status[a:target]
  let job.last_changed = localtime()
  let job.job          = v:false
endfunction "}}}

function! LightlineGitErrorCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status[a:target]
  let job.last_changed = localtime()
  let job.job          = v:false
endfunction "}}}

function! LightlineGitBranchCallback(target, ch, msg) abort "{{{
  let job = s:GitBranchCallbackJob(a:target)

  for elm in a:msg->split('\n', 1)
    if elm[0:1] == '* '
      call s:GitBranchCallbackResult(a:target, elm[2:-1])
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitUntrackedCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status.untracked

  for elm in a:msg->split('\n', 1)
    if elm =~# '^\V?? '
      let job.result = 'untracked'
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitUnstageCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status.unstaged

  for elm in a:msg->split('\n', 1)
    if elm =~# '^## '
      continue
    endif
    if elm =~# '^\V?? '
      continue
    endif
    if len(elm) >= 2 && elm[1] !=# ' '
      let job.result = 'work'
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitStageCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status.staged

  for elm in a:msg->split('\n', 1)
    if elm =~# '^## '
      continue
    endif
    if len(elm) >= 2 && elm[0] !=# ' ' && elm[0] !=# '?'
      let job.result = 'index'
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitBehindCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status.behind

  for elm in a:msg->split('\n', 1)
    if elm =~# '^## ' && elm =~# '\<behind [0-9]\+\>'
      let job.result = 'behind'
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitAheadCallback(target, ch, msg) abort "{{{
  call s:try_create_lightline_git_status()

  let job = b:lightline_git_status.ahead

  for elm in a:msg->split('\n', 1)
    if elm =~# '^## ' && elm =~# '\<ahead [0-9]\+\>'
      let job.result = 'ahead'
      return
    endif
  endfor
endfunction "}}}

function! LightlineGitBranch() abort "{{{
  return LightlineGitStatus('branch')
endfunction "}}}

function! LightlineGitUnstaged() abort "{{{
  return LightlineGitStatus('unstaged')
endfunction "}}}

function! LightlineGitUntracked() abort "{{{
  return LightlineGitStatus('untracked')
endfunction "}}}

function! LightlineGitStaged() abort "{{{
  return LightlineGitStatus('staged')
endfunction "}}}

function! LightlineGitBihind() abort "{{{
  return LightlineGitStatus('behind')
endfunction "}}}

function! LightlineGitAhead() abort "{{{
  return LightlineGitStatus('ahead')
endfunction "}}}

let g:lightline = #{
      \   active: #{
      \     left: [
      \       ['mode', 'paste'],
      \       ['git-branch', 'git-untracked', 'git-unstaged', 'git-staged', 'git-behind', 'git-ahead', 'filename', 'readonly', 'modified'],
      \     ]
      \   },
      \   component_function: #{
      \     filename:      'LightlineFilename',
      \     git-branch:    'LightlineGitBranch',
      \     git-untracked: 'LightlineGitUntracked',
      \     git-unstaged:  'LightlineGitUnstaged',
      \     git-staged:    'LightlineGitStaged',
      \     git-behind:    'LightlineGitBihind',
      \     git-ahead:     'LightlineGitAhead'
      \   }
      \ }

call packman#config#github#new('itchyny/lightline.vim')

augroup LightLineForNetrw
  autocmd!
  autocmd FileType * if &filetype == 'netrw' | call lightline#update() | end
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
