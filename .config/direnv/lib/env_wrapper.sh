use_jenv() {
    export JENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/jenv
    eval "$(command jenv init -)"
}

use_rbenv() {
  export RBENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/rbenv
  eval "$(command rbenv init -)"
}

use_pyenv() {
    export PYENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/pyenv
    eval "$(command pyenv init -)"
}

use_nodenv() {
    export NODEENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/nodenv
    eval "$(command nodenv init -)"
}
