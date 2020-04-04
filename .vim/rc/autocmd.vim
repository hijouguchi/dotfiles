let s:save_cpo = &cpo
set cpo&vim

augroup VimrcAutoCmd
  autocmd!

  " ファイルサイズが大きいときに、シンタックスの適応を一部に制限
  autocmd Syntax * if 5000 < line('$') | syntax sync minlines=100 | endif

  autocmd BufWritePost *
        \   if getline(1) =~ "^#!"
        \ |   silent! exe "silent! !chmod +x %"
        \ | endif

  " if the file doesn't have used Japanese, set fileencoding to utf-8
  " from kana's vimrc http://github.com/kana/config/
  autocmd BufReadPost *
        \   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
        \ |   setlocal fileencoding=
        \ | endif

  autocmd FileType *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif


  autocmd BufWinEnter,Filetype help wincmd K

  autocmd BufNewFile,BufRead *.[rR]                   setfiletype r
  autocmd BufNewFile,BufRead *.v[^./]\\\{0,1\}        setlocal filetype=systemverilog
  autocmd BufNewFile,BufRead *.sv[^./]\\\{0,1\}       setlocal filetype=systemverilog
  autocmd BufNewFile,BufRead todo.txt                 setlocal filetype=todo

  autocmd FileType crontab setlocal nobackup
  autocmd FileType make    setlocal noexpandtab
  autocmd FileType go      setlocal noexpandtab listchars=tab:\ \ ,trail:_,eol:.

  " enable QuickFix for grep
  " see also: http://qiita.com/items/0c1aff03949cb1b8fe6b
  autocmd QuickFixCmdPost *grep* cwindow

  " if already open file, read as readonly
  " see also: http://itchyny.hatenablog.com/entry/2014/12/25/090000
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END

let s:space_match_config = {
      \ 'SpaceEnd'     : '\s\+$',
      \ 'TabAndSpace'  : '\s*\(\t \| \t\)\s*',
      \ 'ZenkakuSpace' : '\s*　\s*',
      \ 'SpaceStart'   : '^\t\s*'
      \ }
      "\ 'SpaceStart'   : function('HighlightSpaceStart')


let s:space_no_highlight = ['help', 'diff', 'make', 'go']
function! s:HighlightTrailingSpacesEnable(...) abort "{{{

  " ハイライトさせたくないファイルタイプ
   if exists('b:current_syntax') &&
         \ index(s:space_no_highlight, b:current_syntax) != -1
    call <SID>HighlightTrailingSpacesDisanable()
    return
  endif

  let mlist = getmatches()

  if a:0 == 0
    let args = keys(s:space_match_config)
  else
    let args = a:000
  endif

  for li in args
    if !has_key(s:space_match_config, li)
      echoerr li 'does not found in s:space_match_config'
      continue
    endif

    let tp = type(s:space_match_config[li])
    if tp == v:t_string
      call matchadd(li, s:space_match_config[li])
    elseif tp == v:t_func
      call call(s:space_match_config[li], [li])
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

function! s:HighlightTralingSpaceStart() abort "{{{
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

  for k in keys(s:space_match_config)
    execute 'highlight default link '.k.' Error'
  endfor

  call <SID>HighlightTrailingSpacesEnable()
endfunction "}}}

function! s:HighlightTralingSpaceStop() abort "{{{
  call <SID>HighlightTrailingSpacesDisanable()

  augroup HighlightTrailingSpaces
    autocmd!
  augroup END
endfunction "}}}

command! HighlightTralingSpaceStart call <SID>HighlightTralingSpaceStart()
command! HighlightTralingSpaceStop  call <SID>HighlightTralingSpaceStop()

" call HighlightTralingSpaceStart
HighlightTralingSpaceStart


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
  augroup EventChecker
    autocmd!
  augroup END

  if !exists('g:event_list')
    let g:event_list = []

    "let val = <SID>get_autocmd_events()
    let val = [
          \ 'BufNewFile'       , 'BufReadPre'           , 'BufRead'          , 'BufReadPost'     , 'BufReadCmd'     ,
          \ 'FileReadPre'      , 'FileReadPost'         , 'FileReadCmd'      , 'FilterReadPre'   , 'FilterReadPost' ,
          \ 'StdinReadPre'     , 'StdinReadPost'        , 
          \ 'BufWrite'         , 'BufWritePre'          , 'BufWritePost'     , 'BufWriteCmd'     , 
          \ 'FileWritePre'     , 'FileWritePost'        , 'FileWriteCmd'     , 'FileAppendPre'   , 
          \ 'FileAppendPost'   , 'FileAppendCmd'        , 
          \ 'FilterWritePre'   , 'FilterWritePost'      , 
          \ 'BufAdd'           , 'BufCreate'            , 'BufDelete'        , 'BufWipeout'      , 'BufFilePre'     , 
          \ 'BufFilePost'      , 'BufEnter'             , 'BufLeave'         , 
          \ 'BufWinEnter'      , 'BufWinLeave'          , 
          \ 'BufUnload'        , 'BufHidden'            , 'BufNew'           , 
          \ 'SwapExists'       , 'FileType'             , 'Syntax'           , 'EncodingChanged' , 
          \ 'TermChanged'      , 'OptionSet'            , 'VimEnter'         , 'GUIEnter'        , 
          \ 'GUIFailed'        , 'TermResponse'         , 'QuitPre'          , 'ExitPre'         , 
          \ 'VimLeavePre'      , 'VimLeave'             , 
          \ 'TerminalOpen'     , 'TerminalWinOpen'      , 
          \ 'FileChangedShell' , 'FileChangedShellPost' , 'FileChangedRO'    , 
          \ 'DiffUpdated'      , 'DirChanged'           , 'ShellCmdPost'     , 'ShellFilterPost' , 
          \ 'CmdUndefined'     , 'FuncUndefined'        , 'SpellFileMissing' , 
          \ 'SourcePre'        , 'SourcePost'           , 'SourceCmd'        , 'VimResized'      , 
          \ 'FocusGained'      , 'FocusLost'            , 
          \ 'CursorHold'       , 'CursorHoldI'          , 'CursorMoved'      , 'CursorMovedI'    , 
          \ 'WinNew'           , 'TabNew'               , 'TabClosed'        , 
          \ 'WinEnter'         , 'WinLeave'             , 'TabEnter'         , 'TabLeave'        , 
          \ 'CmdwinEnter'      , 'CmdwinLeave'          , 'CmdlineChanged'   , 'CmdlineEnter'    , 'CmdlineLeave'   , 
          \ 'InsertEnter'      , 'InsertChange'         , 'InsertLeave'      , 'InsertCharPre'   , 
          \ 'TextChanged'      , 'TextChangedI'         , 'TextChangedP'     , 
          \ 'TextYankPost'     , 
          \ 'ColorSchemePre'   , 'ColorScheme'          , 'RemoteReply'      , 
          \ 'QuickFixCmdPre'   , 'QuickFixCmdPost'      , 
          \ 'SessionLoadPost'  , 'MenuPopup'            , 
          \ 'CompleteChanged'  , 'CompleteDone'         , 'User'
          \ ]
    for va in val
      silent execute 'autocmd EventChecker '.va. ' * call add(g:event_list, "'.va.'")'
    endfor
  else
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

  " MEMO: require vital.vim when using flatten()
  " return uniq(flatten(val))
  return uniq(sort(split(join(val, ' '), '\s\+')))
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker
