" First {{{1
set nocompatible
filetype off
" vim が何をしてるかを確認する用の設定
" set verbosefile=~/vim.log
" set verbose=9


" Bundle settings {{{1

set runtimepath& runtimepath+=~/.vim/vundle.git
call vundle#rc()

" Bundle plugins {{{2

Bundle 'https://github.com/vim-jp/vimdoc-ja.git'
Bundle 'https://github.com/kana/vim-smartchr.git'
Bundle 'Align'
Bundle 'surround.vim'
Bundle 'https://github.com/Shougo/vimproc.vim.git'
" Bundle 'Zenburn'
" Bundle 'https://github.com/kana/vim-ku.git'
" Bundle 'https://github.com/thinca/vim-ref.git'


" vim-submode {{{3
Bundle 'https://github.com/kana/vim-submode.git'

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


" vim-smartinput {{{3
Bundle 'https://github.com/kana/vim-smartinput.git'

" " FIXME: この設定で smartinput#define_rule() で改行ができない (なぜ？)
" "        改行が必要な場合は、代替として <C-O>o, <Esc>o を使う
" call smartinput#map_to_trigger('i', '<Plug>(vimrc_cr)', '<CR>', '<CR>')
" call smartinput#define_rule({
" \ 'at': '^\%(.*=\)\?\s*\zs\%(begin\)\>\%(.*[^.:@$]\<end\>\)\@!.*\%#$',
" \ 'char': '<CR>',
" \ 'input': '<C-O>oend<C-O>O',
" \ 'filetype': ['verilog', 'eruby.verilog'],
" \ })

" call smartinput#map_to_trigger('i', '%', '%', '%')
" call smartinput#define_rule({
"       \   'at'       : '<\%#',
"       \   'char'     : '%',
"       \   'input'    : '% %><Left><Left><Left>',
"       \   'filetype' : ['eruby.verilog'],
"       \ })
"

call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
call smartinput#define_rule({
      \   'at': '\({\|\<do\>\)\s*\%#',
      \   'char': '<Bar>',
      \   'input': '<Bar><Bar><Left>',
      \   'filetype': ['ruby'],
      \ })


" vim-textobj {{{3
Bundle 'https://github.com/kana/vim-textobj-user.git'
Bundle 'https://github.com/sgur/vim-textobj-parameter.git'


" vim-quickrun {{{3
Bundle 'https://github.com/thinca/vim-quickrun.git'
Bundle 'https://github.com/osyo-manga/quickrun-outputter-replace_region.git'
Bundle 'https://github.com/osyo-manga/shabadou.vim.git'


let g:quickrun_config = {
      \   "_" : {
      \       "outputter/buffer/split"              : ":topleft",
      \       "outputter/error/error"               : "quickfix",
      \       "outputter/error/success"             : "buffer",
      \       "outputter"                           : "error",
      \       "outputter/buffer/close_on_empty"     : 1
      \   }
      \}


" neocomplete {{{3
"Bundle 'https://github.com/Shougo/neocomplcache.git'
Bundle 'https://github.com/Shougo/neocomplete.vim.git'
Bundle 'https://github.com/Shougo/neosnippet'

" set temporary directory
let g:neocomplete#data_directory		= '~/.history/neocomplete'
" enable neocomplate
let g:neocomplete#enable_at_startup = 1
" neosnippet snippets directory
let g:neosnippet#snippets_directory = '~/.vim/snippet'



" foldCC {{{3
Bundle 'https://github.com/LeafCage/foldCC.git'
" 使い方は autoload/fildCC.vim を参照 (help 無し)
" let g:foldCCtext_head = 'helo '



" matchit {{{3
" MEMO: bundle ではない
runtime macros/matchit.vim



" settings {{{1
filetype plugin indent on
syntax enable


" ^a, ^x を押したときの増減の挙動
set nrformats=alpha,hex

" 矩形選択時に文字がないところにもカーソルを移動できるように
set virtualedit=block

set noerrorbells


" indent settings
set shiftwidth=2
set tabstop=2
set softtabstop=2
set autoindent
set cinoptions=:0,t0,(0,W1s
set backspace=indent,eol,start
set matchpairs& matchpairs+=<:>
set smartindent
set completeopt=menuone,preview
set formatoptions=nlM1
set cindent

" complete settings
"set complete=.,w,b,u,t,i,d,k
set complete=.,w,b,u,t,k

set wildmenu
set wildchar=<tab>
set wildmode=list:longest,full


" history settings
set viminfo='100,<50,s10,h
set history=1000


"search options
set incsearch
set ignorecase
set smartcase
set wrapscan


" backup options
" 何もバックアップを作らない
set nobackup
set nowritebackup
set noundofile
" set backupext=.bak
" set backupdir-=.
" set directory-=.


" fold settings
set foldmethod=marker
set foldopen=hor,insert,mark,percent,quickfix,undo
set foldtext=FoldCCtext()

" window settings
set number
set list

" no display intro
set shortmess+=I



set listchars=tab:\ \ ,eol:.,trail:_

set showcmd
set showmode

set laststatus=2
set statusline=%<%f%=
set statusline+=%{MyStatusSpec()}
set statusline+=\ %3cC,%3l/%LL\ %P

function! MyStatusSpec() "{{{
  let l = []
  if &paste | call add(l, 'paste') | endif
  if &modified | call add(l, '+') | endif
  if !&modifiable || &readonly | call add(l, '-') | endif
  if len(&filetype)>0 | call add(l, &filetype) | endif
  call add(l, len(&fenc)>0?&fenc:&enc)
  call add(l, &fileformat)
  return '[' . join(l, ',') . ']'
endfunction "}}}


" MEMO: 色を確認する場合は， :runtime syntax/colortest.vim を開く
"       :highlight で，適応されているのが確認できる
" FIXME: 対応していない端末をどうやって探すか
set t_Co=256

" GUI 起動時に 'background' などが上書きされてしまうことがあるらしい
" GUI では、colorscheme 系を再設定した方が良い
" それらを関数でまとめて、autocmd GUIEnter で呼び出すようにする
function! SetMyColorscheme()
  colorscheme desert

  highlight Folded NONE
  highlight link Folded Comment

  highlight Pmenu         term=NONE ctermfg=White     ctermbg=DarkGray
  highlight PmenuSel      term=bold ctermfg=LightGray ctermbg=DarkRed
  highlight PmenuSbar                                  ctermbg=DarkGray
  highlight PmenuThumb                                 ctermbg=White

  " GUI で色が付けられると見にくい
  highlight NonText     gui=NONE guibg=NONE
endfunction

" CUI 用に一度呼び出す
call SetMyColorscheme()


"enc, fencs, ff {{{2

set fileformats=unix,dos,mac
set ambiwidth=double

" KaoriYa をベースにしている
if has('iconv') && iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
  let s:enc_euc = 'euc-jisx0213,euc-jp'
  let s:enc_jis = 'iso-2022-jp-3'
else
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
endif

" encoding によって fileencodings を設定する
if &encoding ==? 'utf-8'
  let &fileencodings = join([s:enc_jis, 'cp932', s:enc_euc, 'ucs-bom'], ',')
elseif &encoding ==? 'cp932'
  let &fileencodings = join(['ucs-bom', 'latin1', s:enc_jis, 'utf-8', s:enc_euc], ',')
elseif &encoding ==? 'euc-jp' || &encoding ==? 'euc-jisx0213'
  let &fileencodings = join(['ucs-bom', 'latin1', s:enc_jis, 'utf-8', 'cp932'], ',')
endif

" KaoriYa vim only
if has('guess_encode')
  let &fileencodings = 'guess,' . &fileencodings
end

unlet s:enc_euc
unlet s:enc_jis



" command {{{1

command! InsertEnvAndCoding call s:insertEnvAndCoding()
function! s:insertEnvAndCoding() "{{{
  if(! exists('b:current_env'))
    let b:current_env = '#!/usr/bin/env ' . &l:filetype
  endif
  call append(0, [
        \ b:current_env,
        \ '# coding: ' . ((&l:fenc!= '') ? &l:fenc : &l:enc),
        \ ''
        \ ])
endfunction "}}}

command! -bang Utf8   e<bang> ++enc=utf-8
command! -bang Euc    e<bang> ++enc=euc-jp
command! -bang Cp932  e<bang> ++enc=cp932
command! -bang Jis    e<bang> ++enc=iso-2022-jp

command! -bang Unix   e<bang> ++ff=unix
command! -bang Mac    e<bang> ++ff=mac
command! -bang Dos    e<bang> ++ff=dos


command! -nargs=* -range=0 -complete=customlist,quickrun#complete
      \ ReplaceRegion QuickRun
      \ -mode v
      \ -outputter replace_region
      \ -outputter/message/log 1
      \ <args>

" autocmd {{{1
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

  " if the file doesn't have used tab by space, set expandtab
  " FIXME: Makefile などの、tab 必須のファイルでも expandtab が有効になってしまう
  autocmd BufReadPost *
        \   if search('^\t', 'cnw') == 0
        \ |   setlocal expandtab
        \ | endif

  autocmd BufNewFile * setlocal expandtab

  autocmd FileType *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif



  autocmd BufRead,BufNewFile *.r,*.R     set filetype=r
  autocmd BufRead,BufNewFile *.m,*.mat   set filetype=octave
  autocmd BufRead,BufNewFile *.mdl       set filetype=spice
  autocmd BufRead,BufNewFile *.gp        set filetype=gnuplot

  autocmd BufRead,BufNewFile *.v.erb     set filetype=eruby.verilog
  autocmd BufRead,BufNewFile *.sp.erb    set filetype=eruby.spice
  autocmd BufRead,BufNewFile *.gp.erb    set filetype=eruby.gnuplot
  autocmd BufRead,BufNewFile *.htm.erb   set filetype=eruby.html
  autocmd BufRead,BufNewFile *.html.erb  set filetype=eruby.html

  " enable QuickFix for grep
  " see also: http://qiita.com/items/0c1aff03949cb1b8fe6b
  autocmd QuickFixCmdPost *grep* cwindow
augroup END


augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin set binary

  autocmd BufReadPost  * if &l:binary
  autocmd BufReadPost  *   set ft=xxd
  autocmd BufReadPost  *   set readonly
  autocmd BufReadPost  *   silent %!xxd -g 1
  autocmd BufReadPost  * endif
augroup END

augroup GuiColorScheme
  autocmd!
  autocmd GUIEnter * call SetMyColorscheme()
augroup END

" keymap settings {{{1

nmap <Space>w <C-W>

nnoremap <Space>bl :buffers<CR>
nnoremap <Space>bn :bnext<CR>
nnoremap <Space>bp :bprevious<CR>

for i in range(1, 9)
  " nnoremap <Space>b0 :buffer 0<CR>
  execute 'silent! nnoremap <Space>b'. i . ' :buffer ' . i . '<CR>'
endfor

" 何もさせない
noremap  <F1> <NOP>
noremap! <F1> <NOP>
nnoremap q    <NOP>
nnoremap Q    <NOP>

" normal mode
noremap ; :
noremap : ;

nnoremap j gj
nnoremap k gk

nnoremap ) t)
nnoremap ( t(

noremap <C-H> :help<Space>

nnoremap Y  y$
nnoremap dl 0d$

" すべての行でインデントをしなおす
nnoremap -- mzgg=G`z



" search highlight
nnoremap / :set hlsearch<CR>/
nnoremap * :set hlsearch<CR>*zv
nnoremap <Space>/ :set hlsearch! \| :set hlsearch?<CR>

" fold を展開して，画面の中央にする
nnoremap gg ggzvzz
nnoremap n  nzvzz
nnoremap N  Nzvzz

" set paste をトグルする
nnoremap <Space>p :set paste! \| :set paste?<CR>

" tag jump
nnoremap <C-N> <C-]>
nnoremap <C-P> <C-T>


" insert, select mode
inoremap <expr> <Tab>   InsertTabWrapper()
imap     <expr> <CR>    InsertCRWrapper()
"inoremap <expr> <Esc>[Z pumvisible() ? "<C-P>"     : "<S-Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "<C-P>"     : "<S-Tab>"
"inoremap <expr> <C-F>   neocomplcache#manual_filename_complete()
inoremap <expr> <C-F>   neocomplete#manual_filename_complete()

imap    <C-K> <Plug>(neosnippet_expand_or_jump)
smap    <C-K> <Plug>(neosnippet_expand_or_jump)

imap    <C-L> <Plug>(neosnippet_expand)
smap    <C-L> <Plug>(neosnippet_expand)

" visual mode
vnoremap i I
vnoremap a A

vnoremap <Space>rp :ReplaceRegion erb -T -<CR>

" command mode
cnoremap <C-B> <left>
cnoremap <C-F> <right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" 補完方向が逆の方がしっくりくるので
cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <expr> /     getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> \     getcmdtype() == '/' ? '\\' : '\'
cnoremap <expr> [     getcmdtype() == '/' ? '\[' : '['
cnoremap <expr> <CR>  getcmdtype() == '/' ? "\<CR>zvzz" : "\<CR>"

" sorround
" s, gs を S, gS と等価にさせる
xmap s  <Plug>VSurround
xmap gs <Plug>VgSurround


" tiny functions {{{1
function! InsertTabWrapper() "{{{
  if pumvisible()
    return "\<C-N>"
  elseif getline('.')[col('.')-2] =~ '\k'
    "call neocomplcache#start_manual_complete()
    call neocomplete#start_manual_complete()
    return "\<C-N>"
  else
    return "\<TAB>"
  endif
endfunction "}}}

function! InsertCRWrapper() "{{{
  if neosnippet#expandable()
    return "\<Plug>(neosnippet_expand)"
  elseif pumvisible()
    let key = neocomplete#close_popup()
    return key . "\<CR>"
    "return "\<Plug>(vimrc_cr)"
  else
    return "\<CR>"
    "return "\<Plug>(vimrc_cr)"
  endif
endfunction "}}}


" Fin. {{{1

set secure



" __END__ {{{1
" vim: et ts=2 sts=2 st=2 tw=0
" vim: fdm=marker et

