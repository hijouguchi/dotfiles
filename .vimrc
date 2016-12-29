" vim: ts=2 sw=2 sts=2 et fdm=marker

set encoding=utf-8
scriptencoding utf-8
set nocompatible
filetype plugin indent on
syntax enable

call packman#initialize()

PackManAdd     'Shougo/vimproc.vim'
PackManAdd     'vim-jp/vimdoc-ja.git'
PackManAdd     'itchyny/landscape.vim'
PackManAddLazy 'kana/vim-textobj-user.git',  {'timer': 10, 'depends': ['sgur/vim-textobj-parameter.git']}
PackManAddLazy 'vim-scripts/Align',          {'commands': ['Align']}
PackManAddLazy 'vim-scripts/vcscommand.vim', {'commands': ['VCSVimDiff']}

source ~/.vim/rc/pack/surround.vim
source ~/.vim/rc/pack/vim-submode.vim
source ~/.vim/rc/pack/vim-smartinput.vim
source ~/.vim/rc/pack/neocomplete.vim
source ~/.vim/rc/pack/vim-template.vim
source ~/.vim/rc/pack/vim-quickrun.vim
source ~/.vim/rc/pack/thumbnail.vim
source ~/.vim/rc/pack/incsearch.vim
source ~/.vim/rc/pack/gtags.vim

PackManLoad

function! s:load_matchit(...)
  runtime macros/matchit.vim
endfunction

call timer_start(15, function('s:load_matchit'))


source ~/.vim/rc/general.vim
source ~/.vim/rc/fileencodings.vim
source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim

if filereadable('~/.vim/localrc.vim')
  source ~/.vim/localrc.vim
endif

if !has('gui_running')
  " colorscheme desert256
  colorscheme landscape
  " colorscheme mycolor
end

" vim: ts=2 sw=2 sts=2 et fdm=marker
