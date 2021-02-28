let s:save_cpo = &cpo
set cpo&vim

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

function! s:create_lightline_git_status() abort "{{{
  let b:lightline_git_status = #{
        \   branch:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      'branch',
        \     callback:     'LightlineGitBranchCallback',
        \     job:          v:false
        \   },
        \   unstaged:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      'status',
        \     callback:     'LightlineGitUnstageCallback',
        \     job:          v:false
        \   },
        \   staged:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      'status',
        \     callback:     'LightlineGitStageCallback',
        \     job:          v:false
        \   },
        \   behind:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      'status',
        \     callback:     'LightlineGitBehindCallback',
        \     job:          v:false
        \   },
        \   ahead:   #{
        \     result:       '',
        \     last_changed: 0,
        \     command:      'status',
        \     callback:     'LightlineGitAheadCallback',
        \     job:          v:false
        \   }
        \ }
endfunction "}}}

function! LightlineGitStatus(arg) abort "{{{
  if !exists('b:lightline_git_status')
    call s:create_lightline_git_status()
  endif


  let ltime = localtime()
  let job   = b:lightline_git_status[a:arg]

  if (ltime - job.last_changed >= 60) && (job.job == v:false)
    let job.job = job_start(
          \ ['git', '-C', s:dir(), job.command],
          \ {'callback': job.callback})
  endif

  return job.result
endfunction "}}}

function! s:GitBranchCallbackJob(target) abort "{{{
    let job = b:lightline_git_status[a:target]
    let job.last_changed = localtime()
    let job.job          = v:false

    return job
endfunction "}}}

function! s:GitBranchCallbackResult(target, text) abort "{{{
    let job = b:lightline_git_status[a:target]

    if job.result != a:text
      let job.result = a:text
      call lightline#update()
    else
      let job.result = a:text
    endif
endfunction "}}}

function! LightlineGitBranchCallback(ch, msg) abort "{{{
    let target = 'branch'
    let job = s:GitBranchCallbackJob(target)

    for elm in a:msg->split('\n', 1)
      if elm[0:1] == '* '
        call s:GitBranchCallbackResult(target, elm[2:-1])
        return
      endif
    endfor
endfunction "}}}

function! LightlineGitUnstageCallback(ch, msg) abort "{{{
    let job = b:lightline_git_status.unstaged
    let job.last_changed = localtime()
    let job.job          = v:false

    for elm in a:msg->split('\n', 1)
      if elm =~ 'Changes not staged for commit'
        let job.result = 'work'
        return
      endif
    endfor
endfunction "}}}

function! LightlineGitStageCallback(ch, msg) abort "{{{
    let job = b:lightline_git_status.staged
    let job.last_changed = localtime()
    let job.job          = v:false

    for elm in a:msg->split('\n', 1)
      if elm =~ 'Changes to be committed'
        let job.result = 'index'
        return
      endif
    endfor
endfunction "}}}

function! LightlineGitBehindCallback(ch, msg) abort "{{{
    let job = b:lightline_git_status.behind
    let job.last_changed = localtime()
    let job.job          = v:false

    for elm in a:msg->split('\n', 1)
      if elm =~ 'use "git pull" to merge' || elm =~ 'use "git pull" to update'
        let job.result = 'behind'
        return
      endif
    endfor
endfunction "}}}

function! LightlineGitAheadCallback(ch, msg) abort "{{{
    let job = b:lightline_git_status.ahead
    let job.last_changed = localtime()
    let job.job          = v:false

    for elm in a:msg->split('\n', 1)
      if elm =~ 'use "git pull" to merge' || elm =~ 'use "git push" to publish'
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
      \       ['git-branch', 'git-unstaged', 'git-staged', 'git-behind', 'git-ahead', 'filename', 'readonly', 'modified'],
      \     ]
      \   },
      \   component_function: #{
      \     filename:      'LightlineFilename',
      \     git-branch:    'LightlineGitBranch',
      \     git-unstaged:  'LightlineGitUnstaged',
      \     git-staged:    'LightlineGitStaged',
      \     git-behind:    'LightlineGitBihind',
      \     git-ahead:     'LightlineGitAhead'
      \   }
      \ }

call packman#config#github#new('itchyny/lightline.vim')

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

