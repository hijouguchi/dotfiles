let s:save_cpo = &cpo
set cpo&vim

" TODO:
"   1. outputter に nonu と nolist を追加したい

let e = packman#config#github#new('thinca/vim-quickrun.git')
call e.add_depends(
      \ packman#config#github#new('osyo-manga/quickrun-outputter-replace_region.git')
      \ )
call e.add_hook_commands('QuickRun', 'ReplaceRegion')

function! e.pre_load()
  if !exists('g:quickrun_config')
    let g:quickrun_config = {}
  endif

  let g:quickrun_config['_'] = {
        \   'runner'                          : 'job',
        \   'outputter/buffer/split'          : ':topleft 10',
        \   'outputter/buffer/close_on_empty' : 1
        \ }
  let g:quickrun_config['verilog'] = {
        \   'command'                   : 'verilator',
        \   'cmdopt'                    : '--lint-only',
        \   'outputter/error/success'   : 'quickfix'
        \ }
  let g:quickrun_config['systemverilog'] = {
        \   'command'                   : 'verilator',
        \   'cmdopt'                    : '--lint-only --sv',
        \   'outputter/error/success'   : 'quickfix'
        \ }
  let g:quickrun_config.tcl = {'command' : 'tclsh'}
endfunction


command! -nargs=* -range=0 -complete=customlist,quickrun#complete
      \ ReplaceRegion QuickRun -mode v
      \   -outputter replace_region
      \   -outputter/error quickfix
      \   <args>

vnoremap <Space>rp :ReplaceRegion ruby<CR>
nnoremap <Space>e  :QuickRun<CR>


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

