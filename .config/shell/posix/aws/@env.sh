#
# aws configuration module.
#

export AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/aws/credentials"

export SAML2AWS_CONFIGFILE="${XDG_CONFIG_HOME:-$HOME/.config}/saml2aws/config"
export SAML2AWS_CREDENTIALS_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/saml2aws/credentials"
