
#
# Gpg configuration module.
#

export GPG_TTY=$(tty)
current_hostname=$(uname -n)
if [[ "$current_hostname" == "mw-llaruss-C94H" ]] || [[ "$current_hostname" == "mw-mendres-JYJJ" ]]; then
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

gpgImportFromGithub() {
  curl "https://github.com/${1}.gpg" | gpg --import
}
