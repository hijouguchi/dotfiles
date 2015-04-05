#!/usr/bin/env zsh
# vim: ft=zsh: et

# ログを置くディレクトリを作る
#mkdir -p $HOME/.history

# dotfile を置く
cd $HOME
[[ ! -f $HOME/.pryrc ]]     && ln -sf $HOME/dotfiles/.pryrc     .
[[ ! -f $HOME/.gitconfig ]] && ln -sf $HOME/dotfiles/.gitconfig .
[[ ! -f $HOME/.vimrc ]]     && ln -sf $HOME/dotfiles/.vimrc     .
[[ ! -f $HOME/.gvimrc ]]    && ln -sf $HOME/dotfiles/.gvimrc     .
[[ ! -f $HOME/.vim ]]       && ln -sf $HOME/dotfiles/.vim       .
[[ ! -f $HOME/.screenrc ]]  && ln -sf $HOME/dotfiles/.screenrc  .
[[ ! -f $HOME/.zshrc ]]     && ln -sf $HOME/dotfiles/.zshrc     .
[[ ! -f $HOME/.zshenv ]]    && cp     $HOME/dotfiles/zshenv     .zshenv

# vim の bundle を持ってくる
cd `dirname $0` # dotfiles に移動
git submodule update --init

#echo 'vim: BundleInstall'
