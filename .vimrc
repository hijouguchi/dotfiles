" .vimrc
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015-04-11

set encoding=utf-8
scriptencoding utf-8

" for Neobundle
if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'

if !has('win32') && !has('win32unix')
  NeoBundle 'Shougo/vimproc.vim', {
        \ 'build' : {
        \   'mac'   : 'make -f make_mac.mak',
        \   'linux' : 'make'
        \   }
        \ }
endif
NeoBundle 'vim-jp/vimdoc-ja.git'
NeoBundle 'vim-scripts/Align'
NeoBundle 'vim-scripts/desert256.vim'
NeoBundle 'itchyny/landscape.vim'
" NeoBundle 'https://github.com/LeafCage/foldCC.git'
NeoBundleLazy 'itchyny/thumbnail.vim', {'commands' : 'Thumbnail'} " depened by rc/keymap.vim

source ~/.vim/rc/bundle/surround.vim
source ~/.vim/rc/bundle/vim-submode.vim
source ~/.vim/rc/bundle/vim-textobj.vim
source ~/.vim/rc/bundle/vim-smartinput.vim
source ~/.vim/rc/bundle/neocomplete.vim
source ~/.vim/rc/bundle/vim-template.vim
source ~/.vim/rc/bundle/vim-quickrun.vim
" source ~/.vim/rc/bundle/lightline.vim

runtime macros/matchit.vim

call neobundle#end()

filetype plugin indent on
syntax enable
NeoBundleCheck


source ~/.vim/rc/general.vim
source ~/.vim/rc/fileencodings.vim
source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim

if !has('gui_running')
  " colorscheme desert256
  colorscheme landscape
  " colorscheme mycolor
end

" vim: ts=2 sw=2 sts=2 et fdm=marker
