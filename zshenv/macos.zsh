eval "$(/opt/homebrew/bin/brew shellenv)"

path=( \
  /opt/packages/*/bin(N-/) \
  /opt/tool/*/bin(N-/) \
  $HOME/.local/bin \
  $(brew --prefix coreutils)/libexec/gnubin \
  $(brew --prefix llvm)/bin \
  $(brew --prefix ruby)/bin \
  $(brew --prefix rustup)/bin \
  /Applications/Docker.app/Contents/Resources/bin \
  $path \
)

fpath=( \
  $HOME/dotfiles/zfunctions \
  /usr/local/share/zsh/site-functions \
  /opt/homebrew/share/zsh/site-functions \
  /opt/homebrew/opt/rustup/share/zsh/site-functions \
  $fpath \
)

export VERILATOR_SOLVER='z3 --in'

setopt no_global_rcs
