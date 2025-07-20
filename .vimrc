scriptencoding utf-8

set nocompatible

set runtimepath+=~/.vim/pack/packman

source ~/.vim/rc/encoding.vim

if isdirectory(expand("$HOME/.history"))
  let g:cachedir = expand("$HOME/.history")
else
  let g:cachedir = 0
endif

call packman#begin()
source ~/.vim/rc/pack/vimdoc-ja.vim
source ~/.vim/rc/pack/vim-cursorword.vim
source ~/.vim/rc/pack/vim-textobj-user.vim
source ~/.vim/rc/pack/Align.vim
source ~/.vim/rc/pack/vcscommand.vim
source ~/.vim/rc/pack/matchit.vim
source ~/.vim/rc/pack/lightline.vim
source ~/.vim/rc/pack/landscape.vim
source ~/.vim/rc/pack/surround.vim
source ~/.vim/rc/pack/vim-submode.vim
source ~/.vim/rc/pack/vim-smartinput.vim
source ~/.vim/rc/pack/vim-quickrun.vim
source ~/.vim/rc/pack/gtags.vim
source ~/.vim/rc/pack/netrw.vim
source ~/.vim/rc/pack/complete.vim
source ~/.vim/rc/pack/vim-clang-format.vim
call packman#end()

filetype plugin indent on
syntax enable


source ~/.vim/rc/general.vim
source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim

" vim: ts=2 sw=2 sts=2 et fdm=marker
