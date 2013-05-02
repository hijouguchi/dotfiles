if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif



" ヘッダ
syntax match wickedHeaderText "^.\+\n=\+$" " FIXME: うまく動かないときがある
syntax match wickedHeaderText "^.\+\n-\+$" " FIXME: うまく動かないときがある
syntax match wickedHeaderText "^=\+.\+$"

" リンク
syntax match  wickedLinkName "\(\h\w*\)\(/\h\w*\)*\(:\h\w*\)\?" contained
syntax region wickedLink     start="\[\[" end="\]\]" oneline contains=wickedLinkName

" リスト
syntax match wickedList "^\s*-\s"
syntax match wickedList "^\s*[0-9\.]\+\.\s"
" syntax region wickedListText matchgroup=wickedList start="^\s*-\+\s" end="$" oneline
" syntax region wickedListText matchgroup=wickedList start="^\s*[0-9\.]\+\.\s" end="$" oneline

" 水平線
syntax match wickedHr "^\n-\+$" " FIXME: うまく動かないときがある

" 引用
syntax match wickedPre "^\s*>\s.*$"

" table
syntax match  wickedTableHeader    "\*[^|]*" contained
syntax match  wickedTableElement   "\*\@![^|]*"   contained
syntax region wickedTable          start="^|" end="$" oneline contains=wickedTableHeader,wickedTableElement

" ソースコード

let num  = 1
let lmax = line("$")

while num <= lmax
  let line = getline(num)

  if line =~ '^\*\{4,}\s.\+\s\*\{4,}$'
    let lang = substitute(line, '\s*\*\+\s*', '', 'g')
    execute 'syntax include @' . lang . ' syntax/' . lang . '.vim'
    unlet b:current_syntax
    execute 'syntax region wickedCode matchgroup=wickedCodeRegionDelimiter ' .
          \ 'start="^\*\{4,}\s' . lang . '\s\*\{4,}$" end="^\*\{4,}$" contains=@' . lang
    execute 'syntax region wickedCode matchgroup=wickedCodeRegionDelimiter ' .
          \ 'start="^#' . lang . ':\s" end="$" contains=@' . lang . ' oneline'
  endif
  let num = num + 1
endwhile

unlet num
unlet lmax


"syntax include @vim syntax/vim.vim
"unlet b:current_syntax
"syntax region wickedCode matchgroup=wickedCodeRegionDelimiter
"      \ start="^\*\{4,}\svim\s\*\{4,}$" end="^\*\{4,}$" contains=@vim
"syntax region wickedCode matchgroup=wickedCodeRegionDelimiter
"      \ start="^#vim:\s" end="$" contains=@vim oneline
"
"syntax include @ruby syntax/ruby.vim
"unlet b:current_syntax
"syntax region wickedCode matchgroup=wickedCodeRegionDelimiter
"      \ start="^\*\{4,}\sruby\s\*\{4,}$" end="^\*\{4,}$" contains=@ruby
"
"syntax include @zsh syntax/zsh.vim
"unlet b:current_syntax
"syntax region wickedCode matchgroup=wickedCodeRegionDelimiter
"      \ start="^\*\{4,}\szsh\s\*\{4,}$" end="^\*\{4,}$" contains=@zsh
"
"syntax include @verilog syntax/verilog.vim
"unlet b:current_syntax
"syntax region wickedCode matchgroup=wickedCodeRegionDelimiter
"      \ start="^\*\{4,}\sverilog\s\*\{4,}$" end="^\*\{4,}$" contains=@verilog

" shell スクリプト的な
syntax match wickedCodeRegionDelimiter "^\s*[#$%]\s"

highlight def link wickedHeaderText Special
highlight def link wickedLinkName   Underlined
highlight def link wickedList       Identifier
"highlight def link wickedListText   Statement
highlight def link wickedHr         Identifier
highlight def link wickedPre        Comment
highlight def link wickedTable          Statement
highlight def link wickedTableHeader    Identifier
"highlight def link wickedTableElement   String
highlight def link wickedCodeRegionDelimiter Comment


let b:current_syntax = 'wicked'
