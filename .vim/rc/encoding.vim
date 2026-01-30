" kaoriya 付属の fileencodings 設定がベース

set ambiwidth=double

" encoding settings
let s:lang      = expand($LANG)

if s:lang =~ 'UTF-8'
  set encoding=utf-8
elseif s:lang =~ 'eucJP'
  set encoding=euc-jp
elseif has('win32') || has('win32unix')
  set encoding=cp932
endif

unlet s:lang

" fileformats settings
if has('win32') || has('win32unix')
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif


" fileencodings settings
let s:enc_cp932 = 'cp932'
let s:enc_eucjp = 'euc-jp'
let s:enc_jisx  = 'iso-2022-jp'
let s:enc_utf8  = 'utf-8'

if has('iconv')
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  else
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
  endif

  let value = 'ucs-bom,ucs-2le,ucs-2'

  if &encoding ==? 'utf-8'
    let value = s:enc_jisx. ','.s:enc_cp932. ','.s:enc_eucjp. ',ucs-bom'
  elseif &encoding ==? 'cp932'
    let value = value. ','.s:enc_jisx. ','.s:enc_utf8. ','.s:enc_eucjp
  elseif &encoding ==? 'euc-jp' || &encoding ==? 'euc-jisx0213'
    let value = value. ','.s:enc_jisx. ','.s:enc_utf8. ','.s:enc_cp932
  endif

  let &fileencodings = value
endif

unlet s:enc_cp932
unlet s:enc_eucjp
unlet s:enc_jisx
unlet s:enc_utf8


" vim: ts=2 sw=2 sts=2 et fdm=marker
