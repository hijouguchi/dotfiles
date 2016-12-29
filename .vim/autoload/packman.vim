let s:save_cpo = &cpo
set cpo&vim


function! packman#initialize() "{{{
  if !has('g:packman_directory')
    let g:packman_directory = $HOME.'/.vim/pack'
  endif

  if !has('g:packman_list')
    let g:packman_list = {}
  endif
endfunction "}}}
function! packman#add(repo, ...) abort "{{{

  let elm = {}
  if a:0 > 0
    let elm = a:1
  endif

  let g:packman_list[a:repo] = elm
  return
endfunction " }}}
function! packman#add_lazy(repo, ...) abort "{{{

  let elm = {}
  if a:0 > 0
    let elm = a:1
  endif

  if !has_key(elm, 'lazy')
    let elm['lazy'] = 1
  endif

  let g:packman_list[a:repo] = elm
  return
endfunction " }}}
function! packman#check() abort "{{{

  for elms in items(g:packman_list)
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
function! packman#load() abort "{{{
  " 先に vimproc.vim があればロードしておく
  for repo in filter(keys(g:packman_list), 'v:val =~# "vimproc"')
    call s:execute(repo)
  endfor


  for elms in items(g:packman_list)
    let repo = elms[0]
    let elm  = elms[1]

    " 先にロードしたので無視
    if repo =~# 'vimproc'
      continue
    endif

    if !has_key(elm, 'lazy') || elm['lazy'] == 0
      call s:execute(repo)
    else
      if has_key(elm, 'insert') && elm['insert'] == 1
        call s:hook_insert(repo)
      endif
      if has_key(elm, 'keymaps')
        call s:hook_keymaps(repo)
      endif
      if has_key(elm, 'commands')
        call s:hook_commands(repo)
      endif
    endif
  endfor

  return
endfunction "}}}
function! packman#execute_on_hook(repo) abort "{{{
  call s:hook_clear(a:repo)
  call s:execute(a:repo)
endfunction "}}}
function! packman#hook_keymap(repo, key) abort "{{{
  call packman#execute_on_hook(a:repo)
  return feedkeys(a:key)
endfunction "}}}
function! packman#hook_command(repo, cmd, bang, line1, line2, args) abort "{{{
  call packman#execute_on_hook(a:repo)

  let range = (a:line1 == a:line2) ? '' : a:line1.','.a:line2
  execute range.a:cmd.a:bang a:args
endfunction "}}}

function! s:install_or_update(repo) abort "{{{
  echom '[packman] check' a:repo
  let dir  = g:packman_directory.'/github/opt'
  let url  = 'https://github.com/'.a:repo
  let targ = dir . '/' . substitute(a:repo, '^.*\/', '', '')

  " TODO: 今後 job とかを使って非同期にやっておきたい
  if isdirectory(targ)
    call system('cd '.targ.' && git pull')
  else
    call system('mkdir -p '.dir.' && git clone --depth 1 --single-branch '.url.' '.targ)
  endif

  if isdirectory(targ.'/doc')
    exec 'helptags' targ.'/doc'
  endif

  " vimproc の場合はコンパイルもしておく
  if a:repo == 'vimproc.vim' && !has('win32') && !has('win32unix')
    call system('cd '.targ.' && make')
  endif
endfunction "}}}
function! s:execute(repo) abort "{{{
  let elm = g:packman_list[a:repo]

  if has_key(elm, 'pre_func')
    call elm.pre_func()
  endif

  let name = substitute(a:repo, '^.*\/', '', '')
  exec 'packadd' name

  if has_key(elm, 'depends')
    for dep in elm['depends']
      let name = substitute(dep, '^.*\/', '', '')
    endfor
  end

  if has_key(elm, 'post_func')
    call elm.post_func()
  endif

  return
endfunction "}}}
function! s:hook_insert(repo) abort "{{{
  let elm   = g:packman_list[a:repo]
  let gname = substitute(a:repo, '^.*\/', 'packman-hook-', '')
  execute 'augroup' gname
    autocmd!
    execute 'autocmd InsertEnter * call packman#execute_on_hook("'.a:repo.'")'
  augroup END
endfunction "}}}
function! s:hook_keymaps(repo) abort "{{{
  let elm   = g:packman_list[a:repo]

  for key in elm['keymaps']
    execute 'map  <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
    execute 'map! <expr>' key 'packman#hook_keymap("'.a:repo.'", "\'.key.'")'
  endfor
endfunction "}}}
function! s:hook_commands(repo) abort "{{{
  let elm   = g:packman_list[a:repo]
  for cmd in elm['commands']
    execute 'silent! command -nargs=* -range -bang -bar' cmd
          \ 'call packman#hook_command("'.a:repo.'", "'.cmd.'", <q-bang>, <line1>, <line2>, <q-args>)'
  endfor
endfunction "}}}
function! s:hook_clear(repo) abort "{{{
  let elm = g:packman_list[a:repo]

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


command! -nargs=+ PackManAdd     call packman#add(<args>)
command! -nargs=+ PackManAddLazy call packman#add_lazy(<args>)
command!          PackManCheck   call packman#check()
command!          PackManLoad    call packman#load()

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
