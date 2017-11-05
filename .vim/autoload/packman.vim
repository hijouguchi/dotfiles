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

  call s:add(a:repo, 0, elm)
endfunction " }}}
function! packman#add_lazy(repo, ...) abort "{{{
  if a:0 > 0
    let elm = a:1
  else
    let elm = {}
  endif

  call s:add(a:repo, 1, elm)
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

  echom '[packman] check complete'
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
function! packman#nop() "{{{
  " No Operation
endfunction "}}}

" global functions for internal to use
function! packman#load_on_hook(repo) abort "{{{
  call s:remove_all_hook(a:repo)
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

function! s:initialize_for_nop() abort "{{{
  " addcommands
  command! -nargs=+   PackManAdd     call packman#nop()
  command! -nargs=+   PackManAddLazy call packman#nop()
  command!            PackManCheck   call packman#nop()
  command!            PackManList    call packman#nop()

  augroup PackManEventGroup
    autocmd!
    autocmd VimEnter * echo "packman.vim requires Vim8.0 or lator..."
    autocmd VimEnter * autocmd! PackManEventGroup
  augroup END
endfunction "}}}
function! s:initialize() abort "{{{
  let s:packman_list = {}
  let s:packman_timer_lazy_list = []
  let s:packman_timer_idx       = 0

  if !exists('g:packman_delay_load_time')
    let g:packman_delay_load_time = 10
  endif

  if !exists('g:packman_default_directory')
    let g:packman_default_directory = $HOME.'/.vim/pack/packman/opt'
  endif

  " addcommands
  command! -nargs=+   PackManAdd     call packman#add(<args>)
  command! -nargs=+   PackManAddLazy call packman#add_lazy(<args>)
  command!            PackManCheck   call packman#check_update()
  command!            PackManList    call packman#show_list()

  " add timer event to VimEnter
  augroup PackManEventGroup
    autocmd!
    autocmd VimEnter * call packman#register_hook_timer()
    autocmd VimEnter * autocmd! PackManEventGroup
  augroup END
endfunction "}}}
function! s:add(repo, is_lazy, elm) abort "{{{
  let a:elm.dir = s:get_installed_directory(a:repo)
  let s:packman_list[a:repo] = a:elm

  if !a:is_lazy
    return s:try_load(a:repo)
  endif

  let hook = 0
  " register hook on each event
  let hook = s:add_hock_event   (a:repo, a:elm) || hook
  let hook = s:add_hock_keymap  (a:repo, a:elm) || hook
  let hook = s:add_hock_commands(a:repo, a:elm) || hook

  " if hook does not exist (when lazy mode)
  " this repository load by timer mode
  if hook == 0
    call add(s:packman_timer_lazy_list, a:repo)
  endif
endfunction "}}}
function! s:add_hock_event(repo, elm) abort "{{{
  if !has_key(a:elm, 'event')
    return 0
  endif

  execute 'augroup' s:get_event_name(a:repo)
    autocmd!
    for eve in a:elm['event']
      execute 'autocmd' eve '* call packman#load_on_hook("'.a:repo.'")'
    endfor
  augroup END

  return 1
endfunction "}}}
function! s:add_hock_keymap(repo, elm) abort "{{{
  if !has_key(a:elm, 'keymaps')
    return 0
  endif

  for key in a:elm['keymaps']
    execute 'map  <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
    execute 'map! <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
  endfor

  return 1
endfunction "}}}
function! s:add_hock_commands(repo, elm) abort "{{{
  if !has_key(a:elm, 'commands')
    return 0
  endif

  for cmd in a:elm['commands']
    execute 'silent! command -nargs=* -range -bang -bar' cmd
          \ 'call packman#hook_command("'.a:repo.'", "'.cmd.'", <q-bang>, <line1>, <line2>, <q-args>)'
  endfor

  return 1
endfunction "}}}
function! s:try_load(repo) abort "{{{
  let elm = s:packman_list[a:repo]

  " if already loaded, ignored
  if get(elm, 'loaded', 0) == 1
    return
  end
  let elm['loaded'] = 1

  call s:try_call_function(elm, 'pre_load')
  call s:load_repo(a:repo)
  call s:try_load_depends(elm)
  call s:try_call_function(elm, 'post_load')
endfunction "}}}
function! s:load_repo(repo) abort "{{{
  let name = substitute(a:repo, '^.*\/', '', '')
  try
    exec 'packadd' name
  catch
    echom '[packman]' a:repo 'is not installed. try install...'
    call s:install_or_update(a:repo)
    exec 'packadd' name
  endtry
endfunction "}}}
function! s:try_call_function(elm, func_name) abort "{{{
  try
    call Func(a:elm[a:func_name])
  catch
    "nop
  endtry
endfunction "}}}
function! s:try_load_depends(elm) abort "{{{
  if !has_key(a:elm, 'depends')
    return
  endif

  for dep in a:elm['depends']
    call s:load_repo(dep)
  endfor
endfunction "}}}
function! s:install_or_update(repo) abort "{{{
  echom '[packman] check' a:repo
  let url  = 'https://github.com/'.a:repo
  let targ = s:get_installed_directory(a:repo)

  if isdirectory(targ)
    call system('cd '.targ.' && git pull')
  else
    call system('mkdir -p '.g:packman_default_directory.' && git clone --depth 1 --single-branch '.url.' '.targ)
  endif

  call s:append_helptags(targ)

  let elm = s:packman_list[a:repo]
  call s:try_call_function(elm, 'post_install_func')
endfunction "}}}
function! s:append_helptags(targ) abort "{{{
  if isdirectory(a:targ.'/doc')
    exec 'helptags' a:targ.'/doc'
  endif
endfunction "}}}
function! s:remove_all_hook(repo) abort "{{{
  let elm = s:packman_list[a:repo]

  call s:remove_event_hook  (a:repo, elm)
  call s:remove_keymap_hook (elm)
  call s:remove_command_hook(elm)
endfunction "}}}
function! s:get_event_name(repo) "{{{
  return substitute(a:repo, '^.*\/', 'packman-hook-', '')
endfunction "}}}
function! s:get_installed_directory(repo) abort "{{{
  return g:packman_default_directory . '/' . substitute(a:repo, '^.*\/', '', '')
endfunction "}}}
function! s:remove_event_hook(repo, elm) abort "{{{
  if has_key(a:elm, 'event')
    silent! execute 'silent! autocmd!' s:get_event_name(a:repo)
  endif
endfunction "}}}
function! s:remove_keymap_hook(elm) abort "{{{
  if !has_key(a:elm, 'keymaps')
    return
  endif

  for key in a:elm['keymaps']
    execute 'unmap'  key
    execute 'unmap!' key
  endfor
endfunction "}}}
function! s:remove_command_hook(elm) abort "{{{
  if !has_key(a:elm, 'commands')
    return
  endif

  for cmd in a:elm['commands']
    execute 'silent command!' cmd
  endfor
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
