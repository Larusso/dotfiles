#
# jenv configuration module.
#

# Abort if requirements are not met.
if ! command -v jenv &> /dev/null
then
  return 1
fi

# jenv() {
#     unset -f jenv
#     export JENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/jenv
#     eval "$(command jenv init -)"
#     jenv $@
# }
