" .vim/rc/autocmd.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-17

let s:save_cpo = &cpo
set cpo&vim

augroup VimrcAutoCmd
  autocmd!


  autocmd BufWritePost * if getline(1) =~ "^#!" |
        \ silent! exe "silent! !chmod +x %" | endif

  " if the file doesn't have used Japanese, set fileencoding to utf-8
  " from kana's vimrc http://github.com/kana/config/
  autocmd BufReadPost *
        \   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
        \ |   setlocal fileencoding=utf-8
        \ | endif

  "" if the file doesn't have used tab by space, set expandtab
  "autocmd BufReadPost *
  "      \   if search('^\t', 'cnw') == 0
  "      \ |   setlocal expandtab
  "      \ | endif

  "autocmd BufNewFile * setlocal expandtab
  autocmd BufNewFile *
        \   if &l:filetype !=? 'make'
        \ |   setlocal expandtab
        \ | endif

  autocmd FileType *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif

  " FIXME: cursor can't not use
  " autocmd BufWritePre * call <SID>UpdateLastChange()


  autocmd BufWinEnter,Filetype help wincmd K



  autocmd BufRead,BufNewFile *.r,*.R     set filetype=r
  autocmd BufRead,BufNewFile *.m,*.mat   set filetype=octave
  autocmd BufRead,BufNewFile *.mdl       set filetype=spice
  autocmd BufRead,BufNewFile *.gp        set filetype=gnuplot

  autocmd BufRead,BufNewFile *.v.erb     set filetype=eruby.verilog
  autocmd BufRead,BufNewFile *.sp.erb    set filetype=eruby.spice
  autocmd BufRead,BufNewFile *.gp.erb    set filetype=eruby.gnuplot
  autocmd BufRead,BufNewFile *.htm.erb   set filetype=eruby.html
  autocmd BufRead,BufNewFile *.html.erb  set filetype=eruby.html

  autocmd FileType crontab setlocal nobackup
  autocmd FileType make    setlocal noexpandtab

  " enable QuickFix for grep
  " see also: http://qiita.com/items/0c1aff03949cb1b8fe6b
  autocmd QuickFixCmdPost *grep* cwindow

  " if already open file, read as readonly
  " see also: http://itchyny.hatenablog.com/entry/2014/12/25/090000
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END


" augroup HighlightTrailingSpaces
"   autocmd!
"   autocmd BufRead,BufNewFile *
"         \   if &l:filetype == 'help'
"         \ |   match none
"         \ | else
"         \ |   match TrailingSpacess /\(\s*\( \t\|\t \)\s*\|\s\s*$\)/
"         \ | endif
" augroup END


augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin set binary

  autocmd BufReadPost  * if &l:binary
  autocmd BufReadPost  *   set ft=xxd
  autocmd BufReadPost  *   set readonly
  autocmd BufReadPost  *   silent %!xxd -g 1
  autocmd BufReadPost  * endif
augroup END

function! s:UpdateLastChange() "{{{
  let s:pos = getpos('.')

  call setpos('.', [0, 0, 0, 0])
  if search('Last\sChange')
    execute 'silent! s/Last\ Change:\zs.*$/ ' . strftime('%Y-%m-%d') . '/'
  endif

  call setpos('.', s:pos)
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
