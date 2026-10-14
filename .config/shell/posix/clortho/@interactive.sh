command -v clortho >/dev/null 2>&1 || return 1

eval "$(command clortho init)"

seatbelt_debug() {
    /usr/bin/log stream \
        --style compact \
        --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'
}
