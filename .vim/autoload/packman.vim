let s:save_cpo = &cpo
set cpo&vim

if get(g:, 'packman_loaded', 0) == 1
  finish
endif
let g:packman_loaded = 1


if !has('g:packman_delay_load_time')
  let g:packman_delay_load_time = 10
endif


function! packman#begin(...) abort "{{{
  if a:0 > 0
    let s:packman_directory = a:1
  else
    let s:packman_directory = $HOME.'/.vim/pack/packman/opt'
  endif

  let s:packman_list = {}

  let s:packman_timer_lazy_list = []
  let s:packman_timer_idx       = 0
endfunction "}}}
function! packman#end() abort "{{{

  for elms in items(s:packman_list)
    let repo = elms[0]
    let elm  = elms[1]

    if get(elm, 'lazy', 0) == 0
      call s:try_load(repo)
      continue
    endif

    let hook = 0

    if has_key(elm, 'event')
      call s:hook_event(repo)
      let hook = 1
    endif

    if has_key(elm, 'keymaps')
      call s:hook_keymaps(repo)
      let hook = 1
    endif

    if has_key(elm, 'commands')
      call s:hook_commands(repo)
      let hook = 1
    endif

    if hook == 0
      call add(s:packman_timer_lazy_list, repo)
    endif
  endfor


  " set timer
  let len = len(s:packman_timer_lazy_list)
  if len > 0
    call timer_start(g:packman_delay_load_time,
          \ 'packman#hook_timer', {'repeat': len})
  endif

  return
endfunction "}}}
function! packman#add(repo, ...) abort "{{{

  if a:0 > 0
    let elm = a:1
  else
    let elm = {}
  endif

  let s:packman_list[a:repo] = elm
  return
endfunction " }}}
function! packman#add_lazy(repo, ...) abort "{{{

  if a:0 > 0
    let elm = a:1
  else
    let elm = {}
  endif

  let elm['lazy'] = 1

  let s:packman_list[a:repo] = elm
  return
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
function! packman#load_on_hook(repo, ...) abort "{{{
  call s:hook_clear(a:repo)
  call s:try_load(a:repo)
endfunction "}}}
function! packman#hook_keymap(repo, key) abort "{{{
  call packman#load_on_hook(a:repo)
  return feedkeys(a:key)
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

function! s:try_load(repo) abort "{{{
  let elm = s:packman_list[a:repo]

  " if already loaded, ignored
  if get(elm, 'loaded', 0) == 1
    return
  end
  let elm['loaded'] = 1

  if has_key(elm, 'pre_func')
    call elm.pre_func()
  endif

  call s:load_repo(a:repo)

  if has_key(elm, 'depends')
    for dep in elm['depends']
      call s:load_repo(dep)
    endfor
  end

  if has_key(elm, 'post_func')
    call elm.post_func()
  endif

  return
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
function! s:install_or_update(repo) abort "{{{
  echom '[packman] check' a:repo
  let url  = 'https://github.com/'.a:repo
  let targ = s:packman_directory . '/' . substitute(a:repo, '^.*\/', '', '')

  if isdirectory(targ)
    call system('cd '.targ.' && git pull')
  else
    call system('mkdir -p '.s:packman_directory.' && git clone --depth 1 --single-branch '.url.' '.targ)
  endif

  if isdirectory(targ.'/doc')
    exec 'helptags' targ.'/doc'
  endif

  " vimproc の場合はコンパイルもしておく
  if a:repo == 'vimproc.vim' && !has('win32') && !has('win32unix')
    call system('cd '.targ.' && make')
  endif
endfunction "}}}
function! s:hook_event(repo) abort "{{{
  let gname = substitute(a:repo, '^.*\/', 'packman-hook-', '')
  let elm   = s:packman_list[a:repo]

  execute 'augroup' gname
    autocmd!
    for eve in elm['event']
      execute 'autocmd' eve '* call packman#load_on_hook("'.a:repo.'")'
    endfor
  augroup END
endfunction "}}}
function! s:hook_keymaps(repo) abort "{{{
  let elm   = s:packman_list[a:repo]

  for key in elm['keymaps']
    execute 'map  <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
    execute 'map! <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
  endfor
endfunction "}}}
function! s:hook_commands(repo) abort "{{{
  let elm   = s:packman_list[a:repo]
  for cmd in elm['commands']
    execute 'silent! command -nargs=* -range -bang -bar' cmd
          \ 'call packman#hook_command("'.a:repo.'", "'.cmd.'", <q-bang>, <line1>, <line2>, <q-args>)'
  endfor
endfunction "}}}
function! s:hook_clear(repo) abort "{{{
  let elm = s:packman_list[a:repo]

  " remove insert hook
  if has_key(elm, 'insert') && elm['insert'] == 1
    let gname = substitute(a:repo, '^.*\/', 'packman-hook-', '')
    silent! execute 'silent! autocmd!' gname
  endif

  " remove keymap hook
  if has_key(elm, 'keymaps')
    for key in elm['keymaps']
      execute 'unmap'  key
      execute 'unmap!' key
    endfor
  endif

  " remove command hook
  if has_key(elm, 'commands')
    for cmd in elm['commands']
      execute 'silent command!' cmd
    endfor
  endif
endfunction "}}}


command! -nargs=+   PackManAdd     call packman#add(<args>)
command! -nargs=+   PackManAddLazy call packman#add_lazy(<args>)
command!            PackManCheck   call packman#check_update()
command!            PackManList    call packman#show_list()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
