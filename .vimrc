scriptencoding utf-8

set nocompatible

source ~/.vim/rc/encoding.vim


if isdirectory(expand("$HOME/.history"))
  let g:cachedir = expand("$HOME/.history")
else
  let g:cachedir = 0
endif

call packman#initialize()

PackManAdd     'vim-jp/vimdoc-ja.git'
PackManAdd     'itchyny/landscape.vim'
PackManAddLazy 'kana/vim-textobj-user.git',  {'depends' : ['sgur/vim-textobj-parameter.git']}
PackManAddLazy 'vim-scripts/Align',          {'commands': ['Align']}
PackManAddLazy 'vim-scripts/vcscommand.vim', {'commands': [
      \ 'VCSCommit', 'VCSDiff',   'VCSLog',    'VCSRevert',
      \ 'VCSStatus', 'VCSUpdate', 'VCSVimDiff'            ]}

source ~/.vim/rc/pack/vimproc.vim
source ~/.vim/rc/pack/surround.vim
source ~/.vim/rc/pack/vim-submode.vim
source ~/.vim/rc/pack/vim-smartinput.vim
source ~/.vim/rc/pack/neocomplete.vim
source ~/.vim/rc/pack/vim-template.vim
source ~/.vim/rc/pack/vim-quickrun.vim
source ~/.vim/rc/pack/thumbnail.vim
source ~/.vim/rc/pack/incsearch.vim
source ~/.vim/rc/pack/gtags.vim

runtime macros/matchit.vim

filetype plugin indent on
syntax enable


source ~/.vim/rc/general.vim
source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim

if filereadable('~/.vim/localrc.vim')
  source ~/.vim/localrc.vim
endif

if !has('gui_running')
  " colorscheme desert256
  colorscheme landscape
end

" vim: ts=2 sw=2 sts=2 et fdm=marker
