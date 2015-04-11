
set t_Co=256
set visualbell
set t_vb=
set noerrorbells
set number
set list
set listchars=tab:\ \ ,trail:_,eol:.
set completeopt=menuone,preview
set matchpairs& matchpairs+=<:>

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

set foldmethod=marker
set foldopen=hor,insert,mark,percent,quickfix,undo

set showcmd
set noshowmode

set wildmenu
set wildchar=<tab>
set wildmode=list:longest,full

set tabstop=2
set shiftwidth=2
set softtabstop=0

set pumheight=15

set laststatus=2
set statusline=%{MyStatusLineEnter()}

let s:mode = {
      \ "n"      : "NORMAL",
      \ "v"      : "VISUAL",
      \ "V"      : "VISUAL LINE",
      \ "\<C-V>" : "VISUAL BLOCK",
      \ "i"      : "INSERT",
      \ "R"      : "REPLACE",
      \ "?"      : "??????"
      \ }

function! MyStatusLineEnter() "{{{
  let nr = bufnr('%')
  let s = printf(' %%{MyStatusLineMode(%d)}', nr)
  let s = s . ' %<%f'
  let s = s . printf(' %%{MyStatusLineModified(%d)}', nr)
  let s = s . '%='
  let s = s . printf(' %%{MyStatusLineFileType(%d)}', nr)
  let s = s . ' %cC,%l/%LL %P'
  let &l:statusline = s
endfunction "}}}

function! MyStatusLineLeave() "{{{
  let nr = bufnr('%')
  let s = '%<%f'
  let s = s . printf(' %%{MyStatusLineModified(%d)}', nr)
  let s = s . '%='
  let s = s . printf(' %%{MyStatusLineFileType(%d)}', nr)
  let s = s . ' %cC,%l/%LL %P'
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
  if ft | let s = s . ft . ',' | endif
  let s = s . (fenc ? fenc : &encoding) . ','
  let s = s . ff . ']'
  return s
endfunction "}}}

function! MyStatusLineModified(nr) "{{{
  if getbufvar(a:nr, "&modified")
    return '+'
  elseif !getbufvar(a:nr, "&modifiable")
    return '-'
  else
    return ''
  endif
endfunction "}}}

augroup MyStatusLine "{{{
  autocmd!

  autocmd! WinEnter * call MyStatusLineEnter()
  autocmd! WinLeave * call MyStatusLineLeave()
augroup END "}}}


" vim: ts=2 sw=2 sts=2 et fdm=marker
