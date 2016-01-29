" .vim/rc/bundle/vim-quickrun.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

let s:save_cpo = &cpo
set cpo&vim

NeoBundleLazy 'thinca/vim-quickrun.git', {
      \   'depends'  : 'osyo-manga/quickrun-outputter-replace_region.git',
      \   'commands' : ['QuickRun', 'ReplaceRegion']
      \ }

let s:bundle = neobundle#get('vim-quickrun')
function! s:bundle.hooks.on_source(bundle)
  if !exists('g:quickrun_config')
    let g:quickrun_config = {}
  endif

  let g:quickrun_config['_'] = {
        \   'runner'                          : 'vimproc',
        \   'runner/vimproc/updatetime'       : 10,
        \   'outputter/buffer/split'          : ':topleft 10',
        \   'outputter/buffer/close_on_empty' : 1
        \ }
  let g:quickrun_config['verilog'] = {
        \   'command'                   : 'verilator',
        \   'cmdopt'                    : '--lint-only',
        \   'outputter/error/success'   : 'quickfix'
        \ }
  let g:quickrun_config.tcl = {'command' : 'tclsh'}

  command! -nargs=* -range=0 -complete=customlist,quickrun#complete
        \ ReplaceRegion QuickRun -mode v
        \   -outputter/error/success replace_region
        \   -outputter/error/error   quickfix
        \   <args>


endfunction
unlet s:bundle


vnoremap <Space>rp :ReplaceRegion ruby<CR>
nnoremap <Space>e  :QuickRun<CR>


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

