#
# Cargo configuration module for zsh.
#

# Abort if requirements are not met.
if [ ! -f "${HOME}/.local/lib/cargo/env" ]; then
  return 1
fi

source "${HOME}/.local/lib/cargo/env"

export CARGO_HOME="$XDG_CACHE_HOME/cargo"
export CARGO_NAME="Manfred Endres"
export CARGO_EMAIL="manfred.endres@tslarusso.de"

# cargo new default settings
export CARGO_CARGO_NEW_NAME="Manfred Endres"
export CARGO_CARGO_NEW_EMAIL="manfred.endres@tslarusso.de"
export CARGO_CARGO_NEW_VCS="git"
