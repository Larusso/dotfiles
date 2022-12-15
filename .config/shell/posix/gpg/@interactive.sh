
#
# Gpg configuration module.
#

export GPG_TTY=$(tty)

if [ $(uname -n) = "mw-llaruss-C94H" ]; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent
fi

gpg-connect-agent updatestartuptty /bye >/dev/null

gpgkill() {
  gpg-connect-agent killagent /bye
  gpg-connect-agent updatestartuptty /bye
  gpg-connect-agent /bye
}

gpgSerials() {
  gpg-connect-agent "scd serialno" "learn --force" /bye
}
