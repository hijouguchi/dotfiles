let s:save_cpo = &cpo
set cpo&vim

if g:cachedir
  set viminfo&
  let &viminfo .= ',n' . g:cachedir . '/.viminfo'
endif

set t_Co=256
set visualbell
set t_vb=
set noerrorbells
set number
set nolist
"set listchars=tab:\ \ ,trail:_,eol:.
set listchars=tab:._,trail:_,eol:.
set completeopt=menuone,preview
set matchpairs& matchpairs+=<:>

set showmatch
set matchtime=1

set autoindent
set cindent
set complete=.,w,b,u,t,k
set backspace=indent,eol,start

set isfname& isfname-=,

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
set nowrap

set scrolloff=3

set foldmethod=marker
set foldopen=hor,insert,mark,percent,quickfix,undo

set showcmd
set noshowmode

set wildmenu
set wildchar=<tab>
set wildmode=longest,full

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

set diffopt& diffopt+=iwhite

set pumheight=15

set laststatus=2
" MEMO: 複数の引数が取れない (設定値が複数として見えてしまう)
" FIXME: たまに表示がバグるので確認する事

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

function! MyStatusLine(arg) abort "{{{
  let nr = bufnr('%')
  let s = ''
  if and(a:arg, 1) == 1
    let s = printf(' %%{MyStatusLineMode(%d)} ', nr)
  endif
  let s = s . '%<%f'
  let t = printf('%%{MyStatusLineModified(%d)}', nr)
  if t != ''
    let s = s . ' %1*' . t . '%* '
  endif
  let s = s . '%='
  let s = s . printf(' %%{MyStatusLineFileType(%d)}', nr)
  let s = s . ' %2cC,%l/%LL %p%%'

  if and(a:arg, 2) == 2
    let &l:statusline = s
  endif
  return s
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

  autocmd! BufWinEnter,WinEnter * call MyStatusLine(3)
  autocmd! WinLeave             * call MyStatusLine(2)
  autocmd! ColorScheme          * hi def link User1 Error
augroup END "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

