
# for $LS_COLORS
eval `dircolors -b`

## Changing Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CHASE_DOTS
setopt PUSHD_IGNORE_DUPS

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zhistory
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
autoload -U compinit
compinit

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
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 5

zstyle ':vcs_info:*' stagedstr   '[stage]' # %c の文字列
zstyle ':vcs_info:*' unstagedstr '[unstage]' # %u の文字列

zstyle ':vcs_info:*' formats       '[%r:%b]' '%u' '%c' '%m'
zstyle ':vcs_info:*' actionformats '[%r:%b]' '%u' '%c' '%m' '%a'
zstyle ':vcs_info:git+set-message:*' hooks \
  git-hook-begin \
  git-status-untracked \
  git-status-push

function +vi-git-hook-begin() {
  if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
    # 0以外を返すとそれ以降のフック関数は呼び出されない
    return 1
  fi

  return 0
}

function +vi-git-status-untracked() {
  # called only 2nd hook (for %u)
  if [[ "$1" != "1" ]]; then
    return 0
  fi

  if command git status --porcelain 2> /dev/null \
      | awk '{print $1}' \
      | command grep -F '??' > /dev/null 2>&1 ; then

      # unstaged (%u) に追加
      hook_com[unstaged]="[untrack]${hook_com[unstaged]}"
  fi
}

function +vi-git-status-push() {
  # called only 4th hook (for %m)
  if [[ "$1" != "3" ]]; then
    return 0
  fi

  local ahead
  ahead=$(command git rev-list origin/${hook_com[branch]}..${hook_com[branch]} 2>/dev/null \
    | wc -l \
    | tr -d ' ')

  if [[ "$ahead" -gt 0 ]]; then
    # misc (%m) に追加
    hook_com[misc]+="[ahead]"
  fi
}

function _hook_precmd_vcs_info() {
  psvar=()

  vcs_info
}
add-zsh-hook precmd _hook_precmd_vcs_info

PROMPT=""
PROMPT+="%(?,,%F{red}[error]%f)"
PROMPT+='%B%F{red}${vcs_info_msg_1_}%f%b'
PROMPT+='%B%F{green}${vcs_info_msg_2_}%f%b'
PROMPT+='%B%F{blue}${vcs_info_msg_3_}%f%b'
PROMPT+='%B%F{red}${vcs_info_msg_4_}%f%b'
PROMPT+="%n@%m%#"
PROMPT="%B${PROMPT}%b "

PROMPT2="%_ > "

RPROMPT=''
RPROMPT+='$(vi_mode_prompt_info)'
RPROMPT+='%B${vcs_info_msg_0_}%b'
RPROMPT+=':%4(~|%-1~/.../%2~|%~)'

function vi_mode_prompt_info() {
  if [[ $KEYMAP == 'vicmd' ]]; then
    echo '%B%F{green}[NORMAL]%f%b'
  else
    echo ""
  fi
}

# keymap を変えた時 (normal <-> insert) でこれが呼ばれる
function zle-line-init zle-keymap-select {
  # prompt を再描画 (して、vi_mode_prompt_info を再評価)
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select


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
#
## __END__ {{{1
## vim:smarttab expandtab
## vim:tabstop=2 shiftwidth=2 softtabstop=2
## vim:foldmethod=marker
