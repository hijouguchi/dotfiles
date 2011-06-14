#!/usr/bin/env sh
# vim: ft=sh: et


[[ ! -f $HOME/.irbrc ]]                   && ln -sf $HOME/dotfiles/.irbrc     $HOME/.irbrc
[[ ! -f $HOME/.gitconfig ]]               && ln -sf $HOME/dotfiles/.gitconfig $HOME/.gitconfig
[[ ! -f $HOME/.vimrc ]]                   && ln -sf $HOME/dotfiles/.vimrc     $HOME/.vimrc
[[ ! -f $HOME/.vim ]]                     && ln -sf $HOME/dotfiles/.vim       $HOME/.vim
[[ ! -f $HOME/.zlogin ]]                  && ln -sf $HOME/dotfiles/.zlogin    $HOME/.zlogin
[[ ! -f $HOME/.zshrc ]]                   && ln -sf $HOME/dotfiles/.zshrc     $HOME/.zshrc
[[ ! -f $HOME/.screenrc ]]                && ln -sf $HOME/dotfiles/.screenrc  $HOME/.screenrc
[[ ! -f $HOME/.zshenv ]]                  && echo 'export FPATH=$HOME/dotfiles/zfunctions:$FPATH' >> $HOME/.zshenv
[[ ! -f $HOME/dotfiles/keymap.screenrc ]] && echo 'escape ^Gt' >> $HOME/dotfiles/keymap.screenrc
