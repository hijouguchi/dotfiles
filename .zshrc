# NOTE {{{1


# exec screen {{{1
_screen_exec() {
  screen -wipe
  if [[ -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
    # screen escape sequence is "^G"
    # exec screen -U -D -RR -e"^Gt" -c $HOME/dotfiles/layout.screenrc
    exec screen -D -RR -e"^Gt"
  else
    exec screen -x
  fi
}

case "${TERM}" in
  *xterm*|rxvt|(dt|k|E)term|linux)
    _screen_exec
    ;;
esac


# Basic Settings {{{1

# minimum function
if [[ $OSTYPE == darwin* ]]; then
  function dircolors() { gdircolors $* }
  function ls() { gls $* }
fi

#export LANG=ja_JP.UTF-8
export EDITOR=vim


eval `dircolors -b`

setopt prompt_subst
setopt no_beep
setopt equals
setopt case_glob
setopt csh_junkie_loops
setopt transient_rprompt

REPORTTIME=30
TIMEFMT="\
The name of this job.             :%J
CPU seconds spent in user mode.   :%U
CPU seconds spent in kernel mode. :%S
Elapsed time in seconds.          :%E
The  CPU percentage.              :%P"

# for directory
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_remove_slash
setopt auto_name_dirs

# for history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zhistory
setopt hist_ignore_all_dups
setopt inc_append_history
setopt share_history


# color
autoload -Uz colors; colors


# prompt
PROMPT='%B%(?||[error] )%1v%3v%n@%m%#%b '
PROMPT2="%_ > "
RPROMPT='%2(v|%2v|:%4(~|%-1~/.../%2~|%~))'

# zmv
autoload -Uz zmv
alias zmv='noglob zmv -W'

autoload -U add-zsh-hook

# vcs_info
autoload -Uz vcs_info

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:*' formats       '[%b] '    '[%s|%r]:%S' ' %c%u '
zstyle ':vcs_info:*' actionformats '[%b|%a] ' '[%s|%r]:%S' ' %c%u '



# completion {{{1
autoload -U  compinit && compinit

setopt complete_in_word
setopt list_packed
setopt list_types
setopt correct
setopt magic_equal_subst
setopt always_last_prompt

zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _oldlist _expand _complete _match _prefix _approximate  _list _history
zstyle ':completion:*:messages'     format "$fg_bold[yellow]%d$reset_color"
zstyle ':completion:*:warnings'     format "$fg_bold[blue]No match command$reset_color"
zstyle ':completion:*:descriptions' format "$fg_bold[blue]completing %d$reset_color"
zstyle ':completion:*:corrections'  format "$fg_bold[blue]%d $fg_bold[red](erros: %e)$reset_color"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.zsh/cache

zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:*' ignore-line true
zstyle ':completion:*:(cp|mv):*' ignore-line false

zstyle ':completion:*:match:*' original only
zstyle ':completion:*' ignore-parents parent pwd

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processec' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

zstyle ':completion::complete:*:argument-rest:' list-dirs-first true


# Keymappings {{{1
bindkey -v

bindkey               '^p'   history-beginning-search-backward
bindkey               '^n'   history-beginning-search-forward
bindkey               '^b'   backward-char
bindkey               '^f'   forward-char
bindkey               '^a'   beginning-of-line
bindkey               '^e'   end-of-line

bindkey               "^i"   menu-complete
bindkey               "^[[Z" reverse-menu-complete

bindkey               '^]'   push-line

bindkey -M vicmd      'u'    undo
bindkey -M vicmd      '^r'   redo

# for use hjkl in menuselect
zmodload -i zsh/complist
bindkey -M menuselect '^h'    backward-char
bindkey -M menuselect '^j'    down-line-or-history
bindkey -M menuselect '^k'    up-line-or-history
bindkey -M menuselect '^l'    forward-char


# autoload -U  edit-command-line
# zle -N edit-command-line
# bindkey               '^e'   edit-command-line

bindkey               '^x'    _complete_help

# Alias {{{1
alias ls='ls -hF   --color=auto'
alias la='ls -hAF  --color=auto'
alias ll='ls -hlAF --color=auto'
alias l1='ls -h1AF --color=auto'
alias du='du -h'
alias grep='grep --color'
alias quit=exit

alias vim='screen vim'
alias s='screen'
alias emacs='screen emacs -nw'


alias -g G='|grep'
alias -g T='|tee'
alias -g L='|less'
alias -g X='|xargs'
alias -g G2='2>&1 |grep'
alias -g T2='2>&1 |tee'
alias -g L2='2>&1 |less'


# Tiny function {{{1
# for preexec, precmd, and chpwd {{{2

# for vcs_info
_make_psvar() {
  LANG=en_US.UTF-8 vcs_info
  psvar=(
    $vcs_info_msg_0_
    $vcs_info_msg_1_
    $vcs_info_msg_2_
  )
}

# for insert date into screen title
_append_screen_date() screen -X title "$(screen -Q title) [$(date +"%H:%M:%S")]"
_remove_screen_date() screen -X title "${"$(screen -Q title)"%%[[:blank:]]\[*}"


# echo number of files if last command is type of ls
_echo_pwd() echo "$fg[green]`pwd`$reset_color"

_type_ls() {
  [[ "${@[2]%%[[:blank:]]*}" == 'ls' ]] &&
    echo "$fg[red]${#${(@f)"$(ls -A1)"}[*]} files$reset_color in $fg[green]`pwd`$reset_color"
}


# here add pre***_functions
preexec_functions=(_type_ls)
precmd_functions=(_make_psvar)
chpwd_functions=(_echo_pwd)

if [[ ! -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
  preexec_functions=($preexec_functions _append_screen_date)
  precmd_functions=($precmd_functions _remove_screen_date)
fi


# for screen hock functions {{{2


_ssh_new_screen() screen -U -t "${@[-1]}" ssh $*

_ssh_screen() screen -U -t "${@[-1]}" ssh $* -t screen -D -RR


_screen_new_window_split() {
  screen -X split
  screen -X focus
  screen $*
}


_screen_new_window_split_v() {
  screen -X split -v
  screen -X focus
  screen $*
}


_screen_name_manual_update() {
  screen -X title "$*"
  echo "screen title is changed to '$*'"
}


# all_window_cd {{{2
# MEMO: windowがshellじゃなかったらどうする？
_all_window_cd() {
  for list in $(screen -Q windows); do
    num=$(echo $list | sed -e 's/[^0-9].*$//g')
    if [ -n "$num" ]; then
      screen -X "at $num stuff cd $0"
    fi
  done
}

calc() {
  zmodload zsh/mathfunc
  echo $(( $* ))
}
alias e='noglob calc'


# others {{{1


# __END__ {{{1
# vim:smarttab expandtab
# vim:foldmethod=marker


