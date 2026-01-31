# Linux-specific settings go here.

path=( \
  /opt/packages/*/bin(N-/) \
  /usr/local/bin \
  /usr/local/sbin \
  $path \
)

fpath=( \
  $HOME/dotfiles/zfunctions \
  /usr/local/share/zsh/site-functions \
  $fpath \
)
