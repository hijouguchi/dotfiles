# General Settings {{{1

[ ! -v MY_ZSH_LOG_DIR  ] && MY_ZSH_LOG_DIR=$HOME/.zsh
[ ! -d $MY_ZSH_LOG_DIR ] && mkdir $MY_ZSH_LOG_DIR

# for $LS_COLORS
eval `dircolors -b`

export GREP_OPTIONS='--extended-regexp --ignore-case --color'
export LESS='--ignore-case -RX'

autoload -Uz zmv
alias zmv='noglob zmv -W'

# 16 Options {{{1

setopt NO_BEEP

# 16.2.1 Chanding Directories {{{2
setopt AUTO_CD           # ディレクトリ名指定で cd する
setopt AUTO_PUSHD        # ディレクトリを移動したら pushd に積む
setopt CHASE_DOTS        # cd hoge/.. みたいなことをしたときのパスをいい感じにする
setopt PUSHD_IGNORE_DUPS # pushd したディレクトリがかぶってたら pushd しない

# 16.2.4 History {{{2
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zhistory
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Alias {{{1
# Basic Aliasies {{{2
alias  l='ls -hF   --color=auto'
alias ls='ls -hF   --color=auto'
alias la='ls -hAF  --color=auto'
alias ll='ls -hlAF --color=auto'
alias l1='ls -h1AF --color=auto'

alias du='du -h'
alias grep='grep --color'
alias quit=exit

# Piped Aliasies {{{2
alias -g G='| grep'
alias -g T='| tee'
alias -g L='| less'
alias -g X='| xargs'
alias -g G2='2>&1 | grep'
alias -g T2='2>&1 | tee'
alias -g L2='2>&1 | less'

# for GNU SCREEN {{{2
# FIXME: 別の端末でscreenを開いていると、自分が screen に属していないにも関わらず screen 判定されてしまう
if [[ ! -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
  alias vim="screen vim"
  alias vimdiff="screen vimdiff"
  alias pry='screen pry'
  alias s='screen'
fi

#  20.5 Bindable Commands {{{1
# vi like keybind {{{2
bindkey -v
# Reverse the order of history (for my vim settings)
bindkey               '^p'   history-beginning-search-backward
bindkey               '^n'   history-beginning-search-forward
bindkey               "^i"   menu-complete
bindkey               "^[[Z" reverse-menu-complete
bindkey -M vicmd      'u'    undo
bindkey -M vicmd      '^r'   redo

# poted some convinient emacs key binds {{{2
bindkey               '^b'    backward-char
bindkey               '^f'    forward-char
bindkey               '^a'    beginning-of-line
bindkey               '^e'    end-of-line
bindkey               '^k'    kill-line
bindkey               '^x^b'  backward-word
bindkey               '^x^f'  forward-word

# for hjkl in menuselect {{{2
zmodload -i zsh/complist
bindkey -M menuselect '^h'    backward-char
bindkey -M menuselect '^j'    down-line-or-history
bindkey -M menuselect '^k'    up-line-or-history
bindkey -M menuselect '^l'    forward-char
bindkey -M menuselect '^n'    down-line-or-history
bindkey -M menuselect '^p'    up-line-or-history
bindkey -M menuselect '^m'    self-insert

# 20 Completion {{{1
# 20.2 Initialization {{{2
autoload -U compinit
compinit -d $MY_ZSH_LOG_DIR/zcompdump

# zstyle settings {{{2
# see 20.3.2 Standard Tags and 20.3.3 Standard Styles
zstyle ':completion:*' verbose yes

# see also 20.4 Control Functions
#zstyle ':completion:*' completer _complete _ignored

zstyle ':completion:*:warnings'     format "%B%F{yellow}--- Not Found ---%f%b"
zstyle ':completion:*:descriptions' format "%B%F{blue}--- Completing %d ---%f%b"
zstyle ':completion:*:corrections'  format "%B%F{blue}--- %d%f %F{red}(erros: %e)%f %F{blue} ---%f%b"

zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' file-patterns '*(^-/):files:files' '*(-/):directories:directories'

# 13 Prompt {{{1
setopt PROMPT_SUBST # $(...) によるの変数を prompt に表示
PROMPT='%B%(?,,%F{red}[error]%f )%n@%m%#%b '
#PROMPT='%B%(?,,%F{red}[error]%f )USER@HOST%#%b '
PROMPT2="%_ > "
RPROMPT='%B%1v%(2v,%F{yellow}%2v%f ,)%b:%4(~|%-1~/.../%2~|%~)'

# Functions {{{2
function vi_mode_prompt_info() {
  if [[ $KEYMAP == 'vicmd' ]]; then
    echo '%B%F{green}[NORMAL]%f%b '
  else
    echo ""
  fi
}

function zle-line-init zle-keymap-select {
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# vcs info {{{1
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 5

zstyle ':vcs_info:*' stagedstr   'index' # %c の文字列
zstyle ':vcs_info:*' unstagedstr 'work'  # %u の文字列

zstyle ':vcs_info:*' formats       '[%r:%b] ' '%a' '%u' '%c' '%m'
zstyle ':vcs_info:*' actionformats '[%r:%b] ' '%a' '%u' '%c' '%m'
zstyle ':vcs_info:git+set-message:*' hooks git-push-status

function +vi-git-push-status() {
  # max-exports の回数だけ叩かれるので、%m の時だけ動くようにする
  [[ "$1" != "4" ]] && return 0
  # .git 以下のディレクトリだと怒られるのでここでは無視する
  [[ `pwd | grep '\.git'` ]] && return 0

  local git_status=`git status`

  # push/pull
  if [[ `echo ${git_status} | grep 'use "git pull" to merge'` ]]; then
    hook_com[misc]="pull-push"
  fi

  # pull
  if [[ `echo ${git_status} | grep 'use "git pull" to update'` ]]; then
    hook_com[misc]="pull"
  fi

  # push
  if [[ `echo ${git_status} | grep 'use "git push" to publish'` ]]; then
    hook_com[misc]="push"
  fi


}

# zsh hook {{{1
autoload -Uz add-zsh-hook

# for psvar hook {{{2
function _my_hook_psvar() {
  psvar=()

  vcs_info

  # branch name to psvar[1]
  psvar[1]=$vcs_info_msg_0_ || ""

  # branch status to psvar[2]
  messages=($vcs_info_msg_2_ $vcs_info_msg_3_ $vcs_info_msg_4_ $vcs_info_msg_5_)
  if [[ $#messages -gt 0 ]]; then
    psvar[2]="[${(j:|:)messages}]"
  else
    psvar[2]=""
  fi

  # msg_1 to psvar[3]
  psvar[3]=$vcs_info_msg_1_ || ""
}

add-zsh-hook precmd _my_hook_psvar

# for chenge directory hook {{{2
_my_hook_show_chdir() {
  #echo "$fg[red]${$(ls -A1 | wc -l)##*[[:blank:]]} files$reset_color in $fg[green]`pwd`$reset_color"
  local fcount=${$(timeout 1 ls -A1 | wc -l)##*[[:blank:]]}
  echo -e "\e[31m ${fcount} files in \e[32m`pwd`\e[m"
}
_my_hook_precmd_ls() {
  [[ "${2%%[[:blank:]]*}" == 'ls' ]] && _my_hook_show_chdir
}
add-zsh-hook chpwd   _my_hook_show_chdir
add-zsh-hook preexec _my_hook_precmd_ls

# Other function {{{1
_screen_exec() {
  screen -wipe
  if [[ -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
    exec ssh-agent screen -D -RR -e"^Gg"
  else
    exec screen -x
  fi
}
# __END__ {{{1
# vim:smarttab expandtab
# vim:tabstop=2 shiftwidth=2 softtabstop=2
# vim:foldmethod=marker
