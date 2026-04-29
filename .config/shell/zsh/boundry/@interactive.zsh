[[ "$(yadm config local.class 2>/dev/null)" == "work-primary" ]] || return 1

alias bsh="boundary connect ssh"
alias bauth="boundary authenticate oidc"
export BOUNDARY_ADDR=https://boundary.playticorp.com/
export AUTH_METHOD_ID=amoidc_P4805BEdcS