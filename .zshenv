typeset -U path cdpath fpath

export LANG=ja_JP.UTF-8

path=( \
  /opt/packages/*/bin(N-/) \
  /usr/local/opt/coreutils/libexec/gnubin \
  /usr/local/opt/ruby/bin \
  /usr/local/bin \
  /usr/local/sbin \
  $path \
)

fpath=( \
  $HOME/dotfiles/zfunctions \
  /usr/local/share/zsh/site-functions \
  $fpath \
)


export GOPATH=$HOME/work/.go

if [ `uname -s` = 'Darwin' ]; then
  setopt no_global_rcs
fi

