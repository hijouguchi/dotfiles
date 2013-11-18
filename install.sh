#!/usr/bin/env zsh
# vim: ft=zsh: et

# ログを置くディレクトリを作る
mkdir -p $HOME/.history

# dotfile を置く
[[ ! -f $HOME/.pryrc ]]     && ln -sf $HOME/dotfiles/.pryrc     $HOME/.pryrc
[[ ! -f $HOME/.gitconfig ]] && ln -sf $HOME/dotfiles/.gitconfig $HOME/.gitconfig
[[ ! -f $HOME/.vimrc ]]     && ln -sf $HOME/dotfiles/.vimrc     $HOME/.vimrc
[[ ! -f $HOME/.vim ]]       && ln -sf $HOME/dotfiles/.vim       $HOME/.vim
[[ ! -f $HOME/.screenrc ]]  && ln -sf $HOME/dotfiles/.screenrc  $HOME/.screenrc
[[ ! -f $HOME/.zshrc ]]     && ln -sf $HOME/dotfiles/.zshrc     $HOME/.zshrc
[[ ! -f $HOME/.zshenv ]]    && cp     $HOME/dotfiles/zshenv     $HOME/.zshenv

# vim の bundle を持ってくる
dirname $0 # dotfiles に移動
git submodule update --init
