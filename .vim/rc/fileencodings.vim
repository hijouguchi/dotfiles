
if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
  let s:enc_euc = 'euc-jisx0213,euc-jp'
  let s:enc_jis = 'iso-2022-jp-3'
else
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
endif


let &fileencodings = 'ucs-bom'
let &fileencodings .= ',' . s:enc_jis


if &encoding ==# 'utf-8'
  "append euc-jp, utf-8(from endoding) and cp932
  let &fileencodings .= ',' . s:enc_euc
  let &fileencodings .= ',' . &encoding
  let &fileencodings .= ',' . 'cp932'
elseif &encoding ==# 'euc-jp'
  "append utf-8, cp932 and euc-jp
  let &fileencodings .= ',' . 'utf-8'
  let &fileencodings .= ',' . s:enc_euc
  let &fileencodings .= ',' . 'cp932'
endif



unlet s:enc_euc
unlet s:enc_jis


if has('win32') || has('win32unix')
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif
set ambiwidth=double

" vim: ts=2 sw=2 sts=2 et fdm=marker
