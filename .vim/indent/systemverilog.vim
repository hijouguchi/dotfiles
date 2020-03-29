" Vim indent file
" Language:    SystemVerilog
" Maintainer:  hijouguchi

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=SystemVerilogIndent()
setlocal indentkeys=0},0),:,!^F,o,O,e

setlocal indentkeys+==begin,=end
setlocal indentkeys+==endcase
setlocal indentkeys+==join,=join_any,=join_none
setlocal indentkeys+==endmodule,=endclass,=endpackage,=endinterface,=endgroup
setlocal indentkeys+==endfunction,=endtask
setlocal indentkeys+==`else,=`endif
setlocal indentkeys+==`uvm_field_utils_end,=`uvm_object_utils_end,=`uvm_component_end

if exists("*SystemVerilogIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

command!  -nargs=* SVIEcho
      \ if g:systemverilog_indent_debug_echo != 0 |
      \   echom <args>                            |
      \ endif


if !exists('g:systemverilog_indent_debug_echo')
  let g:systemverilog_indent_debug_echo = 1
endif

let s:sv_operator = '+'

" FIXME: if - else が bracketpair と xxx にいるので気持ち悪い
let s:bracketpair = [
      \   #{start:'('                              , middle: ''                   , end:')'                            } ,
      \   #{start:'['                              , middle: ''                   , end:']'                            } ,
      \   #{start:'{'                              , middle: ''                   , end:'}'                            } ,
      \   #{start:'\<begin\>'                      , middle: ''                   , end:'\<end\>'                      } ,
      \   #{start:'\<if\>'                         , middle: '\<else\>'           , end:''                             }
      \ ]

let s:xxx = [
      \   #{start:'\<if\>'                         , middle: '\<else\>'           , end:''                             } ,
      \   #{start:'\<case[xz]\?\>'                 , middle: ''                   , end:'\<endcase\>'                  } ,
      \   #{start:'\<function\>'                   , middle: ''                   , end:'\<endfunction\>'              } ,
      \   #{start:'\<task\>'                       , middle: ''                   , end:'\<endtask\>'                  } ,
      \   #{start:'\<module\>'                     , middle: ''                   , end:'\<endmodule\>'                } ,
      \   #{start:'\<class\>'                      , middle: ''                   , end:'\<endclass\>'                 } ,
      \   #{start:'\<inteface\>'                   , middle: ''                   , end:'\<endinterface\>'             } ,
      \   #{start:'\<package\>'                    , middle: ''                   , end:'\<endpackage\>'               } ,
      \   #{start:'\<generate\>'                   , middle: ''                   , end:'\<endgenerate\>'              } ,
      \   #{start:'`\<ifn\?def\>'                  , middle: '`\<els\%(e\|if\)\>' , end:'`\<endif\>'                   } ,
      \   #{start:'`\<uvm_object_utils_begin\>'    , middle: ''                   , end:'`\<uvm_object_utils_end\>'    } ,
      \   #{start:'`\<uvm_component_utils_begin\>' , middle: ''                   , end:'`\<uvm_component_utils_end\>' }
      \ ]

let s:matchpair = s:bracketpair + s:xxx

let s:sv_label  = '\%(\s*:\s*\k\+\)\?'
let s:skip_expr = 's:SynNameMatch(line("."), col("."), "Comment", "String")'


function! SystemVerilogIndent() "{{{

  let info       = {}
  let info.sw    = shiftwidth()
  let info.col   = col('.')
  let info.clnum = v:lnum
  let info.cline = getline(info.clnum)
  let info.plnum = prevnonblank(info.clnum-1)
  let info.pline = getline(info.plnum)

  SVIEcho 'Enterd SystemVerilogIndent() info =' info

  " Step1: Working on the current line {{{
  let callbacks = [
        \ 's:InComment',
        \ 's:SigleBegin',
        \ 's:DeIndentBlock',
        \ 's:CaseCondition'
        \ ]
  for callback in callbacks
    SVIEcho 'try ' . callback.'()'
    if call(function(callback), [info])
      SVIEcho callback . '() returns ' . info.indent
      return info.indent
    endif
  endfor
  "}}}


  " Step2: Working on the previous line {{{
  let callbacks = [
        \ 's:OneLineFunction',
        \ 's:BracketBlock',
        \ 's:ClosingBracket',
        \ 's:SingleLinePropertyExpr',
        \ 's:PreviousCaseCondition',
        \ 's:PreviousContenuedExpr',
        \ 's:AfterContenuedExpr',
        \ 's:TwoLineIfStatement'
        \ ]
  for callback in callbacks
    SVIEcho 'try ' . callback . '()'
    if call(function(callback), [info])
      SVIEcho callback . '() returns ' . info.indent
      return info.indent
    endif
  endfor
  "}}}


  "let info.plnum_msl = s:GetMSL()

  " Step3: Working on the MSL(?) {{{
  " }}}

  SVIEcho "Not found correctable indent."
  return indent(info.plnum)
  "return -1
endfunction "}}}

function! s:InComment(info) "{{{
  let info = a:info

  if s:SynNameMatch(info.clnum, info.col-1, 'Comment')
    let info.indent = -1
    return v:true
  endif

  return v:false
endfunction "}}}
function! s:SigleBegin(info) "{{{
  let info = a:info

  " 単独 begin はインデントさせない
  " じゃなくて直前の if 系と同じ位置に揃えるべき
  " Example:
  "   if(..)
  "   begin --> here
  "     hoge
  "   end
  "
  "   if (
  "     foo
  "     bar)
  "   begin --> here
  "     hoge
  "   end

  " とりあえず直前の行とインデント合わせる作戦で
  if info.cline =~ '^\s*\<begin\>'
    let info.indent = indent(info.plnum)
    return v:true
  endif

  return v:false
endfunction "}}}
function! s:DeIndentBlock(info) "{{{
  " FXIME: 自分のカーソル位置より左の文字列で見ないとダメそう
  let info = a:info

  " Example:
  "   foo(
  "     A,
  "     B
  "   ); <- here

  " Example:
  "   `ifdef
  "       statement
  "   `else         <- here
  "       statement
  "   `endif        <- here

  SVIEcho "'" . info.cline . "'(" . info.clnum  . ")"
  for item in s:matchpair
    for elm in [item.middle, item.end]
      if elm == ''
        continue
      endif

      let pat = '\%(\s\+\ze\|^\)' . elm
      let match = matchstrpos(info.cline, pat)

      if match[0] == ""
        SVIEcho 'not Found keyword' match
        continue
      endif

      SVIEcho 'Found keyword' match

      " search starting bracket
      "call s:cursor(info.clnum, match[2])
      call s:cursor(info.clnum, match[1])
      let jump = s:searchpair(item.start, item.middle, item.end, 'bW', s:skip_expr)

      if jump
        SVIEcho 'found ' . item.start . ' at line:' . line('.') . ' col:' . col('.')
        let info.indent = indent(line('.'))
        return v:true
      else
        SVIEcho 'not found' . item.start
        return v:false
      end
    endfor
  endfor

  return v:false
endfunction "}}}
function! s:CaseCondition(info) "{{{
  let info = a:info

  " Example:
  " case(hoge)
  "   foo0: bar0; --> here
  "   foo1: bar1; --> here
  " endcase

  let line = s:RemoveComment(info.cline)

  " : があること前提
  if line !~ ':'
    return v:false
  endif

  SVIEcho 'found :'

  if s:searchpair('\<case[xz]\?\>', '', '\<endcase\>', 'bW', s:skip_expr)
    let lnum = line('.')
    let info.indent = indent(lnum) + info.sw
    return v:true
  else
    return v:false
  endif
endfunction "}}}

function! s:OneLineFunction(info) "{{{
  let info = a:info
  "Example:
  " function hoge(); endfunction
  " <X> --> here

  for item in s:xxx
    if len(item.end) == 0
      continue
    endif

    SVIEcho 'trying' item.start '~' item.end

    if info.pline =~ item.start . '.*' . item.end
      SVIEcho 'found'
      let info.indent = -1
      return v:true
    endif

  endfor

  SVIEcho 'not found'
  return v:false

endfunction "}}}
function! s:BracketBlock(info) "{{{
  let info = a:info

  " Example:
  " foo(
  "   bar <- here
  " )
  for item in s:bracketpair
    for elm in [item.start, item.middle]
      " FXIME: /* ... */ のコメントを無視するようにする
      let pat = elm . '\s*\%(:\s*\k\+\s*\)\?$'
      let match = matchstrpos(info.pline, pat)

      if match[0] == ""
        SVIEcho 'Not found' elm
        continue
      endif

      SVIEcho 'Found keyword ' match

      let info.indent = indent(info.plnum) + info.sw
      return v:true
    endfor
  endfor

  return v:false
endfunction "}}}
function! s:ClosingBracket(info) "{{{
  let info = a:info

  " Example:
  " function hoge (
  "   foo
  "   bar);
  "   buz<- here
  " 直前の行が ) で終わってるとき、対応する (
  " を探して、その行に function などのキーワードがいるかをみる
  SVIEcho '('. info.plnum . ') "' . info.pline . '"'
  "let match = s:MatchLast(info.plnum, ')')
  " ) 以降は ";" か ": label" だけ許す
  let match = s:Match(info.plnum, ')' . '\s*\%(;\|:\s*\<\k\+\>\)\?')

  " ) 以降は ";" か ": label" だけ許すので、そうなってるか確認する
  let line = info.pline[match[2]:-1]
  SVIEcho match
  SVIEcho 'Checkpoint 0 "' . line . '"'
  let line = s:RemoveComment(line)
  SVIEcho 'Checkpoint 1 "' . line . '"'

  " ";" と ": label" があれば削除
  let line = substitute(line, ';',            '', 'g')
  let line = substitute(line, ':\s*\<\k\+\>', '', '')
  SVIEcho 'Checkpoint 2 "' . line . '"'

  " コメントと ";", ": label" を削除したら空っぽになってるはず
  if line !~ '^\s*$'
    SVIEcho 'line "' . line . '" is not empty line'
    return v:false
  endif

  if match[1] == -1
    SVIEcho 'not found )'
    return v:false
  endif

  SVIEcho 'found )'

  " 見つかった ) に対応する ( を探す
  call s:cursor(info.plnum, match[1])
  let jump = s:searchpair('(', '', ')', 'bW', s:skip_expr)

  if jump == 0
    SVIEcho 'not found ('
    return v:false
  endif
  SVIEcho 'found ('
  "SVIEcho 'Current cursor = ' . line('.') . ', ' . col('.')


  " 見つけた行、あるいはその上の行に ) がいる可能性がある
  " class や module などの parameter が該当
  " それを見つけたら parameter の行に飛ぶ
  " XXX: ひとまず同じ行に ) がいないかを探す
  let lnum = line('.')
  let match = s:Match(lnum, ')')

  "SVIEcho 'Current cursor = ' . lnum . ', ' . col

  if match[1] != -1
    SVIEcho 'found more )'
    call s:cursor(lnum, match[1])
    let jump = s:searchpair('(', '', ')', 'bW', s:skip_expr)
  endif

  " 見つけた ( と同じ行に function とかがいるはず
  let lnum = line('.')
  for item in s:xxx
    let match = s:Match(lnum, item.start)
    if match[1] != -1
      SVIEcho 'Match ' . item

      let info.indent = indent(lnum) + info.sw
      return v:true
    endif
  endfor

  return v:false
endfunction "}}}
function! s:SingleLinePropertyExpr(info) "{{{
  let info = a:info

  " Example:
  " initial /* ... */
  "   foo;

  let line = s:RemoveComment(info.pline)

  if line =~ '^\s*' . '\<initial\|always\|forever\|foreach\>'
    SVIEcho 'found property'
    let info.indent = indent(info.plnum) + info.sw
    return v:true
  else
    SVIEcho 'not found property'
    return v:false
  endif
endfunction "}}}
function! s:PreviousCaseCondition(info) "{{{
  let info = a:info

  " Example:
  " case(hoge)
  "   foo0:
  "     foo; --> here
  "   foo1: bar1; --> here
  " endcase

  let line = s:RemoveComment(info.pline)
  SVIEcho 'line = "' . line '"'

  " : があること前提
  if line !~ ':'
    return v:false
  endif

  SVIEcho 'found :'

  let lnum = line('.')

  if s:searchpair('\<case[xz]\?\>', '', '\<endcase\>', 'bW', s:skip_expr)
    " : が見つかった場所からひとつインデントを深くする
    let info.indent = indent(lnum) + info.sw
    return v:true
  else
    return v:false
  endif
endfunction "}}}
function! s:PreviousContenuedExpr(info) "{{{
  let info = a:info

  " Example:
  " foo = a +
  "   b --> here

  let lnum = prevnonblank(info.plnum)
  SVIEcho '('. lnum . ') ' . getline(lnum)

  let expr_plnum = s:GetExprLine(lnum)
  SVIEcho '('. expr_plnum . ') ' . getline(expr_plnum)

  if expr_plnum < lnum
    SVIEcho 'found expr'
    let info.indent = indent(expr_plnum) + info.sw
    return v:true
  else
    SVIEcho 'not found expr'
    return v:false
  endif
endfunction "}}}
function! s:AfterContenuedExpr(info) "{{{
  let info = a:info

  " Example:
  " foo = a +
  "   b;
  " hoge = 3; --> here

  let lnum = prevnonblank(info.plnum-1)
  SVIEcho '('. lnum . ') ' . getline(lnum)

  let expr_plnum = s:GetExprLine(lnum)
  SVIEcho '('. expr_plnum . ') ' . getline(expr_plnum)

  if expr_plnum < lnum
    SVIEcho 'found expr'
    let info.indent = indent(expr_plnum)
    return v:true
  else
    SVIEcho 'not found expr'
    return v:false
  endif
endfunction "}}}
function! s:TwoLineIfStatement(info) "{{{
  let info = a:info

  " Example:
  " if(foo)
  "   bar
  " <X> --> here

  " 2行上のステートメントを探す

  let lnum = info.plnum
  SVIEcho '1 ('. lnum . ') ' . getline(lnum)
  let expr_plnum = s:GetExprLine(lnum)
  let expr_plnum = min([lnum, expr_plnum])
  SVIEcho '2 ('. expr_plnum . ') ' . getline(expr_plnum)

  " この行は statement のはず。(行末が ; で終わるはず)
  " `uvm_info() などの macro は除外する
  let line = getline(expr_plnum)
  let line = s:RemoveComment(line)
  if line !~ ';\s*$' " 行末は ; で終わってる
    SVIEcho '"' . getline(expr_plnum) . '" is not end of statement'
    return v:false
  endif

  let lnum = prevnonblank(expr_plnum-1)
  let expr_plnum2 = s:GetExprLine(lnum)
  let expr_plnum2 = min([lnum, expr_plnum2])
  SVIEcho '3 ('. expr_plnum2 . ') ' . getline(expr_plnum2)

  " この行に if か else がいるはず
  " FIXME: if(xxx) の部分が複数行になっている場合に対応できていない

  let line = getline(expr_plnum2)
  "if line =~ '^\s*\<if\|else\>'
  if line =~ '^\s*\%(\<if\|else\>\s*\)\{1,2}'
    SVIEcho 'found if, else or elseif'
    let info.indent = indent(expr_plnum2)
    return v:true
  elseif line =~ '^\s*' . '\<initial\|always\|forever\|foreach\>'
    SVIEcho 'found initial, always and so on...'
    let info.indent = indent(expr_plnum2)
    return v:true
  else
    SVIEcho 'not found if, else or elseif'
    return v:false
  endif
endfunction "}}}

function! s:SynNameMatch(lnum, col, ...) "{{{
  let name = synIDattr(synIDtrans(synID(a:lnum, a:col, 1)), "name")
  let found_list = filter(copy(a:000), {_, v -> v == name})

  SVIEcho 's:SynNameMatch('.a:lnum.','.a:col.') -> ' . found_list

  return found_list->len() > 0
endfunction "}}}


" コメントをスキップした matchstrpos
function! s:Match(lnum, regexp) "{{{
  let line = getline(a:lnum)
  let ma   = matchstrpos(line, a:regexp)

  while ma[1] != -1 && s:SynNameMatch(a:lnum, ma[1], 'Comment')
    let ma = matchstrpos(line, a:regexp, ma[2])
  endwhile

  return ma
endfunction "}}}
" コメントをスキップした matchstrpos で、一番最後にヒットした箇所を返す
function! s:MatchLast(lnum, regexp) "{{{
  let line = getline(a:lnum)
  let ma   = matchstrpos(line, a:regexp)
  let ml   = ['', -1, -1]

  while ma[1] != -1
    " ヒット位置がコメントじゃないなら返す値候補を更新
    if !s:SynNameMatch(a:lnum, ma[1], 'Comment')
      let ml = ma
    endif

    " 次の候補を検索
    let ma = matchstrpos(line, a:regexp, ma[2])
  endwhile

  return ml
endfunction "}}}
function! s:cursor(lnum, col) "{{{
  let col = max([1, a:col]) " col が 0 だと良くないので

  SVIEcho 'jamp to cursor(' . a:lnum . ',' . col . ')'
  call cursor(a:lnum, col)
endfunction "}}}
function! s:searchpair(start, middle, end, ...) "{{{
  let args = [a:start, a:middle, a:end] + a:000
  let jump = call('searchpair', args)

  if jump == 0 || jump == -1
    SVIEcho 'cursor stay(' . line('.') . ',' . col('.') . ')'
    return v:false
  endif

  SVIEcho 'jamp to cursor(' . a:lnum . ',' . a:col . ')'
  return v:true
endfunction "}}}
function! s:GetExprLine(lnum) "{{{
  let lnum  = a:lnum
  let match = s:MatchLast(lnum, s:sv_operator)


  while match[1] != -1
    " operator は見つかったけど、行末なのかは不明
    " なので確認する
    let line = getline(lnum)[match[2]:-1]
    let line = s:RemoveComment(line)

    " スペースしかないはず
    if line =~ '\S'
      return lnum+1
    endif

    " 継続してる行なので上の行を見る
    let lnum = prevnonblank(lnum-1)
    let match = s:Match(lnum, s:sv_operator)
  endwhile

  return lnum+1
endfunction "}}}

function! s:RemoveComment(line) "{{{
  let line = a:line
  " コメントがあれば全部削除
  let line = substitute(line, '//.*$',       '', '')  " // ...
  let line = substitute(line, '/\*.\{-}\*/', '', 'g') " /* ... */
  let line = substitute(line, '/\*.*$',      '', '')  " /* ... (コメントが継続)

  return line
endfunction "}}}

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:sw=2
