typeset -U path cdpath fpath

ZSHENV_DIR="${HOME}/dotfiles/sources/zsh/zshenv"

case "$(uname -s 2>/dev/null)" in
  Darwin)
    [ -f "${ZSHENV_DIR}/macos.zsh" ] && source "${ZSHENV_DIR}/macos.zsh"
    ;;
  Linux)
    [ -f "${ZSHENV_DIR}/linux.zsh" ] && source "${ZSHENV_DIR}/linux.zsh"
    ;;
esac

[ -f "${HOME}/.config/zsh/host.zshenv" ] && source "${HOME}/.config/zsh/host.zshenv"
