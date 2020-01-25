let s:save_cpo = &cpo
set cpo&vim


" global functions for users to use
function! packman#initialize() abort "{{{
  if exists('s:packman_initialized')
    return
  endif
  let s:packman_initialized = 1

  if version < 800
    return s:initialize_for_nop()
  endif

  call s:initialize()
endfunction "}}}

function! packman#add(repo, ...) abort "{{{
  if a:0 > 0
    let elm = a:1
  else
    let elm = {}
  endif

  call s:add(a:repo, elm)
endfunction " }}}

function! packman#add_lazy(repo, ...) abort "{{{
  if a:0 > 0
    let elm = a:1
  else
    let elm = {}
  endif

  let elm['lazy'] = 1

  call s:add(a:repo, elm)
endfunction " }}}

function! packman#check_update() abort "{{{
  for elms in items(s:packman_list)
    let repo = elms[0]
    let elm  = elms[1]

    call s:install_or_update(repo)

    if has_key(elm, 'depends')
      for dep in elm['depends']
        call s:install_or_update(dep)
      endfor
    endif
  endfor

  call s:echo('[packman] check complete')
endfunction "}}}

function! packman#show_list() abort "{{{
  for elms in items(s:packman_list)
    let loaded = get(elms[1], 'loaded', 0) == 1 ? '*' : ' '
    echo ' ' loaded elms[0]

    if has_key(elms[1], 'depends')
      for name in elms[1]['depends']
        echo '      ->' name
      endfor
    endif
  endfor
endfunction "}}}

function! packman#repo_list(ArgLead, CmdLine, CursorPos) abort "{{{
  let unloaded_list = filter(copy(s:packman_list),
        \ {_,v -> get(v, 'loaded', 0) == 0})
  let repo_name = keys(unloaded_list)

  "echom a:ArgLead
  "echom a:CmdLine
  "echom a:CursorPos

  return repo_name
endfunction "}}}

function! packman#cleanup() abort "{{{
  let dir_list = map(
        \ split(glob(g:packman_default_directory.'/*'), "\<NL>"),
        \ {_, v -> expand(v)})

  let rep_list = map(
        \ values(s:packman_list),
        \ {_, v -> expand(v.dir)})

  for elm in dir_list
    " filter でうまくやりたいが。。。
    let found = 0
    for rep in rep_list
      if elm == rep
        let found = 1
        break
      endif
    endfor

    if !found
      echo '[packman] cleanup '.elm
      call delete(elm, 'rf')
    endif
  endfor

  echo '[packman] cleanup completed'
endfunction "}}}

function! packman#nop() "{{{
  " No Operation
endfunction "}}}

" global functions for internal to use
function! packman#load_on_hook(repo) abort "{{{
  call s:try_load(a:repo)
endfunction "}}}

function! packman#hook_keymap(repo, key) abort "{{{
  call packman#load_on_hook(a:repo)
  call feedkeys(a:key)
  return ''
endfunction "}}}

function! packman#hook_command(repo, cmd, bang, line1, line2, args) abort "{{{
  call packman#load_on_hook(a:repo)

  let range = (a:line1 == a:line2) ? '' : a:line1.','.a:line2
  execute range.a:cmd.a:bang a:args
endfunction "}}}

function! packman#hook_timer(...) abort "{{{
  let repo = s:packman_timer_lazy_list[s:packman_timer_idx]
  let s:packman_timer_idx += 1
  call s:try_load(repo)
endfunction "}}}

function! packman#register_hook_timer() abort "{{{
  " set timer
  let len = len(s:packman_timer_lazy_list)
  if len > 0
    call timer_start(g:packman_delay_load_time,
          \ 'packman#hook_timer', {'repeat': len})
  endif
endfunction "}}}

" default repository functions
function! packman#repository_github_load(repo) abort "{{{
  let name = substitute(a:repo, '^.*\/', '', '')
  let dir  = s:get_installed_directory(a:repo)

  if !isdirectory(dir)
    call s:echo('[packman]'.a:repo.'is not installed. try install...')
    call s:install_or_update(a:repo)
  endif

  exec 'packadd' name
endfunction "}}}

function! packman#repository_github_update(repo, dir) abort "{{{
    call system('cd '.a:dir.' && git pull')
endfunction "}}}

function! packman#repository_github_install(repo, dir) abort "{{{
    let url  = 'https://github.com/'.a:repo
    call system('mkdir -p '.g:packman_default_directory.' && git clone --depth 1 --single-branch '.url.' '.a:dir)
endfunction "}}}

function! packman#repository_runtine_load(repo) abort "{{{
  exec 'runtime' a:repo
endfunction "}}}



" internal functions
function! s:initialize_for_nop() abort "{{{
  " addcommands
  command! -nargs=*   PackManAdd     call packman#nop()
  command! -nargs=*   PackManAddLazy call packman#nop()
  command!            PackManCheck   call packman#nop()
  command!            PackManList    call packman#nop()
  command!            PackManCleanup call packman#nop()
  command! -nargs=*   PackManEnable  call packman#nop()

  augroup PackManEventGroup
    autocmd!
    autocmd VimEnter * echo "packman.vim requires Vim8.0 or lator..."
    autocmd VimEnter * autocmd! PackManEventGroup
  augroup END
endfunction "}}}

function! s:initialize() abort "{{{
  let s:packman_list            = {}
  let s:packman_timer_lazy_list = []
  let s:packman_timer_idx       = 0

  if !exists('g:packman_delay_load_time')
    let g:packman_delay_load_time = 10
  endif

  if !exists('g:packman_default_directory')
    let g:packman_default_directory = $HOME.'/.vim/pack/packman/opt'
  endif

  call s:initialize_load_and_install_function()

  " addcommands
  command! -nargs=+   PackManAdd     call packman#add(<args>)
  command! -nargs=+   PackManAddLazy call packman#add_lazy(<args>)
  command!            PackManCheck   call packman#check_update()
  command!            PackManList    call packman#show_list()
  command!            PackManCleanup call packman#cleanup()
  command! -nargs=1 -complete=customlist,packman#repo_list
        \             PackManEnable call packman#load_on_hook(<q-args>)

  " add timer event to VimEnter
  augroup PackManEventGroup
    autocmd!
    autocmd VimEnter * call packman#register_hook_timer()
    autocmd VimEnter * autocmd! PackManEventGroup
  augroup END
endfunction "}}}

function! s:initialize_load_and_install_function() abort "{{{
  if !exists('g:packman_load_and_install_config')
    let g:packman_load_and_install_config = {}
  endif

  if !has_key(g:packman_load_and_install_config, 'github')
    let g:packman_load_and_install_config.github = {
          \ 'load':    funcref('packman#repository_github_load'),
          \ 'update':  funcref('packman#repository_github_update'),
          \ 'install': funcref('packman#repository_github_install')
          \ }
  endif

  if !has_key(g:packman_load_and_install_config, 'runtime')
    let g:packman_load_and_install_config.runtime = {
          \ 'load':    funcref('packman#repository_runtine_load'),
          \ 'update':  funcref('packman#nop'),
          \ 'install': funcref('packman#nop')
          \ }
  endif

  if !has_key(g:packman_load_and_install_config, 'default')
    let g:packman_load_and_install_config.default =
          \ g:packman_load_and_install_config.github
  endif
endfunction "}}}

function! s:add(repo, elm) abort "{{{
  let a:elm.dir = s:get_installed_directory(a:repo)
  let s:packman_list[a:repo] = a:elm

  if get(a:elm, 'noload', 0) == 1
    return
  endif

  if get(a:elm, 'lazy', 0) == 0
    return s:try_load(a:repo)
  endif

  " register hook on each event
  let hook = 0
  let hook = s:add_hock_events  (a:repo) || hook
  let hook = s:add_hock_keymaps (a:repo) || hook
  let hook = s:add_hock_commands(a:repo) || hook

  " if hook does not exist (when lazy mode)
  " this repository load by timer mode
  if hook == 0
    call add(s:packman_timer_lazy_list, a:repo)
  endif
endfunction "}}}

function! s:has_element(repo, name) abort "{{{
  return has_key(s:packman_list, a:repo) &&
        \ has_key(s:packman_list[a:repo], a:name)
endfunction "}}}

function! s:add_hock_events(repo) abort "{{{
  if !s:has_element(a:repo, 'events')
    return 0
  endif

  execute 'augroup' s:get_event_name(a:repo)
    autocmd!
    for eve in s:packman_list[a:repo]['events']
      execute 'autocmd' eve '* call packman#load_on_hook("'.a:repo.'")'
    endfor
  augroup END

  return 1
endfunction "}}}

function! s:add_hock_keymaps(repo) abort "{{{
  if !s:has_element(a:repo, 'keymaps')
    return 0
  endif

  for key in s:packman_list[a:repo]['keymaps']
    execute 'map  <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
    execute 'map! <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
  endfor

  return 1
endfunction "}}}

function! s:add_hock_commands(repo) abort "{{{
  if !s:has_element(a:repo, 'commands')
    return 0
  endif

  for cmd in s:packman_list[a:repo]['commands']
    execute 'silent! command -nargs=* -range -bang -bar' cmd
          \ 'call packman#hook_command("'.a:repo.'", "'.cmd.'", <q-bang>, <line1>, <line2>, <q-args>)'
  endfor

  return 1
endfunction "}}}

function! s:try_load(repo) abort "{{{
  " if already loaded, ignored
  if s:has_element(a:repo, 'loaded')
    return
  end
  let s:packman_list[a:repo]['loaded'] = 1

  call s:remove_all_hook(a:repo)

  call s:try_call_function(a:repo, 'pre_load')
  call s:load_repo(a:repo)
  call s:try_load_depends(a:repo)
  call s:try_call_function(a:repo, 'post_load')
endfunction "}}}

function! s:load_repo(repo) abort "{{{
  " default is github
  if s:has_element(a:repo, 'type')
    let repo_type = s:packman_list[a:repo]['type']
  else
    let repo_type = 'default'
  endif

  let Func_ref = g:packman_load_and_install_config[repo_type]['load']
  call Func_ref(a:repo)
endfunction "}}}

function! s:try_call_function(repo, func_name) abort "{{{
  if !s:has_element(a:repo, a:func_name)
    return
  end

  let Fn = s:packman_list[a:repo][a:func_name]
  call Fn()
endfunction "}}}

function! s:try_load_depends(repo) abort "{{{
  if !s:has_element(a:repo, 'depends')
    return
  endif

  for dep in s:packman_list[a:repo]['depends']
    call s:load_repo(dep)
  endfor
endfunction "}}}

function! s:install_or_update(repo) abort "{{{
  call s:echo('[packman] check'.a:repo)
  let dir = s:get_installed_directory(a:repo)

  if s:has_element(a:repo, 'type')
    let repo_type = s:packman_list[a:repo]['type']
  else
    let repo_type = 'default'
  endif

  if isdirectory(dir)
    let Func_ref = g:packman_load_and_install_config[repo_type]['update']
  else
    let Func_ref = g:packman_load_and_install_config[repo_type]['install']
  endif
  call Func_ref(a:repo, dir)

  call s:append_helptags(dir)
  call s:try_call_function(a:repo, 'post_install_func')
endfunction "}}}

function! s:append_helptags(targ) abort "{{{
  if isdirectory(a:targ.'/doc')
    exec 'helptags' a:targ.'/doc'
  endif
endfunction "}}}

function! s:remove_all_hook(repo) abort "{{{
  call s:remove_events_hook  (a:repo)
  call s:remove_keymaps_hook(a:repo)
  call s:remove_command_hook(a:repo)
endfunction "}}}

function! s:get_event_name(repo) "{{{
  return substitute(a:repo, '^.*\/', 'packman-hook-', '')
endfunction "}}}

function! s:get_installed_directory(repo) abort "{{{
  return g:packman_default_directory . '/' . substitute(a:repo, '^.*\/', '', '')
endfunction "}}}

function! s:remove_events_hook(repo) abort "{{{
  if s:has_element(a:repo, 'events')
    silent! execute 'silent! autocmd!' s:get_event_name(a:repo)
  endif
endfunction "}}}

function! s:remove_keymaps_hook(repo) abort "{{{
  if !s:has_element(a:repo, 'keymaps')
    return
  endif

  for key in s:packman_list[a:repo]['keymaps']
    execute 'unmap'  key
    execute 'unmap!' key
  endfor
endfunction "}}}

function! s:remove_command_hook(repo) abort "{{{
  if !s:has_element(a:repo, 'commands')
    return
  endif

  for cmd in s:packman_list[a:repo]['commands']
    execute 'silent command!' cmd
  endfor
endfunction "}}}

function! s:echo(msg) abort "{{{
  redraw
  echom a:msg
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
