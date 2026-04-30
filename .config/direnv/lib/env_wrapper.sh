use_jenv() {
    command -v jenv >/dev/null 2>&1 || return 1
    export JENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/jenv
    eval "$(command jenv init -)"
}

use_rbenv() {
    command -v rbenv >/dev/null 2>&1 || return 1
    export RBENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/rbenv
    eval "$(command rbenv init -)"
}

use_pyenv() {
    command -v pyenv >/dev/null 2>&1 || return 1
    export PYENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/pyenv
    eval "$(command pyenv init -)"
}

use_nodenv() {
    command -v nodenv >/dev/null 2>&1 || return 1
    export NODEENV_ROOT=${XDG_DATA_HOME:-$HOME/.local/share}/nodenv
    eval "$(command nodenv init -)"
}
