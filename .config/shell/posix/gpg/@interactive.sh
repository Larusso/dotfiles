
#
# Gpg configuration module.
#

ensure_gpg_agent_running() {
  if ! pgrep -x "gpg-agent" > /dev/null; then
    gpgconf --launch gpg-agent
  fi
  
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpg-connect-agent updatestartuptty /bye >/dev/null
}

export GPG_TTY=$(tty)
if [[ "$(yadm config local.class 2>/dev/null)" == "work-primary" ]]; then
  ensure_gpg_agent_running
else
  gpg-connect-agent updatestartuptty /bye >/dev/null
fi

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
