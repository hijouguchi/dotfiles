function! keymap#enabled() abort
  return !get(g:, 'vim_keymap_disable', 0)
endfunction

function! keymap#exec(cmd, args) abort
  if !keymap#enabled()
    return
  endif
  execute a:cmd . ' ' . a:args
endfunction

function! keymap#command_setup() abort
  if exists('g:loaded_keymap_commands')
    return
  endif
  let g:loaded_keymap_commands = 1

  command! -nargs=+ -bang KMap call keymap#exec(<bang>0 ? 'map!' : 'map', <q-args>)
  command! -nargs=+ -bang KMapNoremap call keymap#exec(<bang>0 ? 'noremap!' : 'noremap', <q-args>)

  command! -nargs=+ KMapNMap call keymap#exec('nmap', <q-args>)
  command! -nargs=+ KMapVMap call keymap#exec('vmap', <q-args>)
  command! -nargs=+ KMapXMap call keymap#exec('xmap', <q-args>)
  command! -nargs=+ KMapIMap call keymap#exec('imap', <q-args>)
  command! -nargs=+ KMapCMap call keymap#exec('cmap', <q-args>)
  command! -nargs=+ KMapTMap call keymap#exec('tmap', <q-args>)

  command! -nargs=+ KMapNNoremap call keymap#exec('nnoremap', <q-args>)
  command! -nargs=+ KMapINoremap call keymap#exec('inoremap', <q-args>)
  command! -nargs=+ KMapVNoremap call keymap#exec('vnoremap', <q-args>)
  command! -nargs=+ KMapXNoremap call keymap#exec('xnoremap', <q-args>)
  command! -nargs=+ KMapCNoremap call keymap#exec('cnoremap', <q-args>)
  command! -nargs=+ KMapTNoremap call keymap#exec('tnoremap', <q-args>)
endfunction

" vim: ts=2 sw=2 sts=2 et fdm=marker
