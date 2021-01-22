#
# Cargo configuration module for zsh.
#

export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
export CARGO_HOME="${XDG_LIB_HOME:-$HOME/.local/lib}/cargo"

# Abort if requirements are not met.
if [ ! -f "$CARGO_HOME/env" ]; then
  #return 1
fi

source "$CARGO_HOME/env"

export CARGO_NAME="Manfred Endres"
export CARGO_EMAIL="manfred.endres@tslarusso.de"

# cargo new default settings
export CARGO_CARGO_NEW_NAME="Manfred Endres"
export CARGO_CARGO_NEW_EMAIL="manfred.endres@tslarusso.de"
export CARGO_CARGO_NEW_VCS="git"
