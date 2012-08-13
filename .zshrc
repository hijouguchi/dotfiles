# NOTE {{{1



# exec screen {{{1
# FIXME: ssh-agentが二重に起動されないように設定する
_screen_exec() {
  screen -wipe
  if [[ -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
    exec screen -D -RR -e"^Gg"
  else
    exec screen -x
  fi
}

case "$TERM" in
  *xterm*|rxvt|(dt|k|E)term)
    #exec screen -D -RR -e"^Gg" -c dotfiles/layout.screenrc
    exec screen -D -RR -e"^Gg"
    ;;
  linux)
    ssh-agent startx
    [[ $? == 0 ]] && exit
    ;;
esac


# Program settings {{{1
export GREP_OPTIONS='--extended-regexp --ignore-case --color'
export LESS='--ignore-case -R'


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
zstyle ':vcs_info:*' max-exports 4
zstyle ':vcs_info:*' stagedstr   'index' # インデックスに追加された場合に表示される文字列
zstyle ':vcs_info:*' unstagedstr 'work'  # 作業コピーに変更があった場合に表示される文字列
zstyle ':vcs_info:*' formats       '[%b] '    '[%s:%r]:%S' '%u' '%c'
zstyle ':vcs_info:*' actionformats '[%b|%a] ' '[%s:%r]:%S' '%u' '%c'



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
zstyle ':completion:*:*:vim:*' ignored-patterns \
  '*.eps' '*.jpg' '*.png' '*.gif' \
  '*.aux' '*.bbl' '*.dvi' '*.pdf' '*.blg' \
  '*~'

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
bindkey -M menuselect '^n'    down-line-or-history
bindkey -M menuselect '^p'    up-line-or-history


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
alias scp='scp -c arcfour256'

alias grep='grep --color'
alias quit=exit

if [[ ! -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
  alias vim='screen vim'
  alias s='screen'
  #alias emacs='screen emacs -nw'
fi
#case "$TERM" in
#  screen*) ;;
#  *) ;;
#esac


alias -g G='| grep'
alias -g T='| tee'
alias -g L='| less'
alias -g X='| xargs'
alias -g G2='2>&1 | grep'
alias -g T2='2>&1 | tee'
alias -g L2='2>&1 | less'


# Tiny function {{{1
# for preexec, precmd, and chpwd {{{2

# for vcs_info
_make_psvar() {
  vcs_info
  local state
  if [[ -n "$vcs_info_msg_2_" && -n "$vcs_info_msg_3_" ]]; then
    state="[$vcs_info_msg_2_|$vcs_info_msg_3_] "
  elif [[ -n "$vcs_info_msg_2_" || -n "$vcs_info_msg_3_" ]]; then
    state="[$vcs_info_msg_2_$vcs_info_msg_3_] "
  fi
  psvar=($vcs_info_msg_0_ $vcs_info_msg_1_ $state)
}

# echo number of files if last command is type of ls
_echo_pwd() echo "$fg[red]${$(ls -A1 | wc -l)##*[[:blank:]]} files$reset_color in $fg[green]`pwd`$reset_color"
_type_ls() { [[ "${2%%[[:blank:]]*}" == 'ls' ]] && _echo_pwd }


# here add pre***_functions
preexec_functions=(_type_ls)
[[ "$ZSH_VERSION[1,5]" == "5.0.0" ]] && precmd_functions=(_make_psvar)
chpwd_functions=(_echo_pwd)


# for screen title {{{2
# see also: http://d.hatena.ne.jp/tarao/20100223/1266958660

# titleを自動で設定，あるいは自動で設定するためのコマンド
export SCREEN_TITLE_NAME=
title() {
  SCREEN_TITLE_NAME="$1"
  if [[ -n "$SCREEN_TITLE_NAME" ]]; then
    screen -X title "$SCREEN_TITLE_NAME"
  fi
}

# titleを設定するコマンド
_set_screen_title() {
  [[ -n "$SCREEN_TITLE_NAME" ]] && return
  # 実際に設定する
  local command_name title_name
  command_name=${${1##sudo[[:blank:]]}%%[[:blank:]]*}

  case "$command_name" in
  ls|cd|*sh|vim|emacs|git) ;;
  less|tail|man) title_name="$1" ;;
  *) title_name="$command_name" ;;
  esac
  [[ -n "$title_name" ]] && screen -X title "$title_name"
}


if [[ ! -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
  preexec_functions+=_set_screen_title
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
  for list in $(screen -Q eval '@windows'); do
    num=$(echo $list | sed -e 's/[^0-9].*$//g')
    if [ -n "$num" ]; then
      screen -X "at $num stuff cd $0"
    fi
  done
}

# other functions {{{2

r_help() {
  R --vanilla --slave <<EOF
  help($1)
EOF
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


