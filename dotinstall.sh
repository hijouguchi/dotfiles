#!/usr/bin/env sh
# vim: et

repo=dotfiles
dst=`dirname $0`/$repo
src=`pwd`
histdir=$src/.history

giturl=https://github.com:hijouguchi/dotfiles.git

linkfiles=(  \
  .gitconfig \
  .irbrc     \
  .screenrc  \
  .vim       \
  .vimrc     \
  .zshrc     \
  .ctags     \
  .globalrc  \
)


# checkout repository from git
if [ ! -d $dst ]; then
  git clone $giturl $dst
fi

# create symlink for ditfiles
for file in ${linkfiles[@]}; do
  if [ -e $dst/$file ]; then
    ln -sf $dst/$file $src/$file
  else
    "$dst/$file is not exist." >&2
  fi
done

if [ ! -d $histdir ]; then
  mkdir $histdir
fi

# for update vim plugin
vim --cmd "so ~/.vimrc | PackManCheck" +q

