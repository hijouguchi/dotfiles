DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SOURCES_DIR  := $(DOTFILES_DIR)/sources
HOME_DIR     := $(HOME)

ASYNC_URL  := https://raw.githubusercontent.com/mafredri/zsh-async/main/async.zsh
ASYNC_FILE := $(SOURCES_DIR)/zsh/zfunctions/async

# Set DRY_RUN=1 to print what would happen without executing.
# Set FORCE=1 to skip confirmation prompts.
DRY_RUN ?= 0
FORCE   ?= 0

# Shell functions shared across targets.
#   _plan_install DST         : show Install/Skip status for install planning.
#   _plan_remove  DST         : show Remove/Skip  status for uninstall planning.
#   _do_symlink   SRC DST     : create a symlink; skip if DST already exists.
#   _do_copy_template SRC DST : copy template to DST if DST does not exist.
#   _do_download  URL DST     : download URL to DST if DST does not exist.
#   _do_remove    DST         : remove DST if it exists.
#   _confirm                  : prompt [Yes]/No (default: Yes).
define SHELLFN
_plan_install() { \
  if [ ! -e "$$1" ]; then printf "Install: ~%s\n" "$${1#$$HOME}"; \
  else printf "Skip:    ~%s\n" "$${1#$$HOME}"; fi; \
}; \
_plan_remove() { \
  if [ -e "$$1" ] || [ -L "$$1" ]; then printf "Remove: ~%s\n" "$${1#$$HOME}"; \
  else printf "Skip:   ~%s\n" "$${1#$$HOME}"; fi; \
}; \
_do_symlink() { \
  if [ "$(DRY_RUN)" = "1" ]; then \
    if [ ! -e "$$2" ]; then printf "Installed: ~%s\n" "$${2#$$HOME}"; \
    else printf "Skipped:   ~%s\n" "$${2#$$HOME}"; fi; \
  elif [ ! -e "$$2" ]; then \
    ln -sf "$$1" "$$2"; printf "Installed: ~%s\n" "$${2#$$HOME}"; \
  else \
    printf "Skipped:   ~%s\n" "$${2#$$HOME}"; \
  fi; \
}; \
_do_copy_template() { \
  if [ "$(DRY_RUN)" = "1" ]; then \
    if [ ! -e "$$2" ]; then printf "Installed: ~%s\n" "$${2#$$HOME}"; \
    else printf "Skipped:   ~%s\n" "$${2#$$HOME}"; fi; \
  elif [ ! -e "$$2" ]; then \
    cp "$$1" "$$2"; printf "Installed: ~%s\n" "$${2#$$HOME}"; \
  else \
    printf "Skipped:   ~%s\n" "$${2#$$HOME}"; \
  fi; \
}; \
_do_download() { \
  if [ "$(DRY_RUN)" = "1" ]; then \
    if [ ! -e "$$2" ]; then printf "Installed: ~%s\n" "$${2#$$HOME}"; \
    else printf "Skipped:   ~%s\n" "$${2#$$HOME}"; fi; \
  elif [ ! -e "$$2" ]; then \
    curl -fsSL "$$1" -o "$$2"; printf "Installed: ~%s\n" "$${2#$$HOME}"; \
  else \
    printf "Skipped:   ~%s\n" "$${2#$$HOME}"; \
  fi; \
}; \
_do_remove() { \
  if [ "$(DRY_RUN)" = "1" ]; then \
    if [ -e "$$1" ] || [ -L "$$1" ]; then printf "Removed: ~%s\n" "$${1#$$HOME}"; \
    else printf "Skipped: ~%s\n" "$${1#$$HOME}"; fi; \
  elif [ -e "$$1" ] || [ -L "$$1" ]; then \
    rm -f "$$1"; printf "Removed: ~%s\n" "$${1#$$HOME}"; \
  else \
    printf "Skipped: ~%s\n" "$${1#$$HOME}"; \
  fi; \
}; \
_confirm() { \
  printf "Do you want to proceed? [Yes]/No: "; \
  read _ans </dev/tty; \
  case "$$_ans" in [nN]*) printf "Aborted.\n"; return 1 ;; esac; \
}
endef

.PHONY: all install uninstall \
  install-vim install-zsh install-git install-screen install-ugrep install-global \
  uninstall-vim uninstall-zsh uninstall-git uninstall-screen uninstall-ugrep uninstall-global

all: install

install: install-vim install-zsh install-git install-screen install-ugrep install-global

uninstall: uninstall-vim uninstall-zsh uninstall-git uninstall-screen uninstall-ugrep uninstall-global

# ------------------------------------------------------------------------------
# vim
#   symlink: sources/vim/.vimrc  -> ~/.vimrc
#   symlink: sources/vim/.gvimrc -> ~/.gvimrc
#   symlink: sources/vim/.vim/   -> ~/.vim/
# ------------------------------------------------------------------------------
install-vim:
	@$(SHELLFN); \
	echo "===== Install Vim Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.vimrc"; \
	  _plan_install "$(HOME_DIR)/.gvimrc"; \
	  _plan_install "$(HOME_DIR)/.vim"; \
	  _confirm || exit 0; \
	fi; \
	_do_symlink "$(SOURCES_DIR)/vim/.vimrc"  "$(HOME_DIR)/.vimrc"; \
	_do_symlink "$(SOURCES_DIR)/vim/.gvimrc" "$(HOME_DIR)/.gvimrc"; \
	_do_symlink "$(SOURCES_DIR)/vim/.vim"    "$(HOME_DIR)/.vim"

uninstall-vim:
	@$(SHELLFN); \
	echo "===== Uninstall Vim Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.vimrc"; \
	  _plan_remove "$(HOME_DIR)/.gvimrc"; \
	  _plan_remove "$(HOME_DIR)/.vim"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.vimrc"; \
	_do_remove "$(HOME_DIR)/.gvimrc"; \
	_do_remove "$(HOME_DIR)/.vim"

# ------------------------------------------------------------------------------
# zsh
#   symlink:  sources/zsh/.zshrc           -> ~/.zshrc
#   symlink:  sources/zsh/.zshenv          -> ~/.zshenv
#   symlink:  sources/zsh/zfunctions/      -> ~/.config/zsh/zfunctions/
#   template: sources/zsh/host-template.zsh -> ~/.config/zsh/host.zshenv
#   download: zsh-async (mafredri/zsh-async) -> sources/zsh/zfunctions/async
# ------------------------------------------------------------------------------
install-zsh:
	@$(SHELLFN); \
	echo "===== Install Zsh Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.zshrc"; \
	  _plan_install "$(HOME_DIR)/.zshenv"; \
	  _plan_install "$(HOME_DIR)/.config/zsh/zfunctions"; \
	  _plan_install "$(HOME_DIR)/.config/zsh/host.zshenv"; \
	  _plan_install "$(ASYNC_FILE)"; \
	  _confirm || exit 0; \
	fi; \
	_do_symlink "$(SOURCES_DIR)/zsh/.zshrc"     "$(HOME_DIR)/.zshrc"; \
	_do_symlink "$(SOURCES_DIR)/zsh/.zshenv"    "$(HOME_DIR)/.zshenv"; \
	if [ "$(DRY_RUN)" != "1" ]; then mkdir -p "$(HOME_DIR)/.config/zsh"; fi; \
	_do_symlink "$(SOURCES_DIR)/zsh/zfunctions" "$(HOME_DIR)/.config/zsh/zfunctions"; \
	_do_copy_template "$(SOURCES_DIR)/zsh/host-template.zsh" \
	  "$(HOME_DIR)/.config/zsh/host.zshenv"; \
	_do_download "$(ASYNC_URL)" "$(ASYNC_FILE)"

uninstall-zsh:
	@$(SHELLFN); \
	echo "===== Uninstall Zsh Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.zshrc"; \
	  _plan_remove "$(HOME_DIR)/.zshenv"; \
	  _plan_remove "$(HOME_DIR)/.config/zsh/zfunctions"; \
	  _plan_remove "$(HOME_DIR)/.config/zsh/host.zshenv"; \
	  _plan_remove "$(ASYNC_FILE)"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.zshrc"; \
	_do_remove "$(HOME_DIR)/.zshenv"; \
	_do_remove "$(HOME_DIR)/.config/zsh/zfunctions"; \
	_do_remove "$(HOME_DIR)/.config/zsh/host.zshenv"; \
	_do_remove "$(ASYNC_FILE)"

# ------------------------------------------------------------------------------
# git
#   symlink:  sources/git/config              -> ~/.config/git/config
#   symlink:  sources/git/ignore              -> ~/.config/git/ignore
#   template: sources/git/config.local.template -> ~/.config/git/config.local
# ------------------------------------------------------------------------------
install-git:
	@$(SHELLFN); \
	echo "===== Install Git Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.config/git/config"; \
	  _plan_install "$(HOME_DIR)/.config/git/ignore"; \
	  _plan_install "$(HOME_DIR)/.config/git/config.local"; \
	  _confirm || exit 0; \
	fi; \
	if [ "$(DRY_RUN)" != "1" ]; then mkdir -p "$(HOME_DIR)/.config/git"; fi; \
	_do_symlink "$(SOURCES_DIR)/git/config" "$(HOME_DIR)/.config/git/config"; \
	_do_symlink "$(SOURCES_DIR)/git/ignore" "$(HOME_DIR)/.config/git/ignore"; \
	_do_copy_template "$(SOURCES_DIR)/git/config.local.template" \
	  "$(HOME_DIR)/.config/git/config.local"

uninstall-git:
	@$(SHELLFN); \
	echo "===== Uninstall Git Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.config/git/config"; \
	  _plan_remove "$(HOME_DIR)/.config/git/ignore"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.config/git/config"; \
	_do_remove "$(HOME_DIR)/.config/git/ignore"

# ------------------------------------------------------------------------------
# screen
#   symlink: sources/screen/.screenrc -> ~/.screenrc
# ------------------------------------------------------------------------------
install-screen:
	@$(SHELLFN); \
	echo "===== Install Screen Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.screenrc"; \
	  _confirm || exit 0; \
	fi; \
	_do_symlink "$(SOURCES_DIR)/screen/.screenrc" "$(HOME_DIR)/.screenrc"

uninstall-screen:
	@$(SHELLFN); \
	echo "===== Uninstall Screen Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.screenrc"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.screenrc"

# ------------------------------------------------------------------------------
# ugrep
#   symlink: sources/ugrep/.ugrep -> ~/.ugrep
# ------------------------------------------------------------------------------
install-ugrep:
	@$(SHELLFN); \
	echo "===== Install Ugrep Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.ugrep"; \
	  _confirm || exit 0; \
	fi; \
	_do_symlink "$(SOURCES_DIR)/ugrep/.ugrep" "$(HOME_DIR)/.ugrep"

uninstall-ugrep:
	@$(SHELLFN); \
	echo "===== Uninstall Ugrep Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.ugrep"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.ugrep"

# ------------------------------------------------------------------------------
# global
#   symlink: sources/global/.globalrc -> ~/.globalrc
#   symlink: sources/global/.ctags    -> ~/.ctags
# ------------------------------------------------------------------------------
install-global:
	@$(SHELLFN); \
	echo "===== Install Global Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will install the following files:"; \
	  _plan_install "$(HOME_DIR)/.globalrc"; \
	  _plan_install "$(HOME_DIR)/.ctags"; \
	  _confirm || exit 0; \
	fi; \
	_do_symlink "$(SOURCES_DIR)/global/.globalrc" "$(HOME_DIR)/.globalrc"; \
	_do_symlink "$(SOURCES_DIR)/global/.ctags"    "$(HOME_DIR)/.ctags"

uninstall-global:
	@$(SHELLFN); \
	echo "===== Uninstall Global Configuration ====="; \
	if [ "$(DRY_RUN)" != "1" ] && [ "$(FORCE)" != "1" ]; then \
	  echo "I will remove the following files:"; \
	  _plan_remove "$(HOME_DIR)/.globalrc"; \
	  _plan_remove "$(HOME_DIR)/.ctags"; \
	  _confirm || exit 0; \
	fi; \
	_do_remove "$(HOME_DIR)/.globalrc"; \
	_do_remove "$(HOME_DIR)/.ctags"
