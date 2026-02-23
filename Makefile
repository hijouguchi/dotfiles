DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SOURCES_DIR  := $(DOTFILES_DIR)/sources
HOME_DIR     := $(HOME)

ASYNC_URL  := https://raw.githubusercontent.com/mafredri/zsh-async/main/async.zsh
ASYNC_FILE := $(SOURCES_DIR)/zsh/zfunctions/async

# Set DRY_RUN=1 to print commands without executing them.
DRY_RUN ?= 0

ifeq ($(DRY_RUN),1)
  RUN := @echo
else
  RUN :=
endif

.PHONY: all install uninstall \
  install-vim install-zsh install-git install-screen install-ugrep install-global \
  uninstall-vim uninstall-zsh uninstall-git uninstall-screen uninstall-ugrep uninstall-global

all: install

install: install-vim install-zsh install-git install-screen install-ugrep install-global

uninstall: uninstall-vim uninstall-zsh uninstall-git uninstall-screen uninstall-ugrep uninstall-global

# ------------------------------------------------------------------------------
# vim
# ------------------------------------------------------------------------------
install-vim:
	$(RUN) ln -sf $(SOURCES_DIR)/vim/.vimrc  $(HOME_DIR)/.vimrc
	$(RUN) ln -sf $(SOURCES_DIR)/vim/.gvimrc $(HOME_DIR)/.gvimrc
	$(RUN) ln -sf $(SOURCES_DIR)/vim/.vim    $(HOME_DIR)/.vim

uninstall-vim:
	$(RUN) rm -f $(HOME_DIR)/.vimrc $(HOME_DIR)/.gvimrc $(HOME_DIR)/.vim

# ------------------------------------------------------------------------------
# zsh
# ------------------------------------------------------------------------------
$(ASYNC_FILE):
	$(RUN) curl -fsSL $(ASYNC_URL) -o $@

install-zsh: $(ASYNC_FILE)
	$(RUN) ln -sf $(SOURCES_DIR)/zsh/.zshrc     $(HOME_DIR)/.zshrc
	$(RUN) ln -sf $(SOURCES_DIR)/zsh/.zshenv    $(HOME_DIR)/.zshenv
	$(RUN) ln -sf $(SOURCES_DIR)/zsh/zfunctions $(HOME_DIR)/zfunctions
	@if [ "$(DRY_RUN)" = "1" ]; then \
	  echo "mkdir -p $(HOME_DIR)/.zshenv.hosts"; \
	  echo "cp $(SOURCES_DIR)/zsh/zshenv/host-template.zsh" \
	       "$(HOME_DIR)/.zshenv.hosts/HOSTNAME.zsh  # if not exists"; \
	else \
	  mkdir -p $(HOME_DIR)/.zshenv.hosts; \
	  if [ ! -f $(HOME_DIR)/.zshenv.hosts/HOSTNAME.zsh ]; then \
	    cp $(SOURCES_DIR)/zsh/zshenv/host-template.zsh \
	       $(HOME_DIR)/.zshenv.hosts/HOSTNAME.zsh; \
	  fi; \
	fi

uninstall-zsh:
	$(RUN) rm -f $(HOME_DIR)/.zshrc $(HOME_DIR)/.zshenv $(HOME_DIR)/zfunctions

# ------------------------------------------------------------------------------
# git
# ------------------------------------------------------------------------------
install-git:
	$(RUN) ln -sf $(SOURCES_DIR)/git/.gitconfig        $(HOME_DIR)/.gitconfig
	$(RUN) ln -sf $(SOURCES_DIR)/git/.gitignore.global $(HOME_DIR)/.gitignore.global
	@if [ "$(DRY_RUN)" = "1" ]; then \
	  echo "cp $(SOURCES_DIR)/git/gitconfig.local.template" \
	       "$(HOME_DIR)/.gitconfig.local  # if not exists"; \
	else \
	  if [ ! -f $(HOME_DIR)/.gitconfig.local ]; then \
	    cp $(SOURCES_DIR)/git/gitconfig.local.template $(HOME_DIR)/.gitconfig.local; \
	  fi; \
	fi

uninstall-git:
	$(RUN) rm -f $(HOME_DIR)/.gitconfig $(HOME_DIR)/.gitignore.global

# ------------------------------------------------------------------------------
# screen
# ------------------------------------------------------------------------------
install-screen:
	$(RUN) ln -sf $(SOURCES_DIR)/screen/.screenrc $(HOME_DIR)/.screenrc

uninstall-screen:
	$(RUN) rm -f $(HOME_DIR)/.screenrc

# ------------------------------------------------------------------------------
# ugrep
# ------------------------------------------------------------------------------
install-ugrep:
	$(RUN) ln -sf $(SOURCES_DIR)/ugrep/.ugrep $(HOME_DIR)/.ugrep

uninstall-ugrep:
	$(RUN) rm -f $(HOME_DIR)/.ugrep

# ------------------------------------------------------------------------------
# global
# ------------------------------------------------------------------------------
install-global:
	$(RUN) ln -sf $(SOURCES_DIR)/global/.globalrc $(HOME_DIR)/.globalrc
	$(RUN) ln -sf $(SOURCES_DIR)/global/.ctags    $(HOME_DIR)/.ctags

uninstall-global:
	$(RUN) rm -f $(HOME_DIR)/.globalrc $(HOME_DIR)/.ctags
