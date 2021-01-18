#
# Nodenv configuration module.
#

# Abort if requirements are not met.
if ! command -v nodenv &> /dev/null
then
  return 1
fi

nodenv() {
    unset -f nodenv
    export RBENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/nodenv
    eval "$(command nodenv init -)"
    nodenv $@
}
