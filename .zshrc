
if [[ -z "$STY"  ]]; then
  exec screen -D -RR -e"^Gg"
fi

# ここに zhistory, zcompdump を作る
if [[ ! -e ~/.zsh ]]; then
  mkdir ~/.zsh
fi

# for $LS_COLORS
eval `dircolors -b`

## Changing Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CHASE_DOTS
setopt PUSHD_IGNORE_DUPS

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/zhistory
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY


################################################################################
# alias
################################################################################
alias ls='ls -hF --color=auto'
alias la='ls -a'
alias ll='ls -la'
alias l1='ls -1'
alias la1='ls -1a'
alias l=ls

alias du='du -h'
alias grep='grep --color'
alias quit=exit

alias -g G='| grep'
alias -g T='| tee'
alias -g L='| less'
alias -g X='| xargs'
alias -g G2='2>&1 | grep'
alias -g T2='2>&1 | tee'
alias -g L2='2>&1 | less'


## FIXME: 別の端末でscreenを開いていると、自分が screen に属していないにも関わらず screen 判定されてしまう
if [[ ! -n "`screen -ls 2>&1 | grep 'No Sockets found in'`" ]]; then
  alias vim="screen vim"
  alias vimdiff="screen vimdiff"
  alias s='screen'
  alias title='screen -X title'
fi

################################################################################
# key binds
################################################################################
bindkey -v
zmodload -i zsh/complist
bindkey '^p'   history-beginning-search-backward
bindkey '^n'   history-beginning-search-forward
bindkey '^i'   menu-complete
bindkey '^[[Z' reverse-menu-complete

bindkey '^b'    backward-char
bindkey '^f'    forward-char
bindkey '^a'    beginning-of-line
bindkey '^e'    end-of-line
bindkey '^k'    kill-line
bindkey '^x^b'  backward-word
bindkey '^x^f'  forward-word

bindkey -M vicmd 'u'  undo
bindkey -M vicmd '^r' redo

bindkey -M menuselect '^h' backward-char
bindkey -M menuselect '^j' down-line-or-history
bindkey -M menuselect '^k' up-line-or-history
bindkey -M menuselect '^l' forward-char
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
bindkey -M menuselect '^m' self-insert


################################################################################
# Completion
################################################################################
ZCOMPDUMP=~/.zsh/zcompdump
autoload -U compinit

# zcompdump の最終更新日が昨日なら、zcompdump を作り直す
if [[ ! -e ${ZCOMPDUMP} || `stat -c %Y ${ZCOMPDUMP}` -lt `date -d "yesterday" +%s` ]]; then
  compinit -d ${ZCOMPDUMP}
else
  compinit -C -d ${ZCOMPDUMP}
fi

zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu true
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z} r:|[-_.]=**'
zstyle ':completion:*' completer _extensions _expand _complete _match _prefix _approximate

zstyle ':completion:*' file-patterns \
  '*(^-/):files:files' \
  '*(-/):directories:directories'

zstyle ':completion:*' ignore-parents parent pwd ..

zstyle ':completion:*:*:vim:*:*files' ignored-patterns '*.o'

zstyle ':completion:*'              group-name ''
zstyle ':completion:*'              list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format "%B%F{blue}--- Completing %d ---%f%b"
zstyle ':completion:*:corrections'  format "%B%F{blue}--- %d%f %F{red}(erros: %e)%f %F{blue} ---%f%b"
zstyle ':completion:*:warnings'     format "%B%F{yellow}--- Not Found ---%f%b"
zstyle ':completion:*:options'      description yes

################################################################################
# Prompt
################################################################################
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook

# see also: https://github.com/mafredri/zsh-async
# ここの async.zsh を $fpath/async としてコピーすると使える
autoload -Uz async && async

typeset -A __prompt_async_data__

PROMPT=""
PROMPT+="%(?,,%F{red}[error]%f )"
PROMPT+="%B%n@%m%#%b "

PROMPT2="%_ > "

RPROMPT=''
RPROMPT+='${__prompt_keymap__}'
RPROMPT+='${__prompt_async_data__[git-status]}'
RPROMPT+='${__prompt_async_data__[git-ahead]}'
RPROMPT+='${__prompt_async_data__[git-branch]}'
RPROMPT+=':%4(~|%-1~/.../%2~|%~)'

# -----------------------------------------------------------------------------
function prompt_async::job::git-branch() {
  if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
    return
  fi

  local branch=`git branch --contains | cut -d " " -f 2`
  local repo=`basename $(git rev-parse --show-toplevel)`

  echo "%B[${repo}:${branch}]%b"
}

function prompt_async::callback::git-branch() {
  __prompt_async_data__[git-branch]="$3"
  zle .reset-prompt
}

function prompt_async::setup::git-branch() {
  async_stop_worker       worker::git-branch
  async_start_worker      worker::git-branch -n
  async_register_callback worker::git-branch prompt_async::callback::git-branch
  async_job               worker::git-branch prompt_async::job::git-branch
}

# -----------------------------------------------------------------------------
function prompt_async::job::git-status() {
  if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
    return
  fi

  local result=''
  local git_status=`git status --porcelain`

  # untrack
  if [[ $(echo ${git_status} | cut -c 1-2 | grep '\?') ]]; then
    result+="%B%F{red}[untrack]%f%b"
  fi

  # 2 文字目は working tree
  if [[ $(echo ${git_status} | cut -c 2 | grep '^[^? ]') ]]; then
    result+="%B%F{red}[unstage]%f%b"
  fi

  # 1 文字目は index
  if [[ $(echo ${git_status} | cut -c 1 | grep '^[^? ]') ]]; then
    result+="%B%F{green}[stage]%f%b"
  fi

  echo "${result}"
}

function prompt_async::callback::git-status() {
  __prompt_async_data__[git-status]="$3"
  zle .reset-prompt
}

function prompt_async::setup::git-status() {
  async_stop_worker       worker::git-status
  async_start_worker      worker::git-status -n
  async_register_callback worker::git-status prompt_async::callback::git-status
  async_job               worker::git-status prompt_async::job::git-status
}

# -----------------------------------------------------------------------------
function prompt_async::job::git-ahead() {
  if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
    return
  fi

  local branch=`git branch --contains | cut -d " " -f 2`
  local ahead=$(command git rev-list origin/${branch}..${branch} 2>/dev/null \
    | wc -l \
    | tr -d ' ')

  if [[ "$ahead" -gt 0 ]]; then
    echo "%B%F{blue}[ahead]%b%f"
  fi
}

function prompt_async::callback::git-ahead() {
  __prompt_async_data__[git-ahead]="$3"
  zle .reset-prompt
}

function prompt_async::setup::git-ahead() {
  async_stop_worker       worker::git-ahead
  async_start_worker      worker::git-ahead -n
  async_register_callback worker::git-ahead prompt_async::callback::git-ahead
  async_job               worker::git-ahead prompt_async::job::git-ahead
}

# -----------------------------------------------------------------------------
function __prompt_hook_precmd() {
  __prompt_async_data__=()
  prompt_async::setup::git-branch
  prompt_async::setup::git-status
  prompt_async::setup::git-ahead
}
add-zsh-hook precmd __prompt_hook_precmd

# -----------------------------------------------------------------------------
function zle-line-init zle-keymap-select {
  # keymap を変えた時 (normal <-> insert) でこれが呼ばれる
  # prompt を再描画

  if [[ $KEYMAP == 'vicmd' ]]; then
    __prompt_keymap__='%B%F{green}[NORMAL]%f%b'
  else
    __prompt_keymap__=''
  fi

  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# -----------------------------------------------------------------------------
function _my_hook_show_chdir() {
  if [[ $# == 0 ]]; then
    local _target=$PWD
  else
    local _target=$1
  fi

  local fcount=${$(timeout 1 ls ${_target} -A1 | wc -l)##*[[:blank:]]}
  echo -e "\e[31m ${fcount} files in \e[32m${_target}\e[m"
}

function _my_hook_precmd_ls() {
  ## FIXME: ディレクトリ指定での ls ではそのディレクトリごとに表示したい
  [[ "${2%%[[:blank:]]*}" == 'ls' ]] && _my_hook_show_chdir
}
add-zsh-hook chpwd   _my_hook_show_chdir
add-zsh-hook preexec _my_hook_precmd_ls

