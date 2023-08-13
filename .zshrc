
## Changing Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CHASE_DOTS
setopt PUSHD_IGNORE_DUPS

HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY


################################################################################
# alias
################################################################################
alias  l='exa -hF'
alias ls='exa -hF'
alias la='exa -haF'
alias ll='exa -hlaF'
alias l1='exa -h1aF'

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

##  20.5 Bindable Commands {{{1
## vi like keybind {{{2
#bindkey -v
## Reverse the order of history (for my vim settings)
#bindkey               '^p'   history-beginning-search-backward
#bindkey               '^n'   history-beginning-search-forward
#bindkey               "^i"   menu-complete
#bindkey               "^[[Z" reverse-menu-complete
#bindkey -M vicmd      'u'    undo
#bindkey -M vicmd      '^r'   redo
#
## poted some convinient emacs key binds {{{2
#bindkey               '^b'    backward-char
#bindkey               '^f'    forward-char
#bindkey               '^a'    beginning-of-line
#bindkey               '^e'    end-of-line
#bindkey               '^k'    kill-line
#bindkey               '^x^b'  backward-word
#bindkey               '^x^f'  forward-word
#
## for hjkl in menuselect {{{2
#zmodload -i zsh/complist
#bindkey -M menuselect '^h'    backward-char
#bindkey -M menuselect '^j'    down-line-or-history
#bindkey -M menuselect '^k'    up-line-or-history
#bindkey -M menuselect '^l'    forward-char
#bindkey -M menuselect '^n'    down-line-or-history
#bindkey -M menuselect '^p'    up-line-or-history
#bindkey -M menuselect '^m'    self-insert
#
## 20 Completion {{{1
## 20.2 Initialization {{{2
#autoload -U compinit
#compinit -d $MY_ZSH_LOG_DIR/zcompdump
#
## zstyle settings {{{2
## see 20.3.2 Standard Tags and 20.3.3 Standard Styles
#zstyle ':completion:*' verbose yes
#
## see also 20.4 Control Functions
##zstyle ':completion:*' completer _complete _ignored
#
#zstyle ':completion:*:warnings'     format "%B%F{yellow}--- Not Found ---%f%b"
#zstyle ':completion:*:descriptions' format "%B%F{blue}--- Completing %d ---%f%b"
#zstyle ':completion:*:corrections'  format "%B%F{blue}--- %d%f %F{red}(erros: %e)%f %F{blue} ---%f%b"
#
#zstyle ':completion:*' group-name ''
#zstyle ':completion:*' menu select=2
#zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}'
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#
#zstyle ':completion:*' file-patterns '*(^-/):files:files' '*(-/):directories:directories'
#
#
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

RPROMPT='%B${vcs_info_msg_0_}%b'
RPROMPT+=':%4(~|%-1~/.../%2~|%~)'

## Functions {{{2
#function vi_mode_prompt_info() {
#  if [[ $KEYMAP == 'vicmd' ]]; then
#    echo '%B%F{green}[NORMAL]%f%b '
#  else
#    echo ""
#  fi
#}
#
#function zle-line-init zle-keymap-select {
#  zle reset-prompt
#}
#zle -N zle-line-init
#zle -N zle-keymap-select
#
#
## for chenge directory hook {{{2
#_my_hook_show_chdir() {
#  #echo "$fg[red]${$(ls -A1 | wc -l)##*[[:blank:]]} files$reset_color in $fg[green]`pwd`$reset_color"
#  local fcount=${$(timeout 1 ls -A1 | wc -l)##*[[:blank:]]}
#  echo -e "\e[31m ${fcount} files in \e[32m`pwd`\e[m"
#}
#_my_hook_precmd_ls() {
#  [[ "${2%%[[:blank:]]*}" == 'ls' ]] && _my_hook_show_chdir
#}
#add-zsh-hook chpwd   _my_hook_show_chdir
#add-zsh-hook preexec _my_hook_precmd_ls
#
## __END__ {{{1
## vim:smarttab expandtab
## vim:tabstop=2 shiftwidth=2 softtabstop=2
## vim:foldmethod=marker
