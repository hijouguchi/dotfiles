# Dotfiles

## Available configurations

- claude
- codex
- git
- global
- screen
- ugrep
- vim
- zsh

## Directory Structures

```
dotfiles/
|-- README.md
|-- CLAUDE.md
|-- AGENTNS.md
|-- Makefile
|-- sources/
|   |-- claude/
|   |-- codex/
|   |-- git/
|   |-- global/
|   |-- screen/
|   |-- ugrep/
|   |-- vim/
|   `-- zsh/
`-- issues/
    `-- <issue-name>.md
```

## Installation

### Install configuration(s)

```bash
# install all configurations
make install # or make

# install specific configuration
make install-vim install-zsh
```

### Uninstall configurations(s)

```bash
# uninstall all configurations
make uninstall

# uninstall specific configuration
make uninstall-vim uninstall-zsh
```
