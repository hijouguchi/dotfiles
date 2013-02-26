" option {{{1
" reglar settings {{{2
set nocompatible
syntax enable

set background=dark

filetype plugin indent on

set viminfo='100,<50,s10,h,n~/.vim/viminfo
set history=1000

" C の再インデントに影響を与える
set cinoptions=:0,t0,(0,W1s

" コマンドライン補完関係
set wildmenu
set wildchar=<tab>
set wildmode=list:longest,full

set autoindent
set number
" bs などを押したときのインデント関係の挙動
set backspace=indent,eol,start
set matchpairs+=<:>
" ^a, ^x を押したときの増減の挙動
set nrformats=alpha,hex
" 新しい行を作ったときのインデントの挙動
set smartindent
" エラー時にベルを鳴らさない
set noerrorbells
" fold を有効にする
" NOTE: ここら辺の設定は ソース中の vim: ... に記述するべき
set foldmethod=marker

set completeopt=menuone,preview

"search option
set incsearch
set ignorecase
set smartcase
set wrapscan

set autowrite

set nowritebackup

"set complete=.,w,b,u,t,i,d,k
set complete=.,w,b,u,t,k

set backup
set backupext=.bak
set backupdir=/tmp
set directory=/tmp

set formatoptions=nlM1

set shiftwidth=2
set tabstop=2
set softtabstop=2

"fileencodings {{{2


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

set fileformats=unix,dos,mac
set ambiwidth=double

" window settings {{{2
"
set t_Co=256
colorscheme desert
highlight Pmenu cterm=underline ctermbg=8
highlight PmenuSel ctermbg=7 ctermfg=0
highlight PmenuSbar ctermbg=0

"highlight Folded cterm=bold ctermbg=4 ctermfg=7
highlight Folded cterm=bold ctermbg=7 ctermfg=4

set listchars=tab:\ \ ,eol:.,trail:_

set list
set showcmd
set showmode

" for statusline
set laststatus=2
set statusline=%<%f%=
set statusline+=%{MyStatusSpec()}
set statusline+=\ %3cC,%3l/%LL\ %P


" keymap settings {{{1
" default map {{{2
" do not show help when press F1
noremap <F1> <NOP>


" normal node {{{2
" normal settings {{{3
nmap <Space> [SPACE]
nnoremap ; :
nnoremap : ;

nnoremap Y  y$
nnoremap dl 0d$

nnoremap -- mzgg=G`z

nnoremap j gj
nnoremap k gk

nnoremap q    <NOP>
nnoremap Q    <NOP>

"help
noremap <C-H> :help<Space>

"save file
nnoremap ,w :up<CR>


" search highlight
nnoremap / :set hlsearch<CR>/
nnoremap * :set hlsearch<CR>*
nnoremap [SPACE]/ :set hlsearch! \| :set hlsearch?<CR>

" fold を展開して，画面の中央にする
nnoremap gg ggzvzz
nnoremap n  nzvzz
nnoremap N  Nzvzz

" set paste をトグルする
nnoremap [SPACE]p :set paste! \| :set paste?<CR>

" tag ジャンプ
" next
nnoremap <C-N> <C-]>
" previous
nnoremap <C-P> <C-T>


" スクリプトを実行してみる
nnoremap [SPACE]e :!./%<CR>

" for window mode (in normal) {{{3
nmap [SPACE]w <C-W>


" insert mode {{{2
inoremap        <Tab>   <C-R>=InsertTabWrapper()<CR>
inoremap <expr> <CR>    pumvisible() ? neocomplcache#close_popup() : "\<CR>"
inoremap <expr> <S-CR>  pumvisible() ? "<C-Y><CR>" : "<S-CR>"
inoremap <expr> <Esc>[Z pumvisible() ? "<C-P>"     : "<S-Tab>"
inoremap        <C-]>   <C-O>:

imap		<C-K> <Plug>(neocomplcache_snippets_expand)
smap    <C-k> <Plug>(neocomplcache_snippets_expand)


" visual mode {{{2
vnoremap ; :
vnoremap : ;


" command line mode {{{2
" コマンドラインは emacs キーバインドで良い気がする
cnoremap <C-B> <left>
cnoremap <C-F> <right>
cnoremap <C-A> <Home>

" 補完方向が逆の方がしっくりくるので
cnoremap <C-P> <up>
cnoremap <C-N> <down>


" respected from kana
" Search slashes easily (too lazy to prefix backslashes to slashes)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> \  getcmdtype() == '/' ? '\\' : '\'


" command {{{1
" default commands {{{2
command! InsertEnvAndCoding
      \ call append(0, [
      \ '#!/usr/bin/env ' . &l:filetype,
      \ '# coding: ' . ((&l:fenc!= '') ? &l:fenc : &l:enc),
      \ ''
      \ ])

command! InsertDate
      \ call append(".", strftime("%Y/%m/%d"))

" change a character code {{{2
command! -bang DefaultLocale e<bang> ++enc=utf-8 ++ff=unix
command! -bang Utf8   e<bang> ++enc=utf-8
command! -bang Euc    e<bang> ++enc=euc-jp
command! -bang Cp932  e<bang> ++enc=cp932
command! -bang Jis    e<bang> ++enc=iso-2022-jp

command! -bang Unix   e<bang> ++ff=unix
command! -bang Mac    e<bang> ++ff=mac
command! -bang Dos    e<bang> ++ff=dos


" autocmd {{{1
" basic autocmd {{{2
augroup MyAutoCmd
	autocmd!
  autocmd BufWritePost * if getline(1) =~ "^#!" |
        \ silent! exe "silent! !chmod +x %" | endif

  " if the file doesn't have used Japanese, set fileencoding to utf-8
  " from kana's vimrc http://github.com/kana/config/
  autocmd BufReadPost *
        \   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
        \ |   setlocal fileencoding=utf-8
        \ | endif

  " if the file doesn't have used tab by space, set expandtab
  autocmd BufReadPost *
        \   if search('^\t', 'cnw') == 0
        \ |   setlocal expandtab
        \ | endif

  autocmd FileType *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif



	"set filetype R for .r (not set to rexx)
	autocmd BufNewFile,BufEnter *.r,*.R setlocal filetype=r
	"set filetype gnuplot for .plt
	autocmd BufNewFile,BufEnter *.plt setlocal filetype=gnuplot
  " set filetype spice for .mdl
	autocmd BufNewFile,BufEnter *.mdl setlocal filetype=spice


  " verilog indent (see also :help verilog)
  autocmd BufReadPost * if exists("b:current_syntax")
  autocmd BufReadPost *   if b:current_syntax == "verilog"
  autocmd BufReadPost *     let b:verilog_indent_modules = 1
  autocmd BufReadPost *   endif
  autocmd BufReadPost * endif
augroup END


" display trailing spaces {{{2
augroup HighlightTrailingSpaces
  autocmd!

	autocmd BufEnter,ColorScheme *
				\  highlight TrailingSpacess guibg=Red ctermbg=Red
  autocmd BufEnter *
				\   if &l:filetype != 'help'
				\ |   match TrailingSpacess /\(\s*\( \t\|\t \)\s*\|\s\s*$\)/
        \ | else
        \ |  match none
				\ | endif
augroup END



" set binary format {{{2
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin let &l:binary = 1

  autocmd BufReadPost  * if &l:binary
  autocmd BufReadPost  *   set ft=xxd
  autocmd BufReadPost  *   silent %!xxd -g 1
  autocmd BufReadPost  * endif

  autocmd BufWritePre  * if &l:binary
  autocmd BufWritePre  *   %!xxd -r
  autocmd BufWritePre  * endif

  autocmd BufWritePost * if &l:binary
  autocmd BufWritePost *   silent %!xxd -g 1
  autocmd BufWritePost * endif
augroup END

" foldmethod が重い時の対処 {{{2
" see also: http://d.hatena.ne.jp/thinca/20110523/1306080318
augroup foldmethod-expr
  autocmd!
  autocmd InsertEnter * if &l:foldmethod ==# 'expr'
  \                   |   let b:foldinfo = [&l:foldmethod, &l:foldexpr]
  \                   |   setlocal foldmethod=manual foldexpr=0
  \                   | endif
  autocmd InsertLeave * if exists('b:foldinfo')
  \                   |   let [&l:foldmethod, &l:foldexpr] = b:foldinfo
  \                   | endif
augroup END

" plugin {{{1
" bundle settings {{{2
" see also http://vim-users.jp/2011/04/hack215/
filetype off

set rtp+=~/.vim/vundle.git/
call vundle#rc()


" help (japanese)
Bundle 'git://github.com/vim-jp/vimdoc-ja.git'

Bundle 'git://github.com/kana/vim-ku.git'
Bundle "surround.vim"
Bundle 'git://github.com/kana/vim-submode.git'
Bundle 'Align'

Bundle 'git://github.com/Shougo/neocomplcache.git'
Bundle 'git://github.com/Shougo/neocomplcache-snippets-complete.git'
Bundle 'git://github.com/thinca/vim-ref.git'
" Bundle 'vimwiki'

filetype plugin indent on
" neocomplcache {{{2
" set temporary directory
let g:neocomplcache_temporary_dir     = '/var/tmp/neocon'
let g:neocomplcache_snippets_dir      = '$HOME/.vim/snippet'
" enable neocomplcache
let g:neocomplcache_enable_at_startup = 1

" submode {{{2
" solve ^W < - + > ...
call submode#enter_with('Window', 'n', '', '<C-W>+')
call submode#enter_with('Window', 'n', '', '<C-W>-')
call submode#enter_with('Window', 'n', '', '<C-W>>')
call submode#enter_with('Window', 'n', '', '<C-W><')
call submode#leave_with('Window', 'n', '', '<Esc>')
call submode#map('Window', 'n', '', '-', '<C-W>-')
call submode#map('Window', 'n', '', '=', '<C-W>+')
call submode#map('Window', 'n', '', '+', '<C-W>+')
call submode#map('Window', 'n', '', '<', '<C-W><')
call submode#map('Window', 'n', '', '>', '<C-W>>')

" tiny function {{{1
function! MyStatusSpec() "{{{2
  let l = []
  if &paste | call add(l, 'paste') | endif
  if &modified | call add(l, '+') | endif
  if !&modifiable | call add(l, '-') | endif
  if len(&filetype)>0 | call add(l, &filetype) | endif
  call add(l, len(&fenc)>0?&fenc:&enc)
  call add(l, &fileformat)
  return '[' . join(l, ',') . ']'
endfunction


function! InsertTabWrapper() "{{{2
  if pumvisible()
    return "\<C-N>"
  elseif getline('.')[col('.')-2] =~ '\k'
    call neocomplcache#start_manual_complete()
    return "\<C-N>"
  else
    return "\<TAB>"
  endif
endfunction


function! Man(...) "{{{2
  execute "topleft new " . a:1
  silent! execute "0r!man " . a:1
  setlocal nolist
  setlocal nonumber
  call cursor(1, 1)
  setlocal nomodified
  setlocal readonly
endfunction
command! -nargs=+ Man call Man(<f-args>)


function! SubstituteInsertLines(...) "{{{2
  if(a:0 != 5)
    return 1
  endif

  let l:line1   = a:1
  let l:line2   = a:2
  let l:pattern = a:3
  let l:s_num   = a:4
  let l:e_num   = a:5

  let l:lines = getline(l:line1, l:line2)
  let l:array = []

  for l:i in range(l:s_num + 1, l:e_num)
    for l:line in l:lines
      let l:tmp = substitute(l:line, l:pattern, l:i, "g")
      call add(l:array, l:tmp)
    endfor
  endfor

  call append(l:line2, l:array)
  execute l:line1.','.l:line2.'substitute/'.l:pattern.'/'.l:s_num.'/g'
endfunction
command! -nargs=* -range SubstituteInsertLines call SubstituteInsertLines(<line1>, <line2>, <f-args>)
" usage: :[range]SubstituteInsertLines {pattern} {start_num} {end_num}
" for each lines in [range] replace a match of {pattern} with
" {start_num}...{end_num}
"
" foo Z bar " befour
"
" Foo 0 bar " after
" Foo 1 bar
" ...

" END {{{1
" vim:fdm=marker:et
