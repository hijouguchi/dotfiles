" vim: ts=2 sw=2 sts=2 et fdm=marker

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

nnoremap <Space>tj <C-W>:tabnext<CR>
nnoremap <Space>tk <C-W>:tabprev<CR>

noremap qo :<C-U>copen<CR>
noremap qq :<C-U>cclose<CR>

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
"nnoremap <expr> s* ':%s/\<'.expand('<cword>').'\>/'

nnoremap <Space>m :marks<CR>
nnoremap <Space>r :registers<CR>

nmap <Space>w <C-W>

let s:str = "nnoremap <Space>t%d %dgt"
for s:i in range(0,9)
  execute printf(s:str, s:i, s:i+1)
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
"cnoremap <expr> / <SID>MyCmdLineWrapper('/', '\/', '/')
"cnoremap <expr> \ <SID>MyCmdLineWrapper('\', '\\', '\\')
"cnoremap <expr> [ <SID>MyCmdLineWrapper('[', '\[', '\[')
"cnoremap <expr> < <SID>MyCmdLineWrapper('<', '\<', '\<')
"cnoremap <expr> > <SID>MyCmdLineWrapper('>', '\>', '\>')
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


tmap     <C-T>     <C-W>
tmap     <C-W>;    <C-W>:

tnoremap <C-W><C-V> <C-W>N

tnoremap <Space>wh <C-W>h
tnoremap <Space>wj <C-W>j
tnoremap <Space>wk <C-W>k
tnoremap <Space>wl <C-W>l

tnoremap <Space>tj <C-W>:tabnext<CR>
tnoremap <Space>tk <C-W>:tabprev<CR>

tnoremap <C-W>p    <C-W>:call term_sendkeys(bufnr('%'), getreg())<CR>

