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

  autocmd BufReadPost  *
        \   if &l:binary
        \ |   set ft=xxd
        \ |   set readonly
        \ |   silent %!xxd -g 1
  autocmd BufReadPost  *
        \ | endif
augroup END

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
    augroup EventChecker "{{{
      autocmd!
      autocmd BufNewFile           * call add(g:event_list, 'BufNewFile')
      autocmd BufReadPre           * call add(g:event_list, 'BufReadPre')
      autocmd BufRead              * call add(g:event_list, 'BufRead')
      autocmd BufReadPost          * call add(g:event_list, 'BufReadPost')
      autocmd FileReadPre          * call add(g:event_list, 'FileReadPre')
      autocmd FileReadPost         * call add(g:event_list, 'FileReadPost')
      autocmd FilterReadPre        * call add(g:event_list, 'FilterReadPre')
      autocmd FilterReadPost       * call add(g:event_list, 'FilterReadPost')
      autocmd StdinReadPre         * call add(g:event_list, 'StdinReadPre')
      autocmd StdinReadPost        * call add(g:event_list, 'StdinReadPost')
      autocmd BufWrite             * call add(g:event_list, 'BufWrite')
      autocmd BufWritePre          * call add(g:event_list, 'BufWritePre')
      autocmd BufWritePost         * call add(g:event_list, 'BufWritePost')
      autocmd FileWritePre         * call add(g:event_list, 'FileWritePre')
      autocmd FileWritePost        * call add(g:event_list, 'FileWritePost')
      autocmd FileAppendPre        * call add(g:event_list, 'FileAppendPre')
      autocmd FileAppendPost       * call add(g:event_list, 'FileAppendPost')
      autocmd FilterWritePre       * call add(g:event_list, 'FilterWritePre')
      autocmd FilterWritePost      * call add(g:event_list, 'FilterWritePost')
      autocmd BufAdd               * call add(g:event_list, 'BufAdd')
      autocmd BufCreate            * call add(g:event_list, 'BufCreate')
      autocmd BufDelete            * call add(g:event_list, 'BufDelete')
      autocmd BufWipeout           * call add(g:event_list, 'BufWipeout')
      autocmd BufFilePre           * call add(g:event_list, 'BufFilePre')
      autocmd BufFilePost          * call add(g:event_list, 'BufFilePost')
      autocmd BufEnter             * call add(g:event_list, 'BufEnter')
      autocmd BufLeave             * call add(g:event_list, 'BufLeave')
      autocmd BufWinEnter          * call add(g:event_list, 'BufWinEnter')
      autocmd BufWinLeave          * call add(g:event_list, 'BufWinLeave')
      autocmd BufUnload            * call add(g:event_list, 'BufUnload')
      autocmd BufHidden            * call add(g:event_list, 'BufHidden')
      autocmd BufNew               * call add(g:event_list, 'BufNew')
      autocmd SwapExists           * call add(g:event_list, 'SwapExists')
      autocmd FileType             * call add(g:event_list, 'FileType')
      autocmd Syntax               * call add(g:event_list, 'Syntax')
      autocmd EncodingChanged      * call add(g:event_list, 'EncodingChanged')
      autocmd TermChanged          * call add(g:event_list, 'TermChanged')
      autocmd VimEnter             * call add(g:event_list, 'VimEnter')
      autocmd GUIEnter             * call add(g:event_list, 'GUIEnter')
      autocmd GUIFailed            * call add(g:event_list, 'GUIFailed')
      autocmd TermResponse         * call add(g:event_list, 'TermResponse')
      autocmd QuitPre              * call add(g:event_list, 'QuitPre')
      autocmd VimLeavePre          * call add(g:event_list, 'VimLeavePre')
      autocmd VimLeave             * call add(g:event_list, 'VimLeave')
      autocmd FileChangedShell     * call add(g:event_list, 'FileChangedShell')
      autocmd FileChangedShellPost * call add(g:event_list, 'FileChangedShellPost')
      autocmd FileChangedRO        * call add(g:event_list, 'FileChangedRO')
      autocmd ShellCmdPost         * call add(g:event_list, 'ShellCmdPost')
      autocmd ShellFilterPost      * call add(g:event_list, 'ShellFilterPost')
      autocmd CmdUndefined         * call add(g:event_list, 'CmdUndefined')
      autocmd FuncUndefined        * call add(g:event_list, 'FuncUndefined')
      autocmd SpellFileMissing     * call add(g:event_list, 'SpellFileMissing')
      autocmd SourcePre            * call add(g:event_list, 'SourcePre')
      autocmd VimResized           * call add(g:event_list, 'VimResized')
      autocmd FocusGained          * call add(g:event_list, 'FocusGained')
      autocmd FocusLost            * call add(g:event_list, 'FocusLost')
      autocmd CursorHold           * call add(g:event_list, 'CursorHold')
      autocmd CursorHoldI          * call add(g:event_list, 'CursorHoldI')
      autocmd CursorMoved          * call add(g:event_list, 'CursorMoved')
      autocmd CursorMovedI         * call add(g:event_list, 'CursorMovedI')
      autocmd WinEnter             * call add(g:event_list, 'WinEnter')
      autocmd WinLeave             * call add(g:event_list, 'WinLeave')
      autocmd TabEnter             * call add(g:event_list, 'TabEnter')
      autocmd TabLeave             * call add(g:event_list, 'TabLeave')
      autocmd CmdwinEnter          * call add(g:event_list, 'CmdwinEnter')
      autocmd CmdwinLeave          * call add(g:event_list, 'CmdwinLeave')
      autocmd InsertEnter          * call add(g:event_list, 'InsertEnter')
      autocmd InsertChange         * call add(g:event_list, 'InsertChange')
      autocmd InsertLeave          * call add(g:event_list, 'InsertLeave')
      autocmd InsertCharPre        * call add(g:event_list, 'InsertCharPre')
      autocmd TextChanged          * call add(g:event_list, 'TextChanged')
      autocmd TextChangedI         * call add(g:event_list, 'TextChangedI')
      autocmd ColorScheme          * call add(g:event_list, 'ColorScheme')
      autocmd RemoteReply          * call add(g:event_list, 'RemoteReply')
      autocmd QuickFixCmdPre       * call add(g:event_list, 'QuickFixCmdPre')
      autocmd QuickFixCmdPost      * call add(g:event_list, 'QuickFixCmdPost')
      autocmd SessionLoadPost      * call add(g:event_list, 'SessionLoadPost')
      autocmd MenuPopup            * call add(g:event_list, 'MenuPopup')
      autocmd CompleteDone         * call add(g:event_list, 'CompleteDone')
      autocmd User                 * call add(g:event_list, 'User')
    augroup END "}}}
  else
    augroup EventChecker
      autocmd!
    augroup END
    topleft new
    call append(0, g:event_list)
    setlocal buftype=nofile
    unlet g:event_list
  endif
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
