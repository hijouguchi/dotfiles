scriptencoding utf-8

set nocompatible

source ~/.vim/rc/encoding.vim

if isdirectory(expand("$HOME/.history"))
  let g:cachedir = expand("$HOME/.history")
else
  let g:cachedir = 0
endif

call packman#begin()
call packman#config#github#new('vim-jp/vimdoc-ja.git')
call packman#config#github#new('itchyny/landscape.vim')
call packman#config#github#new('itchyny/vim-cursorword.git')

let e = packman#config#github#new('kana/vim-textobj-user.git')
call e.set_lazy(v:true)
call e.add_depends(
      \ packman#config#github#new('sgur/vim-textobj-parameter.git')
      \ )


let e = packman#config#github#new('vim-scripts/Align')
call e.add_hook_commands('Align')

let e = packman#config#github#new( 'vim-scripts/vcscommand.vim')
call e.add_hook_commands(
      \ 'VCSCommit', 'VCSDiff',   'VCSLog',    'VCSRevert',
      \ 'VCSStatus', 'VCSUpdate', 'VCSVimDiff')

call packman#config#runtime#new('macros/matchit.vim')


"source ~/.vim/rc/poorline.vim

source ~/.vim/rc/pack/vimproc.vim
source ~/.vim/rc/pack/lightline.vim
source ~/.vim/rc/pack/surround.vim
source ~/.vim/rc/pack/vim-submode.vim
source ~/.vim/rc/pack/vim-smartinput.vim
source ~/.vim/rc/pack/vim-quickrun.vim
"source ~/.vim/rc/pack/vim-template.vim
"source ~/.vim/rc/pack/thumbnail.vim
source ~/.vim/rc/pack/gtags.vim
source ~/.vim/rc/pack/complete.vim

call packman#end()

filetype plugin indent on
syntax enable


source ~/.vim/rc/general.vim
source ~/.vim/rc/command.vim
source ~/.vim/rc/autocmd.vim
source ~/.vim/rc/keymap.vim
source ~/.vim/rc/complete.vim

if filereadable('~/.vim/localrc.vim')
  source ~/.vim/localrc.vim
endif

if !has('gui_running')
  colorscheme landscape
end

" ファイルツリーの表示形式、1にするとls -laのような表示になります
let g:netrw_liststyle=1
" ヘッダを非表示にする
let g:netrw_banner=0
" サイズを(K,M,G)で表示する
let g:netrw_sizestyle="H"
" 日付フォーマットを yyyy/mm/dd(曜日) hh:mm:ss で表示する
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
" プレビューウィンドウを垂直分割で表示する
let g:netrw_preview=1

" vim: ts=2 sw=2 sts=2 et fdm=marker
