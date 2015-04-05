" .vimrc
"
" Maintainer: hijouguchi <taka13.mac+vim@gmail.com>
" Last Change: 2015 Apr 05

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

NeoBundle 'vim-jp/vimdoc-ja.git'
NeoBundle 'vim-scripts/Align'
NeoBundle 'kana/vim-textobj-user.git'
NeoBundle 'sgur/vim-textobj-parameter.git'
NeoBundle 'itchyny/thumbnail.vim' " depened by rc/keymap.vim
" NeoBundle 'https://github.com/LeafCage/foldCC.git'

source ~/.vim/rc/bundle/surround.vim
source ~/.vim/rc/bundle/vim-submode.vim
source ~/.vim/rc/bundle/vim-smartinput.vim
source ~/.vim/rc/bundle/neocomplete.vim
source ~/.vim/rc/bundle/vim-template.vim

runtime macros/matchit.vim

call neobundle#end()

filetype plugin indent on
syntax enable
NeoBundleCheck


source ~/.vim/rc/general.vim
source ~/.vim/rc/fileencodings.vim
" source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim

" vim: ts=2 sw=2 sts=2 et fdm=marker
