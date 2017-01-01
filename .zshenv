# vim: et
typeset -U path cdpath fpath manpath
export FPATH=$HOME/dotfiles/zfunctions:$FPATH
path=( \
  /opt/*/bin(N-/) \
  /usr/local/bin \
  /usr/local/sbin \
  $path)
export PATH

#export OCTAVE_HISTFILE=$HOME/.history/octave_hist

if [ -d $HOME/.history ]; then
  export LESSHISTFILE=$HOME/.history/lesshst
fi

# for less color
#export LESSOPEN='| src-hilite-lesspipe.sh %s'


# TODO: mac 以外の場合も対応できるように
if [ `uname -s` = 'Darwin' ]; then
  # homebrew を使っている前提で書いてるので注意
  SYSTEMC=/usr/local/opt/systemc
  export SYSTEMC_INCLUDE=${SYSTEMC}/include
  export SYSTEMC_LIBDIR=${SYSTEMC}/lib
fi

if [ `uname -s` = 'Darwin' ]; then
  setopt no_global_rcs
fi

