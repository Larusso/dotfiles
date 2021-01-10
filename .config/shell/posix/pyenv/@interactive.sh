#
# Pyenv configuration module.
#

# Abort if requirements are not met.
if ! command -v pyenv &> /dev/null
then
  return 1
fi

pyenv() {
    unset -f pyenv
    export RBENV_ROOT=$XDG_DATA_HOME/pyenv
    eval "$(command pyenv init -)"
    pyenv $@
}
