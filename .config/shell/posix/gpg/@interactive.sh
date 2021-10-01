
#
# Gpg configuration module.
#

export GPG_TTY=$(tty)
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye >/dev/null

gpgkill() {
  gpg-connect-agent killagent /bye
  gpg-connect-agent updatestartuptty /bye
  gpg-connect-agent /bye
}
