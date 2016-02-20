" .vim/rc/autocmd.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-17

let s:save_cpo = &cpo
set cpo&vim

augroup VimrcAutoCmd
  autocmd!


  autocmd BufWritePost *
        \   if getline(1) =~ "^#!"
        \ |   silent! exe "silent! !chmod +x %"
        \ | endif

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

  autocmd FileType *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif

  " FIXME: cursor can't not use
  " autocmd BufWritePre * call <SID>UpdateLastChange()


  autocmd BufWinEnter,Filetype help wincmd K

  autocmd BufNewFile,BufRead *.r,*.R     setfiletype r
  autocmd BufNewFile,BufRead *.m,*.mat   setfiletype octave
  autocmd BufNewFile,BufRead *.mdl       setfiletype spice
  autocmd BufNewFile,BufRead *.gp        setfiletype gnuplot
  autocmd BufNewFile,BufRead *.sv        setfiletype verilog
  autocmd BufNewFile,BufRead *.svi       setfiletype verilog

  autocmd BufNewFile,BufRead *.v.erb     setfiletype eruby.verilog
  autocmd BufNewFile,BufRead *.sp.erb    setfiletype eruby.spice
  autocmd BufNewFile,BufRead *.gp.erb    setfiletype eruby.gnuplot
  autocmd BufNewFile,BufRead *.htm.erb   setfiletype eruby.html
  autocmd BufNewFile,BufRead *.html.erb  setfiletype eruby.html

  autocmd FileType crontab setlocal nobackup
  autocmd FileType make    setlocal noexpandtab

  " enable QuickFix for grep
  " see also: http://qiita.com/items/0c1aff03949cb1b8fe6b
  autocmd QuickFixCmdPost *grep* cwindow

  " if already open file, read as readonly
  " see also: http://itchyny.hatenablog.com/entry/2014/12/25/090000
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END

" MEMO: VimEnter 時には expandtab が反映されていないっぽい
function! HighlightSpaceStart(name) abort "{{{
  if &l:expandtab
    call matchadd(a:name, '^\s*\t\s*')
  else
    call matchadd(a:name, '^\s* \s*')
  endif
endfunction "}}}

let s:space_match_config = {
      \ 'SpaceEnd'     : '\s\+$',
      \ 'TabAndSpace'  : '\s*\(\t \| \t\)\s*',
      \ 'ZenkakuSpace' : '\s*　\s*'
      \ }
      "\ 'SpaceStart'   : function('HighlightSpaceStart')

augroup HighlightTrailingSpaces
  autocmd!
  for k in keys(s:space_match_config)
    execute 'autocmd ColorScheme     * highlight default link '.k.' Error'
  endfor

  autocmd BufWinEnter,Syntax * call <SID>HighlightTrailingSpacesEnable()
  autocmd WinEnter           * call <SID>HighlightTrailingSpacesEnable() " 既に開いているファイルを :sp したとき
  autocmd InsertLeave        * call <SID>HighlightTrailingSpacesEnable('SpaceEnd')
  autocmd InsertEnter        * call <SID>HighlightTrailingSpacesDisanable('SpaceEnd')
augroup END

let s:space_no_highlight = ['help', 'diff']
function! s:HighlightTrailingSpacesEnable(...) abort "{{{

  " ハイライトさせたくないファイルタイプ
   if exists('b:current_syntax') &&
         \ index(s:space_no_highlight, b:current_syntax) != -1
    call s:HighlightTrailingSpacesDisanable()
    return
  endif

  let mlist = getmatches()
  let args = (a:0 == 0) ? keys(s:space_match_config) : a:000
  for li in args
    if has_key(s:space_match_config, li) &&
          \ empty(filter(copy(mlist), 'v:val["group"] == li'))
      if type(s:space_match_config[li]) == 1
        call matchadd(li, s:space_match_config[li])
      else
        call call(s:space_match_config[li], [li])
      endif
    endif
  endfor
endfunction "}}}

function! s:HighlightTrailingSpacesDisanable(...) abort "{{{
  let mlist = getmatches()
  let args = (a:0 == 0) ? keys(s:space_match_config) : a:000
  for li in args
    for mg in filter(copy(mlist), 'v:val["group"] == li')
      call matchdelete(mg['id'])
    endfor
  endfor
endfunction "}}}


augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin set binary
  autocmd BufReadPost  * call <SID>binary_write()
augroup END

function! s:binary_write() "{{{
  if &l:binary
    set ft=xxd
    set readonly
    silent %!xxd -g 1
  endif
endfunction "}}}

augroup MyColor
  autocmd!
  autocmd ColorScheme *
        \   if g:colors_name == 'landscape'
        \ |   highlight! default link NonText Comment
        \ | endif
augroup END

" イベントチェック用
command! EventChecker call <SID>EventChecker()

function! s:EventChecker() abort "{{{
  if !exists('g:event_list')
    let g:event_list = []

    let val = <SID>get_autocmd_events()
    augroup EventChecker "{{{
      autocmd!
      for va in val
        execute 'autocmd '.va. ' * call add(g:event_list, "'.va.'")'
      endfor
    augroup END "}}}
  else
    " delete augroup
    augroup EventChecker "{{{
      autocmd!
    augroup END "}}}

    " create new buffer and paste result
    topleft new
    call append(0, g:event_list)
    setlocal buftype=nofile

    " remove global valiable
    unlet g:event_list
  endif
endfunction "}}}

function! s:get_autocmd_events() abort "{{{
  " backup register
  let tmp = @a

  " get autocmd list
  redir @a
  silent autocmd
  redir END
  let val = split(@a, '[\r\n]\+')

  " restore register
  let @a = tmp

  call filter(val, 'v:val !~ "^\\(\\s\\|---\\)"')
  return uniq(split(join(val, ' '), '\s\+'))
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
