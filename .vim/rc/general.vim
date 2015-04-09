
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
set showmode

set wildmenu
set wildchar=<tab>
set wildmode=list:longest,full

set tabstop=2
set shiftwidth=2
set softtabstop=0

set pumheight=15

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

" vim: ts=2 sw=2 sts=2 et fdm=marker
