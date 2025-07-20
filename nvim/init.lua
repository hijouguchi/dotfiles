

vim.opt.rtp:prepend("~/.vim/pack/packman")

vim.opt.pp:prepend(vim.env.HOME .. '/.vim')
-- vim.g.packman_default_directory = vim.env.HOME .. '/.vim'
vim.cmd('call packman#begin()')
-- vim.cmd('source ~/.vim/rc/pack/vimdoc-ja.vim')
-- vim.cmd('source ~/.vim/rc/pack/vim-cursorword.vim')
vim.cmd('source ~/.vim/rc/pack/vim-textobj-user.vim')
vim.cmd('source ~/.vim/rc/pack/Align.vim')
-- vim.cmd('source ~/.vim/rc/pack/vcscommand.vim')
vim.cmd('source ~/.vim/rc/pack/matchit.vim')
-- vim.cmd('source ~/.vim/rc/pack/lightline.vim')
-- vim.cmd('source ~/.vim/rc/pack/landscape.vim')
vim.cmd('source ~/.vim/rc/pack/surround.vim')
-- vim.cmd('source ~/.vim/rc/pack/vim-submode.vim')
vim.cmd('source ~/.vim/rc/pack/vim-smartinput.vim')
-- vim.cmd('source ~/.vim/rc/pack/vim-quickrun.vim')
-- vim.cmd('source ~/.vim/rc/pack/gtags.vim')
-- vim.cmd('source ~/.vim/rc/pack/netrw.vim')
-- vim.cmd('source ~/.vim/rc/pack/complete.vim')
-- vim.cmd('source ~/.vim/rc/pack/vim-clang-format.vim')
vim.cmd('call packman#end()')

vim.cmd('source ~/.vim/rc/common/general.vim')
vim.cmd('source ~/.vim/rc/common/command.vim')
vim.cmd('source ~/.vim/rc/common/autocmd.vim')
vim.cmd('source ~/.vim/rc/common/keymap.vim')
