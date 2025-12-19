if [[ "$current_hostname" == "mw-mendres-JYJJ" ]]; then
  alias bsh="boundary connect ssh"
  alias bauth="boundary authenticate oidc"
  export BOUNDARY_ADDR=https://boundary.playticorp.com/
  export AUTH_METHOD_ID=amoidc_P4805BEdcS
fi