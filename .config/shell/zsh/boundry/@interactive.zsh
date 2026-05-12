command -v boundary >/dev/null 2>&1 || return 1

alias bsh="boundary connect ssh"
alias bauth="boundary authenticate oidc"
export BOUNDARY_ADDR=https://boundary.playticorp.com/
export AUTH_METHOD_ID=amoidc_P4805BEdcS
