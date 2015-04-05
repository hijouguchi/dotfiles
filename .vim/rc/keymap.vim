noremap ; :
noremap : ;

noremap  <F1> <NOP>
noremap! <F1> <NOP>

nnoremap q    <NOP>
nnoremap Q    <NOP>

nnoremap j gj
nnoremap k gk

nnoremap ) t)
nnoremap ( t(

nnoremap <C-H> :help<Space>

nnoremap Y  y$
nnoremap dl 0d$

nnoremap -- mzgg=G`z

nnoremap / :set hlsearch<CR>/
nnoremap * :set hlsearch<CR>*
nnoremap <Space>/ :set hlsearch! \| set hlsearch?<CR>

nnoremap <F1> <NOP>

" require itchyny/thumbnail.vim
nnoremap <Space>b :Thumbnail -here<CR>

" MEMO: quickrun に変更
" execute 'nnoremap <Space>e :!' . expand('%:p') . '<CR>'

" fold を展開して，画面の中央にする
nnoremap gg ggzvzz
nnoremap n  nzvzz
nnoremap N  Nzvzz

nnoremap + <C-A>
nnoremap - <C-X>

nnoremap <Space>p :set paste!    \| :set paste?<CR>
nnoremap <Space>h :set readonly! \| :set readonly?<CR>

nnoremap <Space>m :marks<CR>
nnoremap <Space>r :registers<CR>

" nnoremap <C-C> "+y
" nnoremap <C-V> "+p

nmap <Space>w <C-W>


vnoremap i I
vnoremap a A

cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

cnoremap <expr> /     getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> \     getcmdtype() == '/' ? '\\' : '\'
cnoremap <expr> [     getcmdtype() == '/' ? '\[' : '['
cnoremap <expr> <CR>  getcmdtype() == '/' ? "\<CR>zvzz" : "\<CR>"

" vim: ts=2 sw=2 sts=2 et
