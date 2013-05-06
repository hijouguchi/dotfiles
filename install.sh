#!/usr/bin/env sh
# vim: ft=sh: et


if [[ ! -f $HOME/.pryrc ]]     ; then ln -sf $HOME/dotfiles/.pryrc     $HOME/.pryrc                         ; fi
if [[ ! -f $HOME/.gitconfig ]] ; then ln -sf $HOME/dotfiles/.gitconfig $HOME/.gitconfig                     ; fi
if [[ ! -f $HOME/.vimrc ]]     ; then ln -sf $HOME/dotfiles/.vimrc     $HOME/.vimrc                         ; fi
if [[ ! -f $HOME/.vim ]]       ; then ln -sf $HOME/dotfiles/.vim       $HOME/.vim                           ; fi
if [[ ! -f $HOME/.screenrc ]]  ; then ln -sf $HOME/dotfiles/.screenrc  $HOME/.screenrc                      ; fi
if [[ ! -f $HOME/.zshrc ]]     ; then ln -sf $HOME/dotfiles/.zshrc     $HOME/.zshrc                         ; fi
if [[ ! -f $HOME/.zshenv ]]    ; then echo 'export FPATH=$HOME/dotfiles/zfunctions:$FPATH' >> $HOME/.zshenv ; fi

cd dotfiles
git submodule update --init
