#export LANG=ja_JP.UTF-8
#export EDITOR=vim

if [ -x $HOME/local/$HOST/bin/zsh ]; then
	exec $HOME/local/$HOST/bin/zsh
fi


# __END__ {{{1
# vim:smarttab expandtab
# vim:foldmethod=marker

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
