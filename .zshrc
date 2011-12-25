# NOTE {{{1


# exec screen {{{1
_screen_exec() {
  screen -wipe
 if [[ -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
   # screen escape sequence is "^G"
   exec screen -U -D -RR -e"^Gt" -c $HOME/dotfiles/layout.screenrc
 else
   exec screen -U -x
 fi
}

case "${TERM}" in
  *xterm*|rxvt|(dt|k|E)term)
    _screen_exec
    ;;
esac


# Basic Settings {{{1


# minimum function
if [[ $OSTYPE == darwin* ]]; then
  function dircolors() { gdircolors $* }
  function ls() { gls $* }
fi

export LANG=ja_JP.UTF-8
export EDITOR=vim


eval `dircolors -b`

setopt no_beep
setopt equals
setopt case_glob

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
PROMPT="%B%(?||[error] )%n@%m%#%b "
PROMPT2="%_ > "
RPROMPT="%1(v|%1v|:%(3~,%-1~/.../%1~,%~))"

# zmv
autoload -Uz zmv
alias zmv='noglob zmv -W'

autoload -U add-zsh-hook

# vcs_info
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*'     formats       "%c%u[%r:%b]:%S"
zstyle ':vcs_info:*'     actionformats "%c%u[%r:%b|%a]:%S"
zstyle ':vcs_info:git:*' stagedstr     "[I]"
zstyle ':vcs_info:git:*' unstagedstr   "[W]"



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
zstyle ':completion:*:(vim|cp|mv|rm):*' ignore-line true
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' ignore-parents parent pwd

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processec' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# Keymappings {{{1
bindkey -v

bindkey               "^I"   menu-complete
bindkey               '^p'   history-beginning-search-backward
bindkey               '^n'   history-beginning-search-forward
bindkey -v            '^h'   vi-backward-char
bindkey -v            '^l'   vi-forward-char
bindkey               "\e[Z" reverse-menu-complete
bindkey               '^d'   push-line

bindkey -M vicmd      'u'    undo
bindkey -M vicmd      '^r'   redo

# for use hjkl in menuselect
zmodload -i zsh/complist
bindkey -M menuselect '^h'    backward-char
bindkey -M menuselect '^j'    down-line-or-history
bindkey -M menuselect '^k'    up-line-or-history
bindkey -M menuselect '^l'    forward-char


autoload -U  edit-command-line
zle -N edit-command-line
bindkey               '^e'   edit-command-line


# Alias {{{1
alias ls='ls -hF   --color=auto'
alias la='ls -hAF  --color=auto'
alias ll='ls -hlAF --color=auto'
alias l1='ls -h1AF --color=auto'
alias du='du -h'
alias grep='grep --color'
alias quit=exit

alias vim='screen vim'


alias -g G='|grep --color'
alias -g T='|tee'
alias -g L='|less'
alias -g X='|xargs'
alias -g G2='2>&1 |grep'
alias -g T2='2>&1 |tee'
alias -g L2='2>&1 |less'


# Tiny function {{{1
# for preexec, precmd, and chpwd {{{2
_update_vcs_info_msg() {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

# returns number of files if last command is type of ls
_type_ls() {
  for cmd in $=2; do
    [[ "$cmd" == "ls" ]] && _echo_number_of_files && break
  done
}


# returns number of files
_echo_number_of_files() {
  echo "$fg[red]`ls -A1 | wc -l | sed -e 's/ //g'` files$reset_color in $fg[green]`pwd`$reset_color"
}


_set_pwd_screen() screen -X title `pwd`


_update_screen_name_for_preexec() {
  local cmd
  : ${cmd::=${1##([[:digit:]])# (sudo )#}} # remove number and sudo
  : ${cmd::=${cmd##screen }} # remove screen
  COMMAND_NAME=$cmd # save cmd for _update_screen_name_for_precmd

  case ${cmd%% *} in
    ls|ll|la) _echo_number_of_files;;
    vim) screen -X title "${cmd%% *}";;
    ssh*) ;;
    *) screen -X title "!$cmd[1,10]";;
  esac
}


_update_screen_name_for_precmd() {
  #TODO: if not active window in screen, notification
  local cmd=$COMMAND_NAME # load cmd from _update_screen_name_for_preexec
  unset COMMAND_NAME # remove cmd

  case $cmd in
    quit|exit|ssh*|) ;;
    ls|ll|la|cd) ;;
    *) screen -X title "${cmd%% *}";;
  esac
}


_update_git_commit_screen_name() {
  local git_branch=`git branch 2>&1 | grep '^*' | sed -e 's/^* //'`
  if [[ -n "$git_branch" ]] then
    local dir_orig=`pwd`
    local dir=$dir_orig
    while [[ -n "$dir" ]] ; do
      if [[ -n "`ls -1aF $dir | grep .git/`" ]] then
        local relative_git_path="${${dir_orig#${dir}}#/}"
        #screen -X title "${dir##*/}[$git_branch]:$relative_git_path"
        screen -X title "[${dir##*/}:$git_branch]"
        break
      fi
      local dir=${dir%/*}
    done
  fi
}

# here add pre***_functions
preexec_functions=(_type_ls)
precmd_functions=(_update_vcs_info_msg)
chpwd_functions=(_echo_pwd)


# for screen hock functions {{{2


_ssh_new_screen() screen -U -t "$@[-1]" ssh $*

_ssh_screen() screen -U -t "$@[-1]" ssh $* -t screen -U -D -RR


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


# __END__ {{{1
# vim:smarttab expandtab
# vim:foldmethod=marker


