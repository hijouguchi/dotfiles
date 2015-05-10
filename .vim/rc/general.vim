" .vim/rc/keymap.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-26

let s:save_cpo = &cpo
set cpo&vim

set t_Co=256
set visualbell
set t_vb=
set noerrorbells
set number
set list
set listchars=tab:\ \ ,trail:_,eol:.
set completeopt=menuone,preview
set matchpairs& matchpairs+=<:>

set showmatch
set matchtime=1

set autoindent
set cindent
set complete=.,w,b,u,t,k
set backspace=indent,eol,start

set history=1000

set display=lastline
set shortmess& shortmess+=I

if has('win32') || has('win32unix')
  set directory=$TEMP
else
  set directory=/tmp
endif
let &undodir = &directory

set swapfile
set noundofile
set nobackup
set nowritebackup


set helplang=ja,en

set incsearch
set ignorecase
set smartcase
set wrapscan

set scrolloff=3

set foldmethod=marker
set foldopen=hor,insert,mark,percent,quickfix,undo

set showcmd
set noshowmode

set wildmenu
set wildchar=<tab>
set wildmode=longest,full

set tabstop=2
set shiftwidth=2
set softtabstop=0

set pumheight=15

set laststatus=2
set statusline=%{MyStatusLine(1)}

let s:mode = {
      \ "n"      : "NORMAL",
      \ "v"      : "VISUAL",
      \ "V"      : "VISUAL LINE",
      \ "\<C-V>" : "VISUAL BLOCK",
      \ "i"      : "INSERT",
      \ "R"      : "REPLACE",
      \ "c"      : "COMMAND",
      \ "?"      : "??????"
      \ }

function! MyStatusLine(enter) abort "{{{
  let nr = bufnr('%')
  let s = ''
  if a:enter
    let s = printf(' %%{MyStatusLineMode(%d)} ', nr)
  endif
  let s = s . '%<%f'
  let s = s . printf(' %%{MyStatusLineModified(%d)}', nr)
  let s = s . '%='
  let s = s . printf(' %%{MyStatusLineFileType(%d)}', nr)
  let s = s . ' %2cC,%l/%LL %p%%'
  let &l:statusline = s
endfunction "}}}

function! MyStatusLineMode(nr) "{{{
  let s = get(s:mode, mode(), s:mode['?'])
  if getbufvar(a:nr, '&paste') | let s = s . ',PASTE' | endif
  return s
endfunction "}}}

function! MyStatusLineFileType(nr) "{{{
  let ft   = getbufvar(a:nr, '&l:filetype')
  let fenc = getbufvar(a:nr, '&l:fileencoding')
  let ff   = getbufvar(a:nr, '&l:fileformat')

  let s = '['
  if ft != '' | let s = s . ft . ',' | endif
  let s = s . (fenc != '' ? fenc : &encoding) . ','
  let s = s . ff . ']'
  return s
endfunction "}}}

function! MyStatusLineModified(nr) "{{{
  let l = []
  if  getbufvar(a:nr, "&readonly")   | call add(l, 'RO') | endif
  if !getbufvar(a:nr, "&modifiable") | call add(l, '-')  | endif
  if  getbufvar(a:nr, "&modified")   | call add(l, '+')  | endif

  if empty(l)
    return ''
  else
    return '[' . join(l, ',') . ']'
  endif
endfunction "}}}

augroup MyStatusLine "{{{
  autocmd!

  autocmd! WinEnter * call MyStatusLine(1)
  autocmd! WinLeave * call MyStatusLine(0)
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker
