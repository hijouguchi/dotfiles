# Dotfiles

## Available configurations

- git
- global
- screen
- ugrep
- vim
- zsh

## Directory Structure

```
dotfiles/
|-- README.md
|-- CLAUDE.md
|-- Makefile
|-- sources/
|   |-- git/
|   |   |-- config                  # global git config  -> ~/.config/git/config
|   |   |-- ignore                  # global gitignore   -> ~/.config/git/ignore
|   |   `-- config.local.template   # template           -> ~/.config/git/config.local
|   |-- global/
|   |   |-- .globalrc               # -> ~/.globalrc
|   |   `-- .ctags                  # -> ~/.ctags
|   |-- screen/
|   |   |-- common.screenrc         # -> ~/.config/screen/common.screenrc
|   |   |-- v4/                     # -> ~/.config/screen/v4/
|   |   |   |-- base.screenrc
|   |   |   |-- statusline-default.screenrc
|   |   |   |-- statusline-linux.screenrc
|   |   |   `-- statusline-macos.screenrc
|   |   `-- v5/                     # -> ~/.config/screen/v5/
|   |       |-- base.screenrc
|   |       |-- statusline-default.screenrc
|   |       |-- statusline-linux.screenrc
|   |       `-- statusline-macos.screenrc
|   |-- ugrep/
|   |   `-- .ugrep                  # -> ~/.ugrep
|   |-- vim/
|   |   |-- .vimrc                  # -> ~/.vimrc
|   |   |-- .gvimrc                 # -> ~/.gvimrc
|   |   `-- .vim/                   # -> ~/.vim/
|   `-- zsh/
|       |-- .zshrc                  # -> ~/.zshrc
|       |-- .zshenv                 # -> ~/.zshenv
|       |-- host-template.zsh       # template -> ~/.config/zsh/host.zshenv
|       |-- zfunctions/             # -> ~/.config/zsh/zfunctions/
|       `-- zshenv/                 # OS-specific env files (sourced by .zshenv)
`-- issues/
    `-- <issue-name>.md
```

## Installation

### Install configuration(s)

```bash
# install all configurations
make install  # or: make

# install specific configuration(s)
make install-vim install-zsh
```

### Uninstall configuration(s)

```bash
# uninstall all configurations
make uninstall

# uninstall specific configuration(s)
make uninstall-vim uninstall-zsh
```

### Options

| Variable  | Default | Description                                          |
|-----------|---------|------------------------------------------------------|
| `DRY_RUN` | `0`     | Set to `1` to preview actions without executing them |
| `FORCE`   | `0`     | Set to `1` to skip the confirmation prompt           |

```bash
# preview what would be installed without executing
make install DRY_RUN=1

# install without confirmation prompt
make install FORCE=1
```

## Install Destinations

| Config   | Source                               | Destination                      | Method   |
|----------|--------------------------------------|----------------------------------|----------|
| vim      | `sources/vim/.vimrc`                 | `~/.vimrc`                       | symlink  |
| vim      | `sources/vim/.gvimrc`                | `~/.gvimrc`                      | symlink  |
| vim      | `sources/vim/.vim/`                  | `~/.vim/`                        | symlink  |
| zsh      | `sources/zsh/.zshrc`                 | `~/.zshrc`                       | symlink  |
| zsh      | `sources/zsh/.zshenv`                | `~/.zshenv`                      | symlink  |
| zsh      | `sources/zsh/zfunctions/`            | `~/.config/zsh/zfunctions/`      | symlink  |
| zsh      | `sources/zsh/host-template.zsh`      | `~/.config/zsh/host.zshenv`      | template |
| zsh      | (mafredri/zsh-async)                 | `sources/zsh/zfunctions/async`   | download |
| git      | `sources/git/config`                 | `~/.config/git/config`           | symlink  |
| git      | `sources/git/ignore`                 | `~/.config/git/ignore`           | symlink  |
| git      | `sources/git/config.local.template`  | `~/.config/git/config.local`     | template |
| screen   | `sources/screen/common.screenrc`     | `~/.config/screen/common.screenrc` | symlink |
| screen   | `sources/screen/v4/`                 | `~/.config/screen/v4/`           | symlink  |
| screen   | `sources/screen/v5/`                 | `~/.config/screen/v5/`           | symlink  |
| screen   | (generated)                          | `~/.config/screen/host.screenrc` | generate |
| screen   | (generated)                          | `~/.screenrc`                    | generate |
| ugrep    | `sources/ugrep/.ugrep`               | `~/.ugrep`                       | symlink  |
| global   | `sources/global/.globalrc`           | `~/.globalrc`                    | symlink  |
| global   | `sources/global/.ctags`              | `~/.ctags`                       | symlink  |

### Notes

- **git**: `~/.config/git/config` and `~/.config/git/ignore` are read automatically by
  git 2.x as the global config and global gitignore (XDG Base Directory).
  No `core.excludesFile` setting is required.
- **template**: Template files are copied once (skipped if the destination already exists).
  Edit the copied file to add machine-specific settings.
- **uninstall**: Symlink targets are removed only when the destination is a symlink.
  Manually created regular files are preserved.
- **git/zsh local files**: `~/.config/git/config.local` and `~/.config/zsh/host.zshenv`
  are preserved on uninstall.
- **screen**: `~/.screenrc` is generated on each install and sources version/OS-specific files.
  It also sources manually created non-symlink `~/.config/screen/*.screenrc` files.

## Post-Install Manual Configuration

The following files are created from templates and must be edited manually after installation.

### `~/.config/git/config.local`

Set your git identity (name and email). This file is included by `~/.config/git/config`
via `[include]` and is intentionally excluded from version control.

```ini
[user]
    name  = Your Name
    email = you@example.com
```

### `~/.config/zsh/host.zshenv`

Add machine-specific shell environment settings. This file is sourced at the end of
`~/.zshenv` and is intentionally excluded from version control.

```zsh
export LANG=en_US.UTF-8
```
