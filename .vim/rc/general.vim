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
set clipboard=unnamed
set incsearch

set showmatch
set matchtime=1

set autoindent
set cindent
set cinoptions& cinoptions+=l1,E-s,t0,(0,Ws
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

"set diffopt& diffopt+=iwhite

set pumheight=15

set laststatus=2

if executable('ag')
  set grepprg=ag\ --vimgrep
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et fdm=marker

