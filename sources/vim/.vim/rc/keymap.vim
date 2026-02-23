" vim: ts=2 sw=2 sts=2 et fdm=marker

KMapNoremap ; :
KMapNoremap : ;
KMapNNoremap q; q:

KMapNoremap  <F1> <NOP>
KMapNoremap! <F1> <NOP>

KMapNNoremap q    <NOP>
KMapNNoremap Q    <NOP>

KMapNNoremap j gj
KMapNNoremap k gk

KMapNNoremap ) t)
KMapNNoremap ( t(

KMapNNoremap <Space>tj <C-W>:tabnext<CR>
KMapNNoremap <Space>tk <C-W>:tabprev<CR>

KMapNoremap qo :<C-U>copen<CR>
KMapNoremap qq :<C-U>cclose<CR>

" <C-h> is defined by ~/.vim/rc/bundle/unite.vim
silent! KMapNNoremap <unique> <C-h> :help<Space>

KMapNNoremap Y  y$
KMapNNoremap dl 0d$

KMapNNoremap -- mzgg=G`z

KMapNNoremap / :set hlsearch<CR>/
"KMapNNoremap * :set hlsearch<CR>*
KMapNNoremap <Space>/ :set hlsearch! \| set hlsearch?<CR>

KMapNNoremap <F1> <NOP>

" fold を展開して，画面の中央にする
KMapNNoremap gg ggzvzz
KMapNNoremap n  nzvzz
KMapNNoremap N  Nzvzz

" KMapNNoremap + <C-A>
" KMapNNoremap - <C-X>

KMapNNoremap <Space>p :set paste!    \| :set paste?<CR>
KMapNNoremap <Space>h :set readonly! \| :set readonly?<CR>

KMapNNoremap <Space>m :marks<CR>
KMapNNoremap <Space>r :registers<CR>

KMapNMap <Space>w <C-W>

let s:str = "KMapNNoremap <Space>t%d %dgt"
for s:i in range(0,9)
  execute printf(s:str, s:i, s:i+1)
endfor
unlet s:i


" emacs like keybind for cmdline
KMapCNoremap <C-B> <Left>
KMapCNoremap <C-F> <Right>
KMapCNoremap <C-A> <Home>
KMapCNoremap <C-E> <End>

KMapCNoremap <C-P> <Up>
KMapCNoremap <C-N> <Down>

KMapCNoremap <expr> <C-]> expand('<cword>')

KMapTMap     <C-T>     <C-W>
KMapTMap     <C-W>;    <C-W>:

KMapTNoremap <C-W><C-V> <C-W>N

KMapTNoremap <Space>wh <C-W>h
KMapTNoremap <Space>wj <C-W>j
KMapTNoremap <Space>wk <C-W>k
KMapTNoremap <Space>wl <C-W>l

KMapTNoremap <Space>tj <C-W>:tabnext<CR>
KMapTNoremap <Space>tk <C-W>:tabprev<CR>


KMapCNoremap <expr> <CR> cmdline#enter_by_cmdtype("\<CR>", "\<CR>zvzz", "\<CR>")

KMapTNoremap <C-W>p    <C-W>:call term_sendkeys(bufnr('%'), getreg())<CR>
