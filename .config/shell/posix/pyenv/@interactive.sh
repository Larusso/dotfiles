#
# Pyenv configuration module.
#

# Abort if requirements are not met.
if ! command -v pyenv &> /dev/null
then
  return 1
fi

# pyenv() {
#     unset -f pyenv
#     export PYENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/pyenv
#     eval "$(command pyenv init -)"
#     pyenv $@
# }
