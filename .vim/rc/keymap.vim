" .vim/rc/keymap.vim
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-17

let s:save_cpo = &cpo
set cpo&vim

noremap ; :
noremap : ;
nnoremap q; q:

noremap  <F1> <NOP>
noremap! <F1> <NOP>

nnoremap q    <NOP>
nnoremap Q    <NOP>

nnoremap j gj
nnoremap k gk

nnoremap ) t)
nnoremap ( t(

" <C-h> is defined by ~/.vim/rc/bundle/unite.vim
silent! nnoremap <unique> <C-h> :help<Space>

nnoremap Y  y$
nnoremap dl 0d$

nnoremap -- mzgg=G`z

" nnoremap / :set hlsearch<CR>/
" nnoremap * :set hlsearch<CR>*
nnoremap <Space>/ :set hlsearch! \| set hlsearch?<CR>

nnoremap <F1> <NOP>

" fold を展開して，画面の中央にする
nnoremap gg ggzvzz
nnoremap n  nzvzz
nnoremap N  Nzvzz

" nnoremap + <C-A>
" nnoremap - <C-X>

nnoremap <Space>p :set paste!    \| :set paste?<CR>
nnoremap <Space>h :set readonly! \| :set readonly?<CR>

" See also: http://vim-jp.org/vim-users-jp/2009/08/25/Hack-62.html
nnoremap <expr> s* ':%s/\<'.expand('<cword>').'\>/'
nnoremap <expr> s* ':%s/\<'.expand('<cword>').'\>/'

nnoremap <Space>m :marks<CR>
nnoremap <Space>r :registers<CR>

" nnoremap <C-C> "+y
" nnoremap <C-V> "+p

nmap <Space>w <C-W>

nnoremap <Space>tj gt
nnoremap <Space>tk gT

nnoremap <expr> gf ':split ' . expand("<cfile>") . "\<CR>"
"nnoremap <expr> gf ':split ' . <SID>get_current_fname() . "\<CR>"

"function! s:get_current_fname() abort "{{{
"  let col   = col('.')
"  let line  = getline('.')
"  let lline = matchstr(strpart(line, 0, col), '\f\+$')
"  let rline = matchstr(strpart(line, col),  '^\f\+')
"  let fname = lline . rline
"  return fname
"endfunction "}}}

for s:i in range(0,9)
  execute printf("nnoremap <Space>t%d %dgt", s:i, s:i+1)
endfor
unlet s:i


" NOTE: text object を殺してしまう
" vnoremap i I
" vnoremap a A

" emacs like keybind for cmdline
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" NOTE: <Esc> を使わないキーバインドにしたい
" cnoremap <C-[><C-B> <S-Left>
" cnoremap <C-[><C-F> <S-Right>
" cnoremap <C-[><C-[> <Esc>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

cnoremap <expr> <C-]> expand('<cword>')

" cnoremap <expr> /     getcmdtype() == '/' ? '\/' : '/'
" cnoremap <expr> \     getcmdtype() == '/' ? '\\' : '\'
" cnoremap <expr> [     getcmdtype() == '/' ? '\[' : '['
" cnoremap <expr> <CR>  getcmdtype() == '/' ? "\<CR>zvzz" : "\<CR>"
cnoremap <expr> / <SID>MyCmdLineWrapper('/', '\/', '/')
cnoremap <expr> \ <SID>MyCmdLineWrapper('\', '\\', '\\')
cnoremap <expr> [ <SID>MyCmdLineWrapper('[', '\[', '\[')
cnoremap <expr> < <SID>MyCmdLineWrapper('<', '\<', '\<')
cnoremap <expr> > <SID>MyCmdLineWrapper('>', '\>', '\>')
cnoremap <expr> <CR> <SID>MyCmdLineWrapper("\<CR>", "\<CR>zvzz", "\<CR>")

function! s:MyCmdLineWrapper(...) abort "{{{
  if getcmdtype() =~ '[/?]'
    return a:2
  elseif getcmdline() =~? '\<s\(ubstitute\)\?/'
    return a:3
  else
    return a:1
  endif
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=2 sts=2 et fdm=marker

