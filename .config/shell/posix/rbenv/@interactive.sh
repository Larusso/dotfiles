#
# Rbenv configuration module.
#

# Abort if requirements are not met.
if ! command -v rbenv &> /dev/null
then
  return 1
fi

# rbenv() {
#     unset -f rbenv
#     export RBENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/rbenv
#     eval "$(command rbenv init -)"
#     rbenv $@
# }
