" NOTE {{{1


"Basic "{{{1
"initialize "{{{2
set nocompatible

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

" path "{{{2

silent! helptags ~/.vim/doc


"Options "{{{2

syntax enable
set background=dark

filetype plugin indent on

set cinoptions=:0,t0,(0,W1s
set noequalalways
set wildmenu
set wildchar=<tab>
set wildmode=list:longest,full
set noimcmdline

set autoindent
set number
set backspace=indent,eol,start
set matchpairs+=<:>
set nohlsearch
set nrformats+=alpha
set smartindent
set iminsert=1
set imsearch=1
set noerrorbells
set modeline
set foldmethod=marker

set completeopt=menuone,preview

"search option
set incsearch
set ignorecase
set smartcase
set wrapscan

set autowrite

set nowritebackup

"set complete=.,w,b,u,t,i,d,k
set complete=.,w,b,u,t,k

set backup
set backupext=.bak
if has("mac")
  set backupdir=~/.Trash
else
  set backupdir=/tmp
endif

set formatoptions=nlM1

set shiftwidth=2
set tabstop=2
set softtabstop=2
" NOTE:you should write each edit file
"set expandtab
"set smarttab


"fileencodings {{{2


"if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
"  let s:enc_euc = 'euc-jisx0213,euc-jp'
"  let s:enc_jis = 'iso-2022-jp-3'
"else
"  let s:enc_euc = 'euc-jp'
"  let s:enc_jis = 'iso-2022-jp'
"endif
"
"let &fileencodings = 'ucs-bom'
"
"let &fileencodings .= ',' . s:enc_jis
"let &fileencodings .= ',' . s:enc_euc
"let &fileencodings .= ',' . 'cp932'
"let &fileencodings .= ',' . &encoding


"unlet s:enc_euc
"unlet s:enc_jis

if &encoding ==# 'utf-8'
  set fileencodings=euc-jp,utf-8,cp932
elseif &encoding ==# 'euc-jp'
  set fileencodings=utf-8,cp932,euc-jp
endif

set fileformats=unix,dos,mac
set ambiwidth=double

"{{{2 Window

"colorscheme candycode
" color "{{{
set t_Co=256
colorscheme desert
highlight Pmenu cterm=underline ctermbg=8
highlight PmenuSel ctermbg=7 ctermfg=0
highlight PmenuSbar ctermbg=0

"highlight Folded cterm=bold ctermbg=4 ctermfg=7
highlight Folded cterm=bold ctermbg=7 ctermfg=4
" }}}

set listchars=eol:.,tab:._,trail:_
set list
set showcmd
set showmode



set laststatus=2
set statusline=%<%f%=
set statusline+=%{MyStatusSpec()}
set statusline+=\ %3cC,%3l/%LL\ %P

function! MyStatusSpec()
  let l = []
  if &paste | call add(l, 'paste') | endif
  if &modified | call add(l, '+') | endif
  if !&modifiable | call add(l, '-') | endif
  if len(&filetype)>0 | call add(l, &filetype) | endif
  call add(l, len(&fenc)>0?&fenc:&enc)
  call add(l, &fileformat)
  return '[' . join(l, ',') . ']'
endfunction

set tabline=%!MyTabLine()
"set showtabline=2


"key mapping "{{{1
"Nmap {{{2
nmap     <Space>          [Space]
nnoremap [Space]          <Nop>

nnoremap ,w               :up!<CR>

nnoremap j                gj
nnoremap k                gk
nnoremap gg               ggzvzz

nnoremap dl               0d$
nnoremap dL               ^d$
nnoremap Y                y$

nnoremap zo               zv
nnoremap zv               zo

nnoremap --               mzgg=G`z


nnoremap ;                :
nnoremap :                ;

nnoremap <C-P>            :set paste! \| :set paste?<CR>

nnoremap <C-H>            :<C-u>help<Space>

nnoremap [Space]e         :<C-u>!time ./%<CR>


"Imap {{{2
inoremap                 <C-]>         <C-O>:
inoremap                 <Tab>         <C-R>=InsertTabWrapper()<CR>
inoremap          <expr> <Esc>[Z       pumvisible() ? "<C-P>" : "<S-Tab>"
inoremap                 <C-U>         <C-G>u<C-U>
inoremap                 <C-W>         <C-G>u<C-W>
inoremap          <expr> <C-Y>         neocomplcache#close_popup()
inoremap          <expr> <C-E>         neocomplcache#cancel_popup()
inoremap          <expr> <CR>          pumvisible() ? "<C-Y><CR>" : "<CR>"

" for Neocomplcache
imap                     <C-k>         <Plug>(neocomplcache_snippets_expand)
smap                     <C-k>         <Plug>(neocomplcache_snippets_expand)


"Vmap {{{2
vnoremap ;     :
vnoremap :     ;


"Cmap {{{2
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" respected from kana
" Search slashes easily (too lazy to prefix backslashes to slashes)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> \  getcmdtype() == '/' ? '\\' : '\'

" window move {{{2
nmap      [Space]w    <C-W>
nnoremap  <C-w>a      <C-R>:all<Return>


" buffer move {{{2
nmap     [Space]b  [Buffer]
nnoremap [Buffer]  <Nop>

nnoremap [Buffer]j :bn<Cr>
nnoremap [Buffer]n :bn<Cr>

nnoremap [Buffer]k :bp<Cr>
nnoremap [Buffer]p :bp<Cr>


" they are the same behavior
nnoremap [Buffer]b :buffers<CR>
nnoremap [Buffer]l :ls<CR>


" tab    move {{{2
nmap     [Space]t  [Tab]
nnoremap [Tab]j :tabn<CR>
nnoremap [Tab]k :tabp<CR>
nnoremap [Tab]n :tabnew<CR>

"for tab number
for i in range(0,9)
  execute 'nnoremap [Tab]' . i . ' :tabnext '. (i+1) . '<CR>'
endfor


" search jump {{{2
"nnoremap * mz*

nnoremap /        :setlocal hlsearch<CR>/
nnoremap [Space]/ :set hlsearch! \| :set hlsearch?<CR>

"jump, open fold, and cursor to the center
nnoremap n      nzvzz
nnoremap N      Nzvzz
nnoremap *      :setlocal hlsearch<CR>*zvzz
nnoremap #      #zvzz
nnoremap g*     g*zvzz
nnoremap g#     g#zvzz


" tag    jamp {{{2
nnoremap          tt      <C-]>zz
nnoremap          th      <C-T>zz
nnoremap          tl     :<C-U>tags<CR>


" Quickfix {{{2
nnoremap q     <Nop>
nnoremap Q     q

nnoremap qm   :<C-U>make<CR>

nnoremap qj   :<C-U>cnext<CR>
nnoremap qk   :<C-U>cprevious<CR>
nnoremap qfj  :<C-U>cfirst<CR>
nnoremap qfk  :<C-U>clast<CR>
nnoremap ql   :<C-U>clist<CR>
nnoremap qo   :<C-U>copen 3<CR>
nnoremap qq   :<C-U>cclose<CR>


" Ku {{{2
nmap     [Space]k         [Ku]
nnoremap [Ku]f            :<C-U>Ku file<return>
nnoremap [Ku]b            :<C-U>Ku buffer<return>


" No Use cursor-keys "{{{2
map   <Up>     <nop>
map   <Down>   <nop>
map   <Left>   <nop>
map   <Right>  <nop>
map!  <Up>     <nop>
map!  <Down>   <nop>
map!  <Left>   <nop>
map!  <Right>  <nop>


" command {{{1
command! -nargs=0 ToggleListNumber
      \ :setlocal list! | :setlocal number!

command! -nargs=0 TabToSpace
      \ :setlocal expandtab | :setlocal smarttab |  :set expandtab?

command! -nargs=0 SpaceToTab
      \ :setlocal noexpandtab | :setlocal nosmarttab |  :set expandtab?

command! -nargs=0 ToggleCharactorChange
      \ normal vb~w

command! InsertEnv call <SID>Insert_env()

command! InsertCoding call <SID>Insert_coding()

" change a character code {{{2
command! -bang DefaultLocale e<bang> ++enc=utf-8 ++ff=unix
command! -bang Utf8   e<bang> ++enc=utf-8
command! -bang Euc    e<bang> ++enc=euc-jp
command! -bang Cp932  e<bang> ++enc=cp932
command! -bang Jis    e<bang> ++enc=iso-2022-jp

command! -bang Unix   e<bang> ++ff=unix
command! -bang Mac    e<bang> ++ff=mac
command! -bang Dos    e<bang> ++ff=dos


" autocmd {{{1
augroup MyAutoCmd
  autocmd!

  autocmd BufNewFile,BufRead .vimrc
        \ nnoremap <buffer> ,s :<c-u>source ~/.vimrc<cr>

  autocmd BufWritePost * if getline(1) =~ "^#!" |
        \ silent! exe "silent !chmod +x %" | endif

  autocmd QuickfixCmdPost make,grep,vimgrep copen 3

  " if the file doesn't have used Japanese, set fileencoding to utf-8
  " from kana's vimrc http://github.com/kana/config/
  autocmd BufReadPost *
        \   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
        \ |   setlocal fileencoding=utf-8
        \ | endif

  " if the file doesn't have used tab by space, set expandtab
  autocmd BufReadPost *
        \   if search('^\t', 'cnw') == 0
        \ |   setlocal expandtab
        \ | endif

  autocmd FileType  *
        \   if &l:omnifunc == ''
        \ | setlocal omnifunc=syntaxcomplete#Complete
        \ | endif

  " set each filetype dictionary
  autocmd Filetype *
        \   if &filetype !=# '' && findfile(&filetype . ".dict", $HOME . "/.vim/dict") !=# ''
        \ |   execute "setlocal dictionary=" . findfile(&filetype . ".dict", $HOME . "/.vim/dict")
        \ | endif

  "" ruby syntax check
  "" http://vim-users.jp/2009/05/hack13/
  "autocmd BufWrite *.rb !ruby -c %
augroup END


" set binary format
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin let &binary = 1
  autocmd BufReadPost  * if &binary | silent %!xxd -g 1
  autocmd BufReadPost  * set ft=xxd | endif
  autocmd BufWritePre  * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END



"setteing each filetype {{{2
" NOTE: here is only for small settings
augroup FiletypeAutoCmd
  autocmd!
augroup END

" help {{{3
autocmd FiletypeAutoCmd FileType help setlocal nolist | setlocal number


" html {{{3
autocmd FiletypeAutoCmd BufNewFile *.htm,*.html 0r ~/.vim/template/html.html


" C {{{3
autocmd! FiletypeAutoCmd FileType c call <SID>FileType_c()
function! s:FileType_c()
  inoremap <expr> = smartchr#one_of(' = ', ' == ', '=')
endfunction

" Quickfix {{{3
autocmd FiletypeAutoCmd FileType qf call <SID>FileType_qf()
function! s:FileType_qf()
  nnoremap <buffer> <expr> qc   ":\<C-U>cc " . line('.') ."\<CR>"
endfunction


" sh {{{3
autocmd FiletypeAutoCmd FileType sh call <SID>FileType_sh()
function! s:FileType_sh()
  nnoremap <buffer> [Space]e :!./%<CR>
endfunction


" scheme {{{3
autocmd FiletypeAutoCmd FileType scheme call <SID>FileType_scheme()
function! s:FileType_scheme()
  nnoremap <buffer> [Space]e :!gosh %<CR>
endfunction


" R {{{3
autocmd FiletypeAutoCmd FileType r call <SID>FileType_R()
"set filetype R for .r (not set to rexx)
autocmd FiletypeAutoCmd BufNewFile,BufEnter *.r,*.R setlocal filetype=r
function! s:FileType_R()
  nnoremap <buffer> [Space]e :<c-u>!Rscript %<CR>
endfunction

" Ruby {{{3
autocmd FiletypeAutoCmd FileType ruby call <SID>FileType_ruby()
function! s:FileType_ruby()
  "setlocal omnifunc=rubycomplete#Complete
  set expandtab
  set smarttab
  compiler ruby
  setlocal makeprg=ruby\ -c\ %
  nnoremap <buffer> [Space]e :<c-u>!time ruby %<cr>
  nnoremap <buffer> [Space]s :<c-u>!ruby -c %<cr>
endfunction


" Tex {{{3
autocmd FiletypeAutoCmd FileType plaintex setlocal filetype=tex
autocmd FiletypeAutoCmd FileType tex call <SID>FileType_tex()
" if tex file is saved, auto rake
autocmd FiletypeAutoCmd BufWritePost *.tex silent! execute "silent !rake >/dev/null 2>&1"
function! s:FileType_tex()
  setlocal complete+=k~/.vim/dict/tex.dict
endfunction


" verilog {{{3
autocmd FiletypeAutoCmd FileType verilog call <SID>FileType_verilog()
function! s:FileType_verilog()
  command! -buffer -nargs=+ VerilogInsertCaseList call <SID>VerilogInsertCaseList(<f-args>)
endfunction

function! s:VerilogInsertCaseList(l_num, r_num, name) " {{{4
  let l:pat = '^\(\d\+\)$'
  let l:pat_with_type = '^\(\d\+\)\([bodh]\)$'
  if(a:l_num =~? l:pat && a:r_num =~? l:pat_with_type)
    let l:l_bit = float2nr(ceil(str2nr(a:l_num)/4.0))

    let l:r_num_type = matchlist(a:r_num, l:pat_with_type)
    let l:r_type = l:r_num_type[2]
    let l:r_num = l:r_num_type[1]
    if(l:r_type ==? 'b')
      let l:r_bit = str2nr(l:r_num_type[1])
    elseif(l:r_type ==? 'o')
      let l:r_bit = float2nr(ceil(str2nr(l:r_num_type[1])/3.0))
    elseif(l:r_type ==? 'd')
      let l:r_bit = 0
    else " h
      let l:r_bit = float2nr(ceil(str2nr(l:r_num_type[1])/4.0))
    endif

    let l:lab_len = strlen(a:l_num) + 2 + l:l_bit
    let l:def_len = strlen('default')
    let l:lab_rep = (l:def_len > l:lab_len) ? l:def_len - l:lab_len : 0
    let l:def_rep = (l:def_len > l:lab_len) ? 0 : l:lab_len - l:def_len

    if(&l:expandtab)
      let l:indent = repeat(' ', indent('.')) " expandtab
    else
      let l:indent = repeat("\t", indent('.') / &l:tabstop) " noexpandtab
    endif

    let l:format = a:l_num . "'h%0" . l:l_bit . 'x:'

    let l:size = float2nr(pow(2, str2nr(a:l_num)))
    let l:i    = 0
    let l:list = []

    while(l:i < l:size)
      let l:str = l:indent . printf(l:format, l:i) .
            \ repeat(' ', l:lab_rep) . ' ' . a:name . ' = ' . l:r_num . "'" . l:r_type
      call add(l:list, l:str)
      let l:i += 1
    endwhile

    let l:str = l:indent . 'default:' . repeat(' ', l:def_rep) .
          \ ' ' . a:name . ' = ' . l:r_num . "'" . l:r_type . repeat('x', l:r_bit) . ';'
    call add(l:list, l:str)

    call append(line('.'), l:list)
  endif
endfunction


" vim {{{3
autocmd FiletypeAutoCmd FileType vim call <SID>FileType_vim()
function! s:FileType_vim()
  setlocal keywordprg=:help
  nnoremap <buffer> [Space]e :<c-u>source %<CR>
  nnoremap <buffer> [Space]s :<c-u>source $MYVIMRC<CR>
endfunction


" vhdl {{{3
autocmd FiletypeAutoCmd BufNewFile *.vhd 0r ~/.vim/template/vhdl.vhd


" screen {{{3
autocmd FiletypeAutoCmd FileType screen
      \ nnoremap <buffer> ,s :<C-U>!screen -X source %<CR>


" plugin options {{{1
" Neocomplcache {{{2
let g:neocomplcache_enable_at_startup            = 1
let g:neocomplcache_auto_completion_start_length = 5
let g:neocomplcache_max_list                     = 25
let g:neocomplcache_enable_auto_delimiter        = 1
let g:neocomplcache_enable_caching_message       = 0
let g:neocomplcache_temporary_dir                = '/var/tmp/neocon'


" Ku {{{2
autocmd MyAutoCmd FileType ku call Ku_options()

function! Ku_options()
  call ku#default_key_mappings(1)
  inoremap <buffer> <expr> <Tab>         InsertTabWrapper()
  "It dosen't work if inoremap
  imap     <buffer>        <C-U>         <Plug>(ku-choose-an-action)
endfunction


" submode {{{2
" sovle ^W < - + > ...
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


"functions "{{{1
" Resist to dictionary {{{2
" Basic {{{3
let g:throw_dictionary = '~/.vim/dict/throw_dictionary.dict'
execute "set complete+=k" . g:throw_dictionary


" command {{{3
command! -nargs=* ResistDictionary call <SID>Throw_dictionary(<q-args>)
command! -nargs=0 ToggleResistDictionary call <SID>Throw_dictionary_Toggle()


" key mappings {{{3
vnoremap td :<C-U>call <SID>Range_throw()<CR>


function! s:Throw_dictionary(words) "{{{3
  let l:words = split(a:words, ' ')

  if len(l:words) == 0
    return ""
  endif

  execute "split " . &dictionary

  for l:word in l:words

    for l:i in range(1, line('$'))
      if getline(l:i) == l:word
        silent! close
        silent! execute "bdelete " . &dictionary
        return ""
      endif
    endfor

    let @z = l:word . "\n"
    normal G"zp
    sort

    if getline(1) == ""
      normal ggdd
    endif

  endfor

  silent! up
  silent! close
  execute "silent! bdelete " . &dictionary
endfunction


function! s:Throw_dictionary_Toggle() "{{{3
  if (&complete =~ '\V' . g:throw_dictionary)
    execute "setlocal complete-=k" . g:throw_dictionary
  else
    execute "setlocal complete+=k" . g:throw_dictionary
  endif
endfunction


function! MyTabLine() "{{{2
  "NOTE: it's not script local function
  let s = ""
  for i in range(1, tabpagenr('$'))
    let title_number = tabpagebuflist(i)[0]
    let no = i - 1
    let mod = getbufvar(title_number, "&modified") ? "+" : " "
    let title = fnamemodify(bufname(title_number), ":t")
    let title = len(title) ? title : "[No Name]"

    let s .= "%" . i . "T"
    let s .= "%#" . (i == tabpagenr() ? "TablineSel" : "Tabline") . "# "
    let s .= no . mod . title
    let s .= " %#TablineFill#%T"
    let s .= ""
  endfor

  let s .= "%="
  let s .= getcwd()
  return s
endfunction


function! InsertTabWrapper() "{{{2
  if pumvisible()
    return "\<C-N>"
  elseif getline('.')[col('.')-2] =~ '\k'
    call neocomplcache#start_manual_complete()
    return "\<C-N>"
  else
    return "\<TAB>"
  endif
endfunction


function! s:Insert_env() "{{{2
  let l:env = system("which env")
  if l:env == ''
    throw "Can't find env"
  endif
  " delete backspace
  if l:env =~ '\r$\|\n$'
    let l:env = l:env[:-2]
  endif
  let @z = "\#!" . l:env . " " . &filetype . "\n"
  normal mzgg"zP'z
endfunction


function! s:Insert_coding() "{{{2
  let l:fenc = &fileencoding
  if l:fenc == ''
    let l:fenc = 'utf-8'
  endif
  let @z = "# coding: " . l:fenc . "\n"
  if getline(1) =~ '^#!'
    normal mzgg"zp'z
  else
    normal mzgg"zP'z
  endif
endfunction


" __END__ {{{1
" vim: expandtab


