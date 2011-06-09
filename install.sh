#!/usr/bin/env sh
# vim: ft=sh: et

if [ ! -f ~/.irbrc ]; then
  ln -sf dotfiles/.irbrc ~/.irbrc
  echo installed .irbrc
fi
if [ ! -f ~/.gitconfig ]; then
  ln -sf dotfiles/.gitconfig ~/.gitconfig
  echo installed .gitconfig
fi
if [ ! -f ~/.vimrc ]; then
  ln -sf dotfiles/.vimrc ~/.vimrc
  echo installed .vimrc
fi
if [ ! -f ~/.zlogin ]; then
  ln -sf dotfiles/.zlogin ~/.zlogin
  echo installed .zlogin
fi
if [ ! -f ~/.zshrc ]; then
  ln -sf dotfiles/.zshrc ~/.zshrc
  echo installed .zshrc
fi
if [ ! -f ~/.screenrc ]; then
  ln -sf dotfiles/.screenrc ~/.screenrc
  echo installed .screenrc
fi
if [ ! -f ~/.vim ]; then
  ln -sf dotfiles/.vim ~/.vim
  echo installed .vim
fi

echo prease export fpath
