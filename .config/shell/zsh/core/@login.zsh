#
# Core configuration module for zsh.
#

# Do not create group/world writable files by default.
umask a=rx,u+w
#
# XDG base directory
#
# References:
# - https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory
#

# Explicitly set XDG base directory defaults.
# This is done so that these variables can be assumed to be set later on.
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# XDG paths for zsh.
export ZDATADIR=${ZDATADIR:-$XDG_DATA_HOME/zsh}
export ZCACHEDIR=${ZCACHEDIR:-$XDG_CACHE_HOME/zsh}
command mkdir -p $ZDATADIR $ZCACHEDIR

# XDG_LIB_HOME environment overrides for package managers.
export CARGO_HOME="$XDG_LIB_HOME/cargo"
export GOPATH="$XDG_LIB_HOME/go"
export NPM_CONFIG_PREFIX="$XDG_LIB_HOME/npm"
