typeset -U path cdpath fpath

ZSHENV_DIR="${HOME}/dotfiles/zshenv"
ZSHENV_HOSTS_DIR="${HOME}/.zshenv.hosts"

case "$(uname -s 2>/dev/null)" in
  Darwin)
    [ -f "${ZSHENV_DIR}/macos.zsh" ] && source "${ZSHENV_DIR}/macos.zsh"
    ;;
  Linux)
    [ -f "${ZSHENV_DIR}/linux.zsh" ] && source "${ZSHENV_DIR}/linux.zsh"
    ;;
esac

host="$(hostname -s 2>/dev/null || hostname)"
if [ -n "${host}" ] && [ -f "${ZSHENV_HOSTS_DIR}/${host}.zsh" ]; then
  source "${ZSHENV_HOSTS_DIR}/${host}.zsh"
fi
