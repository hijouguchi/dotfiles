# 重複を防ぐ
typeset -U path cdpath fpath manpath

export FPATH=$HOME/dotfiles/zfunctions:$FPATH

# PATH
path=($HOME/local/bin $HOME/local/opt/*/bin(N-/) /usr/local/bin /sbin $path)
export PATH

export OCTAVE_HISTFILE=$HOME/.history/octave_hist
export LESSHISTFILE=$HOME/.history/lesshst
